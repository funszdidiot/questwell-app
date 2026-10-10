"""Synthetic, offline tests. These never use a real private key or contact Apple."""

import hashlib
import json
import os
from pathlib import Path
import plistlib
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tool.ci import ios_upload as upload
from tool.ci import ios_testflight as signing
from tool.qa.ios_testflight_test import request, SHA

KEY = "-----BEGIN PRIVATE KEY-----\nU1lOVEhFVElDX05PVF9BX1JFQUxfS0VZ\n-----END PRIVATE KEY-----\n"


def env():
    return request() | {"IOS_UPLOAD_REQUESTED": "true", "IOS_UPLOAD_APPROVED_SHA": SHA,
                        "GITHUB_RUN_ID": "123456", "GITHUB_RUN_ATTEMPT": "1",
                        "ASC_API_KEY_ID": "TESTKEY123",
                        "ASC_API_ISSUER_ID": "11111111-1111-1111-1111-111111111111"}


def result(message, code=0):
    return subprocess.CompletedProcess([], code, json.dumps({"success-message": message}).encode(), b"")


class UploadTest(unittest.TestCase):
    def test_exact_source_opt_in_and_no_reruns(self):
        self.assertEqual(upload.check_request(env()), (SHA, "1.0.1"))
        for name, value in {"IOS_UPLOAD_REQUESTED": "false", "IOS_UPLOAD_APPROVED_SHA": "",
                            "GITHUB_RUN_ATTEMPT": "2", "GITHUB_RUN_ID": "",
                            "GITHUB_SHA": "b" * 40, "GITHUB_REF": "refs/heads/flutterflow",
                            "GITHUB_EVENT_NAME": "pull_request"}.items():
            with self.subTest(name=name), self.assertRaises(signing.SigningError):
                upload.check_request(env() | {name: value})

    def test_success_requires_positive_structured_confirmation(self):
        self.assertTrue(upload.apple_success(result("No errors uploading 'test.ipa'."), "uploading"))
        for r in (result("No errors validating 'test.ipa'."), result("No errors uploading x", 1),
                  result(""), subprocess.CompletedProcess([], 0, b"UPLOAD FAILED", b""),
                  subprocess.CompletedProcess([], 0, b'{"success-message":"No errors uploading x",'
                                                     b'"product-errors":[{"code":-1}]}', b""),
                  subprocess.CompletedProcess([], 0, b"[]", b"")):
            self.assertFalse(upload.apple_success(r, "uploading"))

    def fixture(self, root):
        (root / "ios").mkdir()
        (root / "ios/Podfile.lock").write_text("PODS:\n  - Flutter (1.0.0)\n")
        app = root / "sample.app"
        app.mkdir()
        (app / "Info.plist").write_bytes(plistlib.dumps({"NSCameraUsageDescription": "Attach a photo",
                                                        "CFBundleURLTypes": [{"CFBundleURLSchemes": ["test"]}]}))
        (app / "PrivacyInfo.xcprivacy").write_bytes(plistlib.dumps({"NSPrivacyTracking": False}))
        output = root / "build/ios-signing-evidence"
        output.mkdir(parents=True)
        with patch.object(signing, "ROOT", root):
            hashes = signing.collect_review_evidence(app, output)
        ipa = root / "build/ios/ipa/Test.ipa"
        ipa.parent.mkdir(parents=True)
        ipa.write_bytes(b"synthetic-ipa")
        evidence = {"source_sha": SHA, "build_number": "1.0.1", "bundle_id": signing.BUNDLE,
                    "team_id": signing.TEAM, "app_store_id": signing.APP_ID,
                    "version": "1.0.0", "environment": "live_beta", "uploaded": False,
                    "github_run_id": "123456", "github_run_attempt": "1",
                    "ipa_sha256": hashlib.sha256(ipa.read_bytes()).hexdigest(), **hashes}
        (output / "validation.json").write_text(json.dumps(evidence))
        return output, ipa

    def test_review_inventory_uses_exported_bundle(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            output, _ = self.fixture(root)
            review = json.loads((output / "native-review.json").read_text())
            self.assertEqual(review["permission_descriptions"], {"NSCameraUsageDescription": "Attach a photo"})
            self.assertFalse(review["privacy_manifests"][0]["declarations"]["NSPrivacyTracking"])
            self.assertFalse(review["review_complete"])
            self.assertEqual((output / "Podfile.lock").read_bytes(), (root / "ios/Podfile.lock").read_bytes())

    def test_evidence_rejects_tampering_and_cross_run_reuse(self):
        for target in ("ipa", "lock", "review", "run", "source"):
            with self.subTest(target=target), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                output, ipa = self.fixture(root)
                with patch.object(upload, "ROOT", root):
                    upload.verified_ipa(env(), SHA, "1.0.1")
                    if target == "ipa": ipa.write_bytes(b"changed")
                    if target == "lock": (root / "ios/Podfile.lock").write_bytes(b"changed")
                    if target == "review": (output / "native-review.json").write_bytes(b"changed")
                    test_env = env() | ({"GITHUB_RUN_ID": "999"} if target == "run" else {})
                    with self.assertRaises(signing.SigningError):
                        upload.verified_ipa(test_env, "b" * 40 if target == "source" else SHA, "1.0.1")

    def exercise(self, failure=None):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            output, ipa = self.fixture(root)
            request_env = env() | {"RUNNER_TEMP": tmp, "ASC_API_PRIVATE_KEY": KEY,
                                   "IOS_DISTRIBUTION_P12_PASSWORD": "never-inherit"}
            calls = []
            def fake_process(args, *, env, timeout=120):
                args = [str(a) for a in args]
                calls.append(args)
                self.assertNotIn(upload.KEY_NAME, env)
                self.assertTrue(set(signing.SECRET_NAMES).isdisjoint(env))
                if "--help" in args:
                    return subprocess.CompletedProcess([], 0, b"--validate-app --upload-app --apiKey "
                        b"--apiIssuer --apple-id --output-format API_PRIVATE_KEYS_DIR", b"")
                key = Path(env["API_PRIVATE_KEYS_DIR"]) / "AuthKey_TESTKEY123.p8"
                self.assertEqual(key.stat().st_mode & 0o777, 0o600)
                self.assertEqual(key.read_text(), KEY)
                if args[0] == "openssl": return result("", 1 if failure == "key" else 0)
                if "--validate-app" in args:
                    if failure == "tamper": ipa.write_bytes(b"tamper after validation")
                    return result("bad response" if failure == "validation" else "No errors validating test.ipa")
                if "--upload-app" in args:
                    self.assertEqual(args[-2:], ["--apple-id", signing.APP_ID])
                    if failure == "timeout": raise subprocess.TimeoutExpired(args, timeout)
                    return result("bad response" if failure == "upload" else "No errors uploading test.ipa")
                self.fail("Unexpected command")
            with patch.object(upload, "ROOT", root), patch.object(upload, "preflight", return_value=(SHA, "1.0.1")), \
                 patch.object(upload, "process", side_effect=fake_process):
                if failure:
                    with self.assertRaises((signing.SigningError, subprocess.TimeoutExpired)):
                        upload.deliver(request_env, KEY)
                else:
                    upload.deliver(request_env, KEY)
            self.assertFalse(list(root.glob("questwell-apple-key-*")))
            uploads = [c for c in calls if "--upload-app" in c]
            self.assertEqual(len(uploads), 0 if failure in ("key", "validation", "tamper") else 1)
            report = output / "apple-delivery.json"
            if report.exists():
                data = json.loads(report.read_text())
                self.assertEqual(data["upload_confirmed"], failure is None)
                self.assertFalse(data["apple_processing_verified"])
                self.assertNotIn(KEY, report.read_text())
                if failure in ("upload", "timeout"):
                    self.assertEqual(data["status"], "upload_outcome_unknown")

    def test_one_upload_and_cleanup(self): self.exercise()
    def test_key_failure_never_contacts_apple(self): self.exercise("key")
    def test_validation_failure_never_uploads(self): self.exercise("validation")
    def test_ipa_mutation_after_validation_never_uploads(self): self.exercise("tamper")
    def test_zero_exit_upload_error_stays_unconfirmed(self): self.exercise("upload")
    def test_timeout_is_not_retried_and_key_is_cleaned(self): self.exercise("timeout")

    def test_preflight_requires_committed_unchanged_native_lock(self):
        for command in ("ls-files", "diff"):
            def fake_run(args):
                if args[:2] == ["git", command]: raise signing.SigningError("lock rejected")
                if args[:2] == ["git", "rev-parse"]: return SHA.encode()
                return b""
            with patch.object(upload.sys, "platform", "darwin"), patch.object(signing, "run", side_effect=fake_run):
                with self.assertRaisesRegex(signing.SigningError, "lock rejected"):
                    upload.preflight(env())

    def test_workflow_separates_upload_key_from_build_steps(self):
        script = "process.stdout.write(JSON.stringify(require('./tool/ci/node_modules/yaml').parse(require('fs').readFileSync('.github/workflows/questwell-ios-testflight.yml','utf8'))))"
        workflow = json.loads(subprocess.run(["node", "-e", script], cwd=ROOT, capture_output=True, check=True).stdout)
        self.assertFalse(workflow["on"]["workflow_dispatch"]["inputs"]["upload_to_testflight"]["default"])
        job = workflow["jobs"]["archive"]
        self.assertNotIn("ASC_API_PRIVATE_KEY", job["env"])
        steps = job["steps"]
        exposed = [s for s in steps if "ASC_API_PRIVATE_KEY" in s.get("env", {})]
        self.assertEqual(len(exposed), 1)
        self.assertEqual(exposed[0]["if"], "inputs.upload_to_testflight")
        self.assertEqual(exposed[0]["run"], "python3 -m tool.ci.ios_upload")
        signing_index = next(i for i, s in enumerate(steps) if s.get("run") == "python3 tool/ci/ios_testflight.py")
        self.assertGreater(steps.index(exposed[0]), signing_index)
        self.assertEqual(steps[-1]["if"], "always()")


if __name__ == "__main__":
    unittest.main(verbosity=2)
