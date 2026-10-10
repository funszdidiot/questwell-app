"""Credential-free tests for staging signing; no network or Apple operations."""

import base64
import json
import os
import runpy
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tool.ci import ios_testflight as signing
from tool.ci import ios_upload
from tool.qa import ios_testflight_test as fixtures


def request():
    return fixtures.request() | {
        "GITHUB_WORKFLOW_REF": "funszdidiot/questwell-app/.github/workflows/questwell-ios-staging.yml@refs/heads/questwell-dev",
        "IOS_STAGING_APPROVED_SHA": fixtures.SHA,
        "GITHUB_RUN_ATTEMPT": "1", "IOS_UPLOAD_REQUESTED": "false"}


class StagingBoundaryTest(unittest.TestCase):
    def test_module_entrypoint_is_fixed_to_staging(self):
        with patch.object(signing, "main", return_value=0) as main:
            with self.assertRaises(SystemExit) as result:
                runpy.run_module("tool.ci.ios_staging", run_name="__main__")
            self.assertEqual(result.exception.code, 0)
            main.assert_called_once_with("staging")

    def test_exact_staging_dispatch(self):
        self.assertEqual(signing.validate_staging_request(request()), (fixtures.SHA, "1.0.1"))
        for key in request():
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_staging_request(request() | {key: "wrong"})
        for key in ("IOS_UPLOAD_APPROVED_SHA", "ASC_API_PRIVATE_KEY"):
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_staging_request(request() | {key: "present"})

    def test_staging_entrypoint_cannot_fall_back_to_live(self):
        with patch.dict(os.environ, request(), clear=True), \
             patch.object(signing, "credentials", return_value=(b"fixture", "test", b"fixture")), \
             patch.object(signing, "build_signed_archive") as build:
            self.assertEqual(signing.main("staging"), 0)
            self.assertEqual(build.call_args.args[-1], "staging")
        with patch.dict(os.environ, fixtures.request(), clear=True), \
             patch.object(signing, "credentials") as credentials:
            self.assertEqual(signing.main("staging"), 1)
            credentials.assert_not_called()

    def test_staging_settings_reject_live_duplicate_and_unknown_profiles(self):
        settings = fixtures.build_settings("staging")
        signing.validate_build_settings(settings, fixtures.UUID, fixtures.IDENTITY, fixtures.SHA, "staging")
        for profile in ("live_beta", "isolated_test"):
            with self.subTest(profile=profile), self.assertRaises(signing.SigningError):
                signing.validate_build_settings(fixtures.build_settings(profile), fixtures.UUID,
                                                fixtures.IDENTITY, fixtures.SHA, "staging")
        settings[0]["buildSettings"]["DART_DEFINES"] += "," + base64.b64encode(b"QUESTWELL_ENVIRONMENT=staging").decode()
        with self.assertRaises(signing.SigningError):
            signing.validate_build_settings(settings, fixtures.UUID, fixtures.IDENTITY, fixtures.SHA, "staging")
        with self.assertRaises(signing.SigningError):
            signing.build_signed_archive(fixtures.SHA, "1.0.1", (), "arbitrary")

    def test_existing_upload_rejects_staging_evidence(self):
        evidence = {"source_sha": fixtures.SHA, "build_number": "1.0.1",
                    "bundle_id": signing.BUNDLE, "team_id": signing.TEAM,
                    "app_store_id": signing.APP_ID, "version": "1.0.0",
                    "environment": "staging", "uploaded": False,
                    "github_run_id": "123", "github_run_attempt": "1"}
        with patch.object(Path, "read_text", return_value=json.dumps(evidence)):
            with self.assertRaisesRegex(signing.SigningError, "Signing evidence"):
                ios_upload.verified_ipa({"GITHUB_RUN_ID": "123"}, fixtures.SHA, "1.0.1")

    def test_workflow_has_no_delivery_surface(self):
        script = "process.stdout.write(JSON.stringify(require('./tool/ci/node_modules/yaml').parse(require('fs').readFileSync('.github/workflows/questwell-ios-staging.yml','utf8'))))"
        workflow = json.loads(subprocess.run(["node", "-e", script], cwd=ROOT,
                              capture_output=True, check=True).stdout)
        self.assertEqual(list(workflow["on"]), ["workflow_dispatch"])
        self.assertEqual(set(workflow["on"]["workflow_dispatch"]["inputs"]), {"source_sha", "build_number"})
        self.assertEqual(workflow["permissions"], {"contents": "read"})
        self.assertEqual(workflow["concurrency"], {"group": "questwell-ios-signing", "cancel-in-progress": False})
        self.assertEqual(set(workflow["jobs"]), {"quality", "archive"})
        self.assertEqual(workflow["jobs"]["quality"], {
            "if": "github.ref == 'refs/heads/questwell-dev' && inputs.source_sha == github.sha",
            "uses": "./.github/workflows/questwell-flutter-check.yml"})
        job = workflow["jobs"]["archive"]
        self.assertEqual(job["steps"][0]["with"], {
            "persist-credentials": False, "ref": "${{ github.sha }}"})
        self.assertEqual(job["environment"], "ios-testflight")
        self.assertEqual(job["needs"], "quality")
        self.assertEqual(job["runs-on"], "macos-15")
        self.assertEqual(job["if"], "github.event_name == 'workflow_dispatch' && github.ref == 'refs/heads/questwell-dev' && inputs.source_sha == github.sha")
        self.assertEqual(job["env"]["IOS_UPLOAD_REQUESTED"], "false")
        exposed = [s for s in job["steps"] if "secrets." in json.dumps(s)]
        self.assertEqual(len(exposed), 1)
        self.assertEqual(exposed[0]["run"], "python3 -m tool.ci.ios_staging")
        self.assertEqual(set(exposed[0]["env"]), set(signing.SECRET_NAMES))
        self.assertNotIn("ASC_API_", json.dumps(workflow))
        self.assertNotIn("ios_upload", json.dumps(workflow))
        artifacts = [s for s in job["steps"] if s.get("uses", "").startswith("actions/upload-artifact@")]
        self.assertEqual(len(artifacts), 1)
        self.assertEqual(artifacts[0]["with"]["path"].split(), [
            "build/ios-signing-evidence/validation.json", "build/ios-signing-evidence/Podfile.lock",
            "build/ios-signing-evidence/native-review.json", "build/ios-signing-evidence/altool-help.txt"])
        check = (ROOT / ".github/workflows/questwell-flutter-check.yml").read_text()
        self.assertIn("run: python3 tool/qa/ios_staging_test.py", check)
        self.assertIn("--no-codesign --target lib/main.dart --dart-define=QUESTWELL_ENVIRONMENT=staging", check)


class StagingOrchestrationTest(fixtures.SigningOrchestrationTest):
    def exercise(self, failure=None, environment="staging"):
        super().exercise(failure, environment)


if __name__ == "__main__":
    unittest.main(verbosity=2)
