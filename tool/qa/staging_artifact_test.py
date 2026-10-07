import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location(
    'stamp_staging', Path(__file__).resolve().parents[1] / 'stamp_staging_artifact.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class StagingArtifactTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.html = ('<html><head><base href="/questwell-app/staging/"></head>'
                     '<body><script data-build="__QUESTWELL_BUILD__">'
                     'load("main.dart.js")</script></body></html>')
        (self.root / 'index.html').write_text(self.html)
        (self.root / 'main.dart.js').write_text(MODULE.PROJECT)

    def test_stamps_revision_environment_and_notice(self):
        MODULE.stamp(self.root, 'a' * 40)
        html = (self.root / 'index.html').read_text()
        manifest = json.loads((self.root / 'questwell-version.json').read_text())
        self.assertIn('STAGING — synthetic test accounts only', html)
        self.assertNotIn('__QUESTWELL_BUILD__', html)
        self.assertIn('main.dart.js?rev=' + 'a' * 40, html)
        self.assertEqual(manifest['environment'], 'staging')
        self.assertEqual(manifest['revision'], 'a' * 40)
        self.assertEqual(manifest['project'], MODULE.PROJECT)
        self.assertEqual(len(manifest['bundle_sha256']), 64)

    def test_invalid_revision_does_not_write(self):
        for revision in ['', 'a' * 7, 'A' * 40, '<script>']:
            with self.assertRaises(ValueError):
                MODULE.stamp(self.root, revision)
        self.assertEqual((self.root / 'index.html').read_text(), self.html)

    def test_wrong_base_does_not_write(self):
        path = self.root / 'index.html'
        bad = self.html.replace('/staging/', '/')
        path.write_text(bad)
        with self.assertRaises(ValueError):
            MODULE.stamp(self.root, 'a' * 40)
        self.assertEqual(path.read_text(), bad)

    def test_live_or_missing_project_rejected(self):
        for bundle in ['', MODULE.LIVE_PROJECT, MODULE.PROJECT + MODULE.LIVE_PROJECT]:
            (self.root / 'main.dart.js').write_text(bundle)
            with self.assertRaises(ValueError):
                MODULE.stamp(self.root, 'a' * 40)

    def test_missing_marker_or_body_rejected(self):
        for html in [self.html.replace('__QUESTWELL_BUILD__', ''),
                     self.html.replace('<body>', '')]:
            (self.root / 'index.html').write_text(html)
            with self.assertRaises(ValueError):
                MODULE.stamp(self.root, 'a' * 40)

    def test_duplicate_stamp_rejected(self):
        MODULE.stamp(self.root, 'a' * 40)
        with self.assertRaises(ValueError):
            MODULE.stamp(self.root, 'a' * 40)


if __name__ == '__main__':
    unittest.main()
