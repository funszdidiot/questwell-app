"""Prepare and verify a local signed iOS archive; never upload or distribute it."""

import base64
import binascii
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import secrets
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
BUNDLE = "com.alreyva.questwell"
TEAM = "W5779VXQYR"
APP_ID = "6821206348"
SECRET_NAMES = ("IOS_DISTRIBUTION_P12_BASE64", "IOS_DISTRIBUTION_P12_PASSWORD",
                "IOS_APP_STORE_PROFILE_BASE64")
RELEASE_ID = "97C147071CF9000F007C117D"


class SigningError(Exception):
    """Safe, actionable error whose message never contains credential values."""


def require(condition, message):
    if not condition:
        raise SigningError(message)


def validate_request(env):
    require(env.get("GITHUB_EVENT_NAME") == "workflow_dispatch" and
            env.get("GITHUB_REF") == "refs/heads/questwell-dev" and
            env.get("GITHUB_REPOSITORY") == "funszdidiot/questwell-app",
            "Signing requires a manual dispatch on Questwell's development branch.")
    sha = env.get("IOS_SOURCE_SHA", "")
    require(re.fullmatch(r"[0-9a-f]{40}", sha) and sha == env.get("GITHUB_SHA"),
            "Requested source SHA must equal the dispatched development revision.")
    require(env.get("IOS_SIGNING_ENABLED") == "true",
            "Protected ios-testflight environment has not been enabled.")
    version = env.get("IOS_BUILD_NUMBER", "")
    # Apple's three-component CFBundleVersion limits, not an unbounded run ID.
    require(re.fullmatch(r"[1-9][0-9]{0,3}\.(?:0|[1-9][0-9]?)\.(?:0|[1-9][0-9]?)", version),
            "Build number must be N.N.N (1–9999, 0–99, 0–99).")
    return sha, version


def credentials(env):
    for name in SECRET_NAMES:
        require(bool(env.get(name)), f"Missing protected environment secret: {name}")
    decoded = []
    for name in (SECRET_NAMES[0], SECRET_NAMES[2]):
        try:
            value = base64.b64decode(env[name], validate=True)
        except (ValueError, binascii.Error):
            raise SigningError(f"Invalid Base64 in {name}") from None
        require(0 < len(value) <= 1024 * 1024, f"Invalid file size in {name}")
        decoded.append(value)
    return decoded[0], env[SECRET_NAMES[1]], decoded[1]


def validate_staging_request(env):
    """A separate, exact-source gate; never inherit live-beta upload approval."""
    sha, number = validate_request(env)
    require(env.get("GITHUB_WORKFLOW_REF") ==
            "funszdidiot/questwell-app/.github/workflows/questwell-ios-staging.yml@refs/heads/questwell-dev",
            "Staging signing requires the dedicated development workflow.")
    require(env.get("IOS_STAGING_APPROVED_SHA") == sha,
            "This exact source has not been approved for a staging archive.")
    require(env.get("GITHUB_RUN_ATTEMPT") == "1",
            "Staging signing requires a fresh approved dispatch.")
    require(env.get("IOS_UPLOAD_REQUESTED") == "false" and
            not env.get("IOS_UPLOAD_APPROVED_SHA") and
            not env.get("ASC_API_PRIVATE_KEY"),
            "Staging archive must not receive upload approval or Apple API credentials.")
    return sha, number


def validate_profile(profile, now=None):
    require(isinstance(profile, dict), "Provisioning profile is not a dictionary.")
    ent = profile.get("Entitlements", {})
    require(isinstance(ent, dict), "Invalid profile entitlements.")
    require(profile.get("TeamIdentifier") == [TEAM], "Provisioning team mismatch.")
    require(ent.get("application-identifier") == f"{TEAM}.{BUNDLE}" and
            ent.get("com.apple.developer.team-identifier") == TEAM,
            "Profile must authorize the exact registered app and team.")
    require(ent.get("get-task-allow") is False and ent.get("beta-reports-active") is True
            and "ProvisionedDevices" not in profile and not profile.get("ProvisionsAllDevices"),
            "An App Store distribution profile is required; debug/ad hoc/enterprise rejected.")
    expires = profile.get("ExpirationDate")
    now = now or dt.datetime.now(dt.timezone.utc)
    require(isinstance(expires, dt.datetime), "Profile expiry is missing.")
    require(expires.replace(tzinfo=dt.timezone.utc) > now, "Provisioning profile has expired.")
    uuid = profile.get("UUID", "")
    require(isinstance(uuid, str) and re.fullmatch(r"[A-Fa-f0-9]{8}(?:-[A-Fa-f0-9]{4}){3}-[A-Fa-f0-9]{12}", uuid),
            "Profile UUID is invalid.")
    certs = profile.get("DeveloperCertificates", [])
    require(isinstance(certs, list) and certs and
            all(isinstance(c, bytes) and c for c in certs), "Profile has no signing certificates.")
    return uuid


def select_identity(output, profile):
    allowed = {hashlib.sha1(c).hexdigest().upper() for c in profile["DeveloperCertificates"]}
    matches = re.findall(r'\b([A-F0-9]{40}) "Apple Distribution:[^\n"]+ \(' + TEAM + r'\)"', output)
    matches = set(matches) & allowed
    require(len(matches) == 1, "Expected exactly one valid distribution identity matching the profile.")
    return matches.pop()


def signed_project(project, uuid, identity):
    require(re.fullmatch(r"[A-F0-9]{40}", identity), "Invalid signing identity fingerprint.")
    require(re.fullmatch(r"[A-Fa-f0-9-]{36}", uuid), "Invalid signing profile identifier.")
    pattern = rf"(^\t\t{RELEASE_ID} /\* Release \*/ = \{{\n)(.*?)(^\t\t\}};)"
    matches = list(re.finditer(pattern, project, re.M | re.S))
    require(len(matches) == 1, "Runner Release configuration changed; signing needs review.")
    match = matches[0]
    body = match[2]
    require(f"PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE};" in body and
            f"DEVELOPMENT_TEAM = {TEAM};" in body, "Runner Release identity mismatch.")
    require(not re.search(r"CODE_SIGN_|PROVISIONING_PROFILE", body),
            "Existing Runner signing settings require explicit reconciliation.")
    marker = "\t\t\tbuildSettings = {\n"
    require(body.count(marker) == 1, "Runner Release settings layout changed.")
    additions = (f'\t\t\t\tCODE_SIGN_STYLE = Manual;\n'
                 f'\t\t\t\tCODE_SIGN_IDENTITY = "{identity}";\n'
                 f'\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "{uuid}";\n')
    return project[:match.start(2)] + body.replace(marker, marker + additions) + project[match.end(2):]


def validate_app_info(info, build_number):
    for key, expected in {"CFBundleIdentifier": BUNDLE, "CFBundleDisplayName": "Questwell",
                          "CFBundleShortVersionString": "1.0.0", "CFBundleVersion": build_number,
                          "DTPlatformName": "iphoneos"}.items():
        require(info.get(key) == expected, f"Signed application {key} mismatch.")


def validate_entitlements(ent):
    require(ent.get("application-identifier") == f"{TEAM}.{BUNDLE}" and
            ent.get("com.apple.developer.team-identifier") == TEAM and
            ent.get("get-task-allow") is False, "Signed app entitlements mismatch.")


def run(args, *, visible=False):
    # Do not propagate private files/passwords to Flutter, pods, or build scripts.
    env = {k: v for k, v in os.environ.items() if k not in SECRET_NAMES}
    result = subprocess.run([str(a) for a in args], cwd=ROOT, env=env,
                            stdout=None if visible else subprocess.PIPE,
                            stderr=None if visible else subprocess.PIPE, check=False)
    # CalledProcessError would include the password-bearing argument list.
    require(result.returncode == 0, f"{Path(args[0]).name} failed; exit code {result.returncode}.")
    return result.stdout or b""


def validate_build_settings(settings, uuid, identity, sha, environment="live_beta"):
    require(environment in ("live_beta", "staging"), "Unsupported signed build environment.")
    runners = [item.get("buildSettings", {}) for item in settings if item.get("target") == "Runner"]
    require(len(runners) == 1, "Expected one effective Runner build configuration.")
    values = runners[0]
    for key, expected in {"PRODUCT_BUNDLE_IDENTIFIER": BUNDLE, "DEVELOPMENT_TEAM": TEAM,
                          "CODE_SIGN_STYLE": "Manual", "CODE_SIGN_IDENTITY": identity,
                          "PROVISIONING_PROFILE_SPECIFIER": uuid}.items():
        require(values.get(key) == expected, f"Effective Runner {key} mismatch.")
    try:
        defines = [base64.b64decode(item, validate=True).decode()
                   for item in values.get("DART_DEFINES", "").split(",")]
    except (ValueError, UnicodeError, binascii.Error):
        raise SigningError("Effective Dart build configuration is invalid.") from None
    for expected in (f"QUESTWELL_ENVIRONMENT={environment}", "QUESTWELL_DECORATE_HEARTH=true",
                     f"QUESTWELL_BUILD={sha}"):
        key = expected.split("=", 1)[0] + "="
        require([d for d in defines if d.startswith(key)] == [expected],
                "Effective Dart build configuration does not match the approved beta request.")


def export_options(uuid, identity):
    return {"method": "app-store-connect", "destination": "export", "teamID": TEAM,
            "signingStyle": "manual", "signingCertificate": identity,
            "provisioningProfiles": {BUNDLE: uuid}, "manageAppVersionAndBuildNumber": False}


def verify_app(app, build_number, expected_uuid):
    require(app.is_dir() and not app.is_symlink(), "Signed application is missing.")
    require(not list(app.rglob("*.appex")), "App extensions require a separate reviewed signing contract.")
    info = plistlib.loads((app / "Info.plist").read_bytes())
    validate_app_info(info, build_number)
    run(["codesign", "--verify", "--deep", "--strict", app])
    ent = plistlib.loads(run(["codesign", "--display", "--entitlements", "-", "--xml", app]))
    validate_entitlements(ent)
    profile = plistlib.loads(run(["security", "cms", "-D", "-i", app / "embedded.mobileprovision"]))
    require(validate_profile(profile) == expected_uuid, "Embedded provisioning profile changed.")


def collect_review_evidence(app, output):
    """Inventory the exported app; this is evidence for review, not a compliance claim."""
    lock = ROOT / "ios/Podfile.lock"
    require(lock.is_file() and not lock.is_symlink(), "Native dependency lockfile is missing.")
    lock_bytes = lock.read_bytes()
    require(0 < len(lock_bytes) < 1024 * 1024, "Invalid native dependency lockfile size.")
    (output / "Podfile.lock").write_bytes(lock_bytes)
    manifests = []
    for path in sorted(app.rglob("PrivacyInfo.xcprivacy")):
        require(not path.is_symlink(), "Symlinked privacy manifest requires review.")
        data = path.read_bytes()
        value = plistlib.loads(data)
        require(isinstance(value, dict), "Invalid privacy manifest.")
        manifests.append({"path": path.relative_to(app).as_posix(),
                          "sha256": hashlib.sha256(data).hexdigest(), "declarations": value})
    info = plistlib.loads((app / "Info.plist").read_bytes())
    inventory = {"privacy_manifests": manifests,
                 "permission_descriptions": {k: v for k, v in info.items()
                                             if k.startswith("NS") and k.endswith("UsageDescription")},
                 "url_types": info.get("CFBundleURLTypes", []),
                 "flutter_deep_linking_enabled": info.get("FlutterDeepLinkingEnabled"),
                 "export_encryption_declaration": info.get("ITSAppUsesNonExemptEncryption"),
                 "frameworks": sorted(p.relative_to(app).as_posix() for p in app.rglob("*.framework")),
                 "review_complete": False}
    payload = (json.dumps(inventory, indent=2, sort_keys=True) + "\n").encode()
    (output / "native-review.json").write_bytes(payload)
    return {"podfile_lock_sha256": hashlib.sha256(lock_bytes).hexdigest(),
            "native_review_sha256": hashlib.sha256(payload).hexdigest()}


def build_signed_archive(sha, build_number, material, environment="live_beta"):
    require(environment in ("live_beta", "staging"), "Unsupported signed build environment.")
    if environment == "staging":
        require(validate_staging_request(os.environ) == (sha, build_number),
                "Staging archive request changed.")
    require(sys.platform == "darwin", "Signing requires a GitHub-hosted macOS runner.")
    require(run(["git", "rev-parse", "HEAD"]).decode().strip() == sha, "Checkout revision mismatch.")
    run(["git", "diff", "--exit-code", "HEAD", "--", "ios", "pubspec.yaml", "pubspec.lock"])
    require(run(["xcodebuild", "-version"]).decode().strip() == "Xcode 26.3\nBuild version 17C529",
            "Expected pinned Xcode 26.3 / 17C529.")
    require(run(["xcrun", "--sdk", "iphoneos", "--show-sdk-version"]).decode().strip() == "26.2",
            "Expected iPhoneOS SDK 26.2.")
    require(json.loads(run(["flutter", "--version", "--machine"]))["frameworkVersion"] == "3.44.6",
            "Expected Flutter 3.44.6.")
    require(run(["pod", "--version"]).decode().strip() == "1.17.0", "Expected CocoaPods 1.17.0.")
    # Flutter's official docs direct export-key verification to this Xcode help.
    help_result = subprocess.run(["xcodebuild", "-help"], capture_output=True, check=False)
    help_text = (help_result.stdout + help_result.stderr).decode()
    for token in (*export_options("", "").keys(), "app-store-connect"):
        require(token in help_text, f"Pinned Xcode does not document export option {token}.")
    ipa_dir = ROOT / "build/ios/ipa"
    archive = ROOT / "build/ios/archive/Runner.xcarchive"
    require(not ipa_dir.exists() and not archive.exists(), "Old archive/export exists; use a fresh runner.")
    project_path = ROOT / "ios/Runner.xcodeproj/project.pbxproj"
    original = project_path.read_bytes()
    installed = None
    keychain_created = False
    with tempfile.TemporaryDirectory(prefix="questwell-signing-", dir=os.environ["RUNNER_TEMP"]) as tmp:
        tmp = Path(tmp)
        p12, password, profile_bytes = material
        (tmp / "certificate.p12").write_bytes(p12)
        (tmp / "profile.mobileprovision").write_bytes(profile_bytes)
        keychain = tmp / "signing.keychain-db"
        keychain_password = secrets.token_hex(32)
        try:
            profile = plistlib.loads(run(["security", "cms", "-D", "-i", tmp / "profile.mobileprovision"]))
            uuid = validate_profile(profile)
            run(["security", "create-keychain", "-p", keychain_password, keychain])
            keychain_created = True
            run(["security", "set-keychain-settings", "-lut", "21600", keychain])
            run(["security", "unlock-keychain", "-p", keychain_password, keychain])
            run(["security", "import", tmp / "certificate.p12", "-P", password,
                 "-A", "-t", "cert", "-f", "pkcs12", "-k", keychain])
            run(["security", "set-key-partition-list", "-S", "apple-tool:,apple:",
                 "-k", keychain_password, keychain])
            # This job only runs on a disposable GitHub-hosted VM.
            run(["security", "list-keychains", "-d", "user", "-s", keychain])
            identity = select_identity(run(["security", "find-identity", "-v", "-p", "codesigning", keychain]).decode(), profile)
            profiles = Path.home() / "Library/Developer/Xcode/UserData/Provisioning Profiles"
            profiles.mkdir(parents=True, exist_ok=True)
            destination = profiles / f"{uuid}.mobileprovision"
            require(not destination.exists(), "Refusing to replace an existing installed profile.")
            destination.write_bytes(profile_bytes)
            installed = destination
            options = tmp / "ExportOptions.plist"
            options.write_bytes(plistlib.dumps(export_options(uuid, identity)))
            print(f"Building signed {environment} archive; upload is disabled.", flush=True)
            run(["flutter", "build", "ios", "--config-only", "--no-codesign",
                 "--release", "--no-pub", "--target", "lib/main.dart",
                 "--build-name=1.0.0", f"--build-number={build_number}",
                 f"--dart-define=QUESTWELL_ENVIRONMENT={environment}",
                 "--dart-define=QUESTWELL_DECORATE_HEARTH=true",
                 f"--dart-define=QUESTWELL_BUILD={sha}"], visible=True)
            project_path.write_text(signed_project(project_path.read_text(), uuid, identity))
            xcode_args = ["xcodebuild", "-workspace", "ios/Runner.xcworkspace", "-scheme", "Runner",
                          "-configuration", "Release", "-sdk", "iphoneos",
                          "-destination", "generic/platform=iOS"]
            effective = json.loads(run([*xcode_args, "-showBuildSettings", "-json"]))
            validate_build_settings(effective, uuid, identity, sha, environment)
            run([*xcode_args, "-archivePath", archive, "archive"], visible=True)
            run(["xcodebuild", "-exportArchive", "-archivePath", archive,
                 "-exportPath", ipa_dir, "-exportOptionsPlist", options], visible=True)
            verify_app(archive / "Products/Applications/Runner.app", build_number, uuid)
            ipas = list(ipa_dir.glob("*.ipa"))
            require(len(ipas) == 1, "Expected one exported IPA; archive-only success is insufficient.")
            # ditto preserves bundle symlinks while expanding the Xcode-generated ZIP.
            expanded = tmp / "exported"
            run(["ditto", "-x", "-k", ipas[0], expanded])
            apps = list((expanded / "Payload").glob("*.app"))
            require(len(apps) == 1, "Exported IPA must contain one application.")
            verify_app(apps[0], build_number, uuid)
            evidence = {"source_sha": sha, "bundle_id": BUNDLE, "team_id": TEAM,
                        "app_store_id": APP_ID, "build_number": build_number,
                        "version": "1.0.0", "environment": environment, "uploaded": False,
                        "xcode": "26.3 / 17C529", "sdk": "26.2", "flutter": "3.44.6",
                        "cocoapods": "1.17.0", "ipa_sha256": hashlib.sha256(ipas[0].read_bytes()).hexdigest(),
                        "certificate_sha1": identity, "profile_uuid": uuid,
                        "github_run_id": os.environ.get("GITHUB_RUN_ID"),
                        "github_run_attempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
                        "native_auth_verified": False, "device_acceptance_verified": False}
            output = ROOT / "build/ios-signing-evidence"
            output.mkdir(parents=True, exist_ok=True)
            evidence.update(collect_review_evidence(apps[0], output))
            (output / "altool-help.txt").write_bytes(run(["xcrun", "altool", "--help"]))
            (output / "validation.json").write_text(json.dumps(evidence, indent=2) + "\n")
        finally:
            project_path.write_bytes(original)
            if installed is not None:
                installed.unlink(missing_ok=True)
            if keychain_created:
                run(["security", "delete-keychain", keychain])
    run(["git", "diff", "--exit-code", "HEAD", "--", "ios/Runner.xcodeproj/project.pbxproj", "pubspec.yaml", "pubspec.lock"])


def main(environment="live_beta"):
    try:
        require(environment in ("live_beta", "staging"), "Unsupported signed build environment.")
        sha, build_number = (validate_staging_request(os.environ) if environment == "staging"
                             else validate_request(os.environ))
        material = credentials(os.environ)
        # Remove secrets before invoking any child process.
        for name in SECRET_NAMES:
            os.environ.pop(name, None)
        build_signed_archive(sha, build_number, material, environment)
    except SigningError as error:
        print(f"iOS signing stopped: {error}", file=sys.stderr)
        return 1
    except (OSError, ValueError, KeyError, plistlib.InvalidFileException):
        print("iOS signing stopped: invalid file/tool output; no credentials logged.", file=sys.stderr)
        return 1
    print("Signed archive and IPA passed local validation. Nothing uploaded to Apple.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

