"""Credential-free boundary and orchestration tests for iOS signing preparation."""

import base64
import datetime as dt
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
from tool.ci import ios_testflight as signing

UUID = "12345678-1234-1234-1234-123456789ABC"
CERT = b"synthetic-test-certificate-not-a-real-credential"
IDENTITY = hashlib.sha1(CERT).hexdigest().upper()
SHA = "a" * 40
NOW = dt.datetime(2026, 10, 10, tzinfo=dt.timezone.utc)


def profile():
    return {"TeamIdentifier": [signing.TEAM], "UUID": UUID,
            "ExpirationDate": dt.datetime(2099, 1, 1), "DeveloperCertificates": [CERT],
            "Entitlements": {"application-identifier": f"{signing.TEAM}.{signing.BUNDLE}",
                             "com.apple.developer.team-identifier": signing.TEAM,
                             "get-task-allow": False, "beta-reports-active": True}}


def request():
    return {"GITHUB_EVENT_NAME": "workflow_dispatch", "GITHUB_REF": "refs/heads/questwell-dev",
            "GITHUB_REPOSITORY": "funszdidiot/questwell-app", "GITHUB_SHA": SHA,
            "IOS_SOURCE_SHA": SHA, "IOS_BUILD_NUMBER": "1.0.1", "IOS_SIGNING_ENABLED": "true"}


def build_settings():
    defines = ("QUESTWELL_ENVIRONMENT=live_beta", "QUESTWELL_DECORATE_HEARTH=true", f"QUESTWELL_BUILD={SHA}")
    return [{"target": "Runner", "buildSettings": {"PRODUCT_BUNDLE_IDENTIFIER": signing.BUNDLE,
             "DEVELOPMENT_TEAM": signing.TEAM, "CODE_SIGN_STYLE": "Manual", "CODE_SIGN_IDENTITY": IDENTITY,
             "PROVISIONING_PROFILE_SPECIFIER": UUID,
             "DART_DEFINES": ",".join(base64.b64encode(d.encode()).decode() for d in defines)}}]


def app_info():
    return {"CFBundleIdentifier": signing.BUNDLE, "CFBundleDisplayName": "Questwell",
            "CFBundleShortVersionString": "1.0.0", "CFBundleVersion": "1.0.1",
            "DTPlatformName": "iphoneos"}


class SigningValidationTest(unittest.TestCase):
    def test_request_accepts_only_trusted_exact_revision(self):
        self.assertEqual(signing.validate_request(request()), (SHA, "1.0.1"))
        for key, value in {"GITHUB_EVENT_NAME": "pull_request", "GITHUB_REF": "refs/heads/attacker",
                           "GITHUB_REPOSITORY": "fork/questwell-app", "GITHUB_SHA": "b" * 40,
                           "IOS_SOURCE_SHA": "$(shell)", "IOS_SIGNING_ENABLED": "false"}.items():
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_request(request() | {key: value})

    def test_build_number_limits_and_injection(self):
        for number in ("", "1", "0.1.1", "10000.0.0", "1.100.0", "1.0.100", "01.0.1", "1.0.1; env"):
            with self.subTest(number=number), self.assertRaises(signing.SigningError):
                signing.validate_request(request() | {"IOS_BUILD_NUMBER": number})
        signing.validate_request(request() | {"IOS_BUILD_NUMBER": "9999.99.99"})

    def test_secret_validation_reports_names_not_values(self):
        encoded = base64.b64encode(b"fixture").decode()
        env = dict(zip(signing.SECRET_NAMES, (encoded, "secret-password", encoded)))
        self.assertEqual(signing.credentials(env), (b"fixture", "secret-password", b"fixture"))
        for key in signing.SECRET_NAMES:
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.credentials(env | {key: ""})
        with self.assertRaisesRegex(signing.SigningError, "Invalid Base64") as error:
            signing.credentials(env | {signing.SECRET_NAMES[0]: "private!"})
        self.assertNotIn("private!", str(error.exception))
        with self.assertRaises(signing.SigningError):
            signing.credentials(env | {signing.SECRET_NAMES[2]: base64.b64encode(b"x" * (1024*1024+1)).decode()})

    def test_explicit_app_store_profile(self):
        self.assertEqual(signing.validate_profile(profile(), NOW), UUID)
        for key, value in {"TeamIdentifier": ["WRONG"], "ExpirationDate": NOW.replace(tzinfo=None),
                           "UUID": "../../other", "DeveloperCertificates": [],
                           "ProvisionedDevices": [], "ProvisionsAllDevices": True,
                           "Entitlements": "wrong"}.items():
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_profile(profile() | {key: value}, NOW)

    def test_profile_entitlement_failures(self):
        for key, value in {"application-identifier": f"{signing.TEAM}.*",
                           "com.apple.developer.team-identifier": "wrong",
                           "get-task-allow": True, "beta-reports-active": False}.items():
            p = profile()
            p["Entitlements"][key] = value
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_profile(p, NOW)

    def test_certificate_must_match_valid_identity_and_profile(self):
        output = f'1) {IDENTITY} "Apple Distribution: Test Person ({signing.TEAM})"'
        self.assertEqual(signing.select_identity(output, profile()), IDENTITY)
        for changed in (output.replace(IDENTITY, "A" * 40), output.replace("Distribution", "Development"), "0 valid identities found"):
            with self.subTest(output=changed), self.assertRaises(signing.SigningError):
                signing.select_identity(changed, profile())

    def test_project_patch_is_release_only_and_reversible(self):
        project = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
        changed = signing.signed_project(project, UUID, IDENTITY)
        self.assertEqual(changed.count("PROVISIONING_PROFILE_SPECIFIER"), 1)
        start = project.index(signing.RELEASE_ID + " /* Release */ =")
        end = project.index("/* End XCBuildConfiguration section */")
        self.assertEqual(project[:start], changed[:start])
        self.assertEqual(project[end:], changed[changed.index("/* End XCBuildConfiguration section */"):])
        for bad in (project.replace(signing.BUNDLE, "wrong"), project.replace(signing.RELEASE_ID, "OTHER"), changed):
            with self.assertRaises(signing.SigningError):
                signing.signed_project(bad, UUID, IDENTITY)

    def test_signed_info_and_entitlements_reject_drift(self):
        signing.validate_app_info(app_info(), "1.0.1")
        for key in app_info():
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_app_info(app_info() | {key: "wrong"}, "1.0.1")
        ent = profile()["Entitlements"]
        signing.validate_entitlements(ent)
        for key in ("application-identifier", "com.apple.developer.team-identifier", "get-task-allow"):
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_entitlements(ent | {key: "wrong"})

    def test_effective_settings_reject_wrong_signer_and_test_backend(self):
        signing.validate_build_settings(build_settings(), UUID, IDENTITY, SHA)
        for key in build_settings()[0]["buildSettings"]:
            bad = build_settings()
            bad[0]["buildSettings"][key] = "wrong"
            with self.subTest(key=key), self.assertRaises(signing.SigningError):
                signing.validate_build_settings(bad, UUID, IDENTITY, SHA)
        for environment in ("isolated_test", "staging"):
            bad = build_settings()
            wrong = base64.b64encode(f"QUESTWELL_ENVIRONMENT={environment}".encode()).decode()
            values = bad[0]["buildSettings"]
            values["DART_DEFINES"] = wrong + "," + values["DART_DEFINES"]
            with self.assertRaises(signing.SigningError):
                signing.validate_build_settings(bad, UUID, IDENTITY, SHA)

    def test_export_is_manual_and_never_upload(self):
        opts = signing.export_options(UUID, IDENTITY)
        self.assertEqual(opts["destination"], "export")
        self.assertEqual(opts["signingStyle"], "manual")
        self.assertEqual(opts["provisioningProfiles"], {signing.BUNDLE: UUID})
        self.assertFalse(opts["manageAppVersionAndBuildNumber"])

    def test_subprocess_does_not_receive_or_report_secrets(self):
        result = subprocess.CompletedProcess([], 1, b"", b"private diagnostic")
        env = dict(zip(signing.SECRET_NAMES, ("private-p12", "private-password", "private-profile")))
        with patch.dict(os.environ, env), patch.object(signing.subprocess, "run", return_value=result) as call:
            with self.assertRaises(signing.SigningError) as error:
                signing.run(["security", "import", "private-file", "-P", "private-password"])
            self.assertNotIn("private", str(error.exception))
            self.assertTrue(set(signing.SECRET_NAMES).isdisjoint(call.call_args.kwargs["env"]))

    def test_main_rejects_missing_credentials_before_macos_actions(self):
        with patch.dict(os.environ, request(), clear=True), patch.object(signing, "build_signed_archive") as build:
            self.assertEqual(signing.main(), 1)
            build.assert_not_called()

    def test_workflow_contract(self):
        # Parse with the existing locked YAML dependency; no second parser/version.
        script = "process.stdout.write(JSON.stringify(require('./tool/ci/node_modules/yaml').parse(require('fs').readFileSync('.github/workflows/questwell-ios-testflight.yml','utf8'))))"
        result = subprocess.run(["node", "-e", script], cwd=ROOT, capture_output=True, check=True)
        workflow = json.loads(result.stdout)
        self.assertEqual(list(workflow["on"]), ["workflow_dispatch"])
        self.assertEqual(workflow["permissions"], {"contents": "read"})
        job = workflow["jobs"]["archive"]
        self.assertEqual(job["environment"], "ios-testflight")
        self.assertEqual(job["needs"], "quality")
        self.assertIn("inputs.source_sha == github.sha", job["if"])
        self.assertIn("github.event_name == 'workflow_dispatch'", job["if"])
        self.assertEqual(job["runs-on"], "macos-15")
        exposed = [s for s in job["steps"] if any("secrets." in str(v) for v in s.get("env", {}).values())]
        self.assertEqual(len(exposed), 1)
        self.assertEqual(exposed[0]["run"], "python3 tool/ci/ios_testflight.py")
        uploads = [s for s in job["steps"] if s.get("uses", "").startswith("actions/upload-artifact@")]
        self.assertEqual([s["with"]["path"] for s in uploads], ["build/ios-signing-evidence/validation.json"])
        check = (ROOT / ".github/workflows/questwell-flutter-check.yml").read_text()
        self.assertIn("run: python3 tool/qa/ios_testflight_test.py", check)


class SigningOrchestrationTest(unittest.TestCase):
    """Exercise a complete synthetic archive/export plus failures through cleanup."""

    def exercise(self, failure=None):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "repo"
            project = root / "ios/Runner.xcodeproj/project.pbxproj"
            project.parent.mkdir(parents=True)
            original = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_bytes()
            project.write_bytes(original)
            calls = []
            def fake_run(args, **kwargs):
                args = [str(a) for a in args]
                calls.append(args)
                if failure == "import" and args[:2] == ["security", "import"]:
                    raise signing.SigningError("Synthetic import failure")
                if args[:3] == ["git", "rev-parse", "HEAD"]:
                    return SHA.encode()
                if args[:2] == ["xcodebuild", "-version"]:
                    return b"Xcode 26.3\nBuild version 17C529\n"
                if args[0] == "xcrun": return b"26.2\n"
                if args[:2] == ["flutter", "--version"]: return b'{"frameworkVersion":"3.44.6"}'
                if args[:2] == ["pod", "--version"]: return b"1.17.0\n"
                if args[:2] == ["security", "cms"]: return plistlib.dumps(profile())
                if args[:2] == ["security", "find-identity"]:
                    return f'1) {IDENTITY} "Apple Distribution: Test ({signing.TEAM})"'.encode()
                if args[:3] == ["codesign", "--display", "--entitlements"]:
                    return plistlib.dumps(profile()["Entitlements"])
                if args[:2] == ["codesign", "--verify"] and failure == "verify":
                    raise signing.SigningError("Synthetic signature failure")
                if args[0] == "xcodebuild" and "-showBuildSettings" in args:
                    return json.dumps(build_settings()).encode()
                if args[0] == "xcodebuild" and args[-1] == "archive":
                    if failure == "build": raise signing.SigningError("Synthetic build failure")
                    app = root / "build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app"
                    app.mkdir(parents=True)
                    (app / "Info.plist").write_bytes(plistlib.dumps(app_info()))
                if args[:2] == ["xcodebuild", "-exportArchive"] and failure != "export":
                        ipa = root / "build/ios/ipa/Questwell.ipa"
                        ipa.parent.mkdir(parents=True)
                        ipa.write_bytes(b"synthetic-export")
                if args[0] == "ditto":
                    app = Path(args[-1]) / "Payload/Runner.app"
                    app.mkdir(parents=True)
                    (app / "Info.plist").write_bytes(plistlib.dumps(app_info()))
                return b""
            help_text = " ".join((*signing.export_options("", "").keys(), "app-store-connect")).encode()
            with patch.object(signing, "ROOT", root), patch.object(signing.sys, "platform", "darwin"), \
                 patch.object(signing, "run", side_effect=fake_run), patch.object(Path, "home", return_value=Path(tmp)), \
                 patch.dict(os.environ, {"RUNNER_TEMP": tmp}), \
                 patch.object(signing.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, help_text, b"")):
                if failure:
                    with self.assertRaises(signing.SigningError):
                        signing.build_signed_archive(SHA, "1.0.1", (b"fixture", "password", b"fixture"))
                else:
                    signing.build_signed_archive(SHA, "1.0.1", (b"fixture", "password", b"fixture"))
            self.assertEqual(project.read_bytes(), original)
            self.assertFalse(list(Path(tmp).rglob("*.mobileprovision")))
            self.assertFalse(list(Path(tmp).glob("questwell-signing-*")))
            self.assertTrue(any(c[:2] == ["security", "delete-keychain"] for c in calls))
            report = root / "build/ios-signing-evidence/validation.json"
            self.assertEqual(report.exists(), failure is None)
            if report.exists():
                evidence = json.loads(report.read_text())
                self.assertEqual(evidence["source_sha"], SHA)
                self.assertFalse(evidence["uploaded"])
                self.assertNotIn("password", report.read_text())
            self.assertTrue(any("--config-only" in c and "--no-codesign" in c for c in calls) or failure == "import")
            self.assertFalse(any(c[:3] == ["flutter", "build", "ipa"] for c in calls))
            self.assertFalse(any("--upload-app" in c or "-allowProvisioningUpdates" in c for c in calls))

    def test_synthetic_archive_export_golden_path(self):
        self.exercise()

    def test_import_failure_cleans_keychain(self):
        self.exercise("import")

    def test_build_failure_restores_project_and_cleans_credentials(self):
        self.exercise("build")

    def test_archive_without_export_is_failure(self):
        self.exercise("export")

    def test_invalid_signature_is_failure(self):
        self.exercise("verify")


if __name__ == "__main__":
    unittest.main(verbosity=2)
