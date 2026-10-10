"""Opt-in Apple delivery of this run's verified IPA. Never distribute to testers."""

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

from tool.ci import ios_testflight as signing

ROOT = signing.ROOT
KEY_NAME = "ASC_API_PRIVATE_KEY"


def check_request(env):
    sha, number = signing.validate_request(env)
    signing.require(env.get("IOS_UPLOAD_REQUESTED") == "true",
                    "Apple upload must be explicitly selected on the manual dispatch.")
    signing.require(env.get("IOS_UPLOAD_APPROVED_SHA") == sha,
                    "This source revision has not been approved for Apple upload.")
    signing.require(env.get("GITHUB_RUN_ATTEMPT") == "1",
                    "Do not rerun an upload; check Apple delivery status before a new dispatch.")
    signing.require(re.fullmatch(r"[0-9]+", env.get("GITHUB_RUN_ID", "")), "Missing workflow run ID.")
    return sha, number


def process(args, *, env, timeout=120):
    # Capture all tool diagnostics: Apple tools may include auth material in them.
    return subprocess.run([str(a) for a in args], cwd=ROOT, env=env,
                          capture_output=True, check=False, timeout=timeout)


def preflight(env):
    sha, number = check_request(env)
    signing.require(sys.platform == "darwin", "Apple upload requires the pinned macOS runner.")
    signing.require(signing.run(["git", "rev-parse", "HEAD"]).decode().strip() == sha,
                    "Upload checkout revision mismatch.")
    signing.run(["git", "ls-files", "--error-unmatch", "ios/Podfile.lock"])
    signing.run(["git", "diff", "--exit-code", "HEAD", "--", "ios/Podfile.lock"])
    signing.require(signing.run(["xcodebuild", "-version"]).decode().strip() ==
                    "Xcode 26.3\nBuild version 17C529", "Upload requires pinned Xcode 26.3.")
    return sha, number


def verified_ipa(env, sha, number):
    evidence = json.loads((ROOT / "build/ios-signing-evidence/validation.json").read_text())
    expected = {"source_sha": sha, "build_number": number, "bundle_id": signing.BUNDLE,
                "team_id": signing.TEAM, "app_store_id": signing.APP_ID,
                "version": "1.0.0", "environment": "live_beta", "uploaded": False,
                "github_run_id": env["GITHUB_RUN_ID"], "github_run_attempt": "1"}
    signing.require(all(evidence.get(k) == v for k, v in expected.items()),
                    "Signing evidence does not match this upload request and run.")
    lock_hash = hashlib.sha256((ROOT / "ios/Podfile.lock").read_bytes()).hexdigest()
    signing.require(evidence.get("podfile_lock_sha256") == lock_hash,
                    "Signed native dependencies differ from the reviewed lockfile.")
    native = ROOT / "build/ios-signing-evidence/native-review.json"
    signing.require(evidence.get("native_review_sha256") == hashlib.sha256(native.read_bytes()).hexdigest(),
                    "Native review evidence changed after signing.")
    ipas = list((ROOT / "build/ios/ipa").glob("*.ipa"))
    signing.require(len(ipas) == 1 and ipas[0].is_file() and not ipas[0].is_symlink(),
                    "Expected one local IPA from this signing job.")
    signing.require(hashlib.sha256(ipas[0].read_bytes()).hexdigest() == evidence.get("ipa_sha256"),
                    "IPA changed after signature validation.")
    return ipas[0], evidence


def apple_success(result, operation):
    """Fail closed on Apple errors even when altool returns zero; never echo output."""
    if result.returncode != 0:
        return False
    try:
        payload = json.loads(result.stdout)
    except (ValueError, UnicodeError):
        return False
    if not isinstance(payload, dict) or payload.get("product-errors") or payload.get("errors"):
        return False
    message = payload.get("success-message")
    return isinstance(message, str) and message.startswith(f"No errors {operation} ")


def deliver(env, private_key):
    sha, number = preflight(env)
    ipa, evidence = verified_ipa(env, sha, number)
    key_id, issuer = env.get("ASC_API_KEY_ID", ""), env.get("ASC_API_ISSUER_ID", "")
    signing.require(re.fullmatch(r"[A-Z0-9]{10}", key_id), "Invalid Apple key ID.")
    signing.require(re.fullmatch(r"[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}", issuer),
                    "Invalid Apple issuer ID.")
    signing.require(isinstance(private_key, str) and len(private_key) <= 16384 and
                    re.fullmatch(r"-----BEGIN PRIVATE KEY-----\r?\n[A-Za-z0-9+/=\r\n]+"
                                 r"-----END PRIVATE KEY-----\s*", private_key),
                    "Apple secret must contain the entire PEM private key.")
    clean_env = {k: v for k, v in env.items() if k not in (*signing.SECRET_NAMES, KEY_NAME)}
    help_result = process(["xcrun", "altool", "--help"], env=clean_env)
    help_text = (help_result.stdout + help_result.stderr).decode(errors="replace")
    for token in ("--validate-app", "--upload-app", "--apiKey", "--apiIssuer", "--apple-id",
                  "--output-format", "API_PRIVATE_KEYS_DIR"):
        signing.require(token in help_text, "Pinned altool interface changed; review its local help.")
    report_path = ROOT / "build/ios-signing-evidence/apple-delivery.json"
    signing.require(not report_path.exists(), "This runner already has a delivery record; do not retry.")
    report = {"source_sha": sha, "build_number": number, "app_store_id": signing.APP_ID,
              "ipa_sha256": evidence["ipa_sha256"], "upload_attempted": False,
              "upload_confirmed": False, "apple_processing_verified": False,
              "testers_notified": False, "status": "preparing"}
    def record(status):
        report["status"] = status
        report_path.write_text(json.dumps(report, indent=2) + "\n")
    with tempfile.TemporaryDirectory(prefix="questwell-apple-key-", dir=env["RUNNER_TEMP"]) as tmp:
        key = Path(tmp) / f"AuthKey_{key_id}.p8"
        with open(key, "x", opener=lambda path, flags: os.open(path, flags, 0o600)) as handle:
            handle.write(private_key)
        clean_env["API_PRIVATE_KEYS_DIR"] = tmp
        key_check = process(["openssl", "pkey", "-in", key, "-check", "-noout"], env=clean_env)
        signing.require(key_check.returncode == 0, "Apple private key is invalid.")
        common = ["--type", "ios", "-f", ipa, "--apiKey", key_id, "--apiIssuer", issuer,
                  "--output-format", "json"]
        record("validating")
        try:
            validation = process(["xcrun", "altool", "--validate-app", *common],
                                 env=clean_env, timeout=900)
            signing.require(apple_success(validation, "validating"),
                            "Apple validation did not confirm success; upload was not attempted.")
            # Recheck bytes after remote validation before the one non-retried upload.
            verified_ipa(env, sha, number)
            report["upload_attempted"] = True
            record("upload_outcome_unknown")
            result = process(["xcrun", "altool", "--upload-app", *common,
                              "--apple-id", signing.APP_ID], env=clean_env, timeout=1200)
            signing.require(apple_success(result, "uploading"),
                            "Upload outcome is unconfirmed; inspect App Store Connect before any retry.")
            report["upload_confirmed"] = True
            record("uploaded_processing_unverified")
        finally:
            if not report["upload_attempted"]:
                record("validation_not_confirmed")
    print("Apple upload confirmed. Processing, export compliance and tester access remain unverified.")


def main():
    # Drop credentials from the process environment before any child can inherit them.
    private_key = os.environ.pop(KEY_NAME, "")
    for name in signing.SECRET_NAMES:
        os.environ.pop(name, None)
    try:
        if sys.argv[1:] == ["--check-request"]:
            if os.environ.get("IOS_UPLOAD_REQUESTED") == "true":
                preflight(os.environ)
            return 0
        signing.require(not sys.argv[1:], "Unsupported upload arguments.")
        deliver(os.environ, private_key)
    except signing.SigningError as error:
        print(f"Apple delivery stopped: {error}", file=sys.stderr)
        return 1
    except (OSError, ValueError, KeyError, subprocess.TimeoutExpired):
        print("Apple delivery stopped: tool/file failure; inspect delivery evidence and Apple before retrying.",
              file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
