#!/usr/bin/env python3
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('package_staging', Path(__file__).resolve().parents[1] / 'package_staging.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class PackageTest(unittest.TestCase):
    def fixture(self, root, base='/questwell-app/staging/'):
        source = root / 'build/staging'
        source.mkdir(parents=True)
        (source / 'index.html').write_text(f'<base href="{base}"><title> Questwell </title><script src="main.dart.js"></script>__QUESTWELL_BUILD__')
        (source / 'main.dart.js').write_text('staging compiled app')
        live = root / 'build/web'
        live.mkdir()
        (live / 'main.dart.js').write_text('live compiled app')

    def test_separate_bundle_preserves_live_bytes_and_stamps_staging(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.fixture(root)
            module.package(root, 'a' * 40)
            self.assertEqual((root / 'build/web/main.dart.js').read_text(), 'live compiled app')
            target = root / 'build/web/staging'
            self.assertEqual((target / 'main.dart.js').read_text(), 'staging compiled app')
            self.assertEqual(json.loads((target / 'questwell-version.json').read_text())['environment'], 'staging')
            self.assertNotIn('__QUESTWELL_BUILD__', (target / 'index.html').read_text())
            self.assertIn('Questwell Staging', (target / 'index.html').read_text())
            manifest = json.loads((target / 'manifest.json').read_text())
            self.assertEqual(manifest['start_url'], './')
            self.assertEqual(manifest['scope'], './')
            with self.assertRaises(ValueError):
                module.package(root, 'a' * 40)

    def test_wrong_base_never_packages_a_live_bundle_as_staging(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.fixture(root, '/questwell-app/')
            with self.assertRaises(ValueError):
                module.package(root, 'a' * 40)
            self.assertFalse((root / 'build/web/staging').exists())

if __name__ == '__main__':
    unittest.main()
