"""Source identity guard; does not establish signing or device acceptance."""

import copy
from pathlib import Path
import plistlib
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
BUNDLE_ID = "com.alreyva.questwell"
TEAM_ID = "W5779VXQYR"
CONFIGS = {
    "Debug": "97C147061CF9000F007C117D",
    "Profile": "249021D4217E4FDB00AE95B9",
    "Release": "97C147071CF9000F007C117D",
}


def object_body(project, identifier):
    # Xcode's checked-in object layout; fail closed if it changes.
    matches = re.findall(
        rf"^\t\t{identifier}(?: /\*[^\n]*\*/)? = \{{\n(.*?)^\t\t\}};",
        project, re.MULTILINE | re.DOTALL,
    )
    if len(matches) != 1:
        raise ValueError(f"Expected one Xcode object: {identifier}")
    return matches[0]


def validate_identity(project, info):
    target = object_body(project, "97C146ED1CF9000F007C117D")
    if "buildConfigurationList = 97C147051CF9000F007C117D " not in target:
        raise ValueError("Runner configuration list changed; review identity guard")
    config_list = object_body(project, "97C147051CF9000F007C117D")
    listed = re.findall(r"^\s*([A-F0-9]{24}) /\*.*\*/,\s*$", config_list, re.MULTILINE)
    if sorted(listed) != sorted(CONFIGS.values()):
        raise ValueError("Runner configurations changed; review all identities")
    for name, identifier in CONFIGS.items():
        body = object_body(project, identifier)
        for key, expected in {
            "name": name,
            "PRODUCT_BUNDLE_IDENTIFIER": BUNDLE_ID,
            "DEVELOPMENT_TEAM": TEAM_ID,
            "INFOPLIST_FILE": "Runner/Info.plist",
        }.items():
            values = re.findall(rf"^\s*{key} = ([^;]+);$", body, re.MULTILINE)
            if values != [expected]:
                raise ValueError(f"{name}: expected {key} = {expected}")
    for key, expected in {
        "CFBundleDisplayName": "Questwell",
        "CFBundleName": "Questwell",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
        "CFBundleShortVersionString": "$(FLUTTER_BUILD_NAME)",
        "CFBundleVersion": "$(FLUTTER_BUILD_NUMBER)",
        # Preserve the current auth contract until its separately reviewed phase.
        "FlutterDeepLinkingEnabled": True,
        "CFBundleURLTypes": [{
            "CFBundleTypeRole": "Editor",
            "CFBundleURLName": "projectmomentum.com",
            "CFBundleURLSchemes": ["projectmomentum"],
        }],
    }.items():
        if info.get(key) != expected:
            raise ValueError(f"Unexpected Info.plist {key}")


class IOSIdentityTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.project = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
        cls.info = plistlib.loads((ROOT / "ios/Runner/Info.plist").read_bytes())

    def test_registered_source_identity(self):
        validate_identity(self.project, self.info)

    def test_rejects_identity_drift_in_each_configuration(self):
        for name, identifier in CONFIGS.items():
            body = object_body(self.project, identifier)
            for original in (BUNDLE_ID, TEAM_ID):
                with self.subTest(configuration=name, setting=original):
                    changed = self.project.replace(body, body.replace(original, "wrong"))
                    with self.assertRaises(ValueError):
                        validate_identity(changed, self.info)

    def test_rejects_missing_team(self):
        changed = self.project.replace(f"DEVELOPMENT_TEAM = {TEAM_ID};", "")
        with self.assertRaises(ValueError):
            validate_identity(changed, self.info)

    def test_rejects_unchecked_configuration(self):
        changed = self.project.replace(
            "buildConfigurationList = 97C147051CF9000F007C117D ",
            "buildConfigurationList = 97C146E91CF9000F007C117D ",
        )
        with self.assertRaises(ValueError):
            validate_identity(changed, self.info)

    def test_rejects_plist_drift(self):
        for key in self.info:
            if key in {"CFBundleDisplayName", "CFBundleName", "CFBundleIdentifier",
                       "CFBundleShortVersionString", "CFBundleVersion",
                       "FlutterDeepLinkingEnabled", "CFBundleURLTypes"}:
                with self.subTest(key=key):
                    changed = copy.deepcopy(self.info)
                    changed[key] = "wrong"
                    with self.assertRaises(ValueError):
                        validate_identity(self.project, changed)


if __name__ == "__main__":
    unittest.main(verbosity=2)
