"""Exercise real SDK failures in disposable projects, plus fail-closed parsing."""
import contextlib
import hashlib
import io
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import quality_gate as gate


class QualityGateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.dart = os.environ.get('DART', 'dart')
        self.baseline = {'diagnostics': [], 'unformatted_sha256': {}}
        self.source = self.root / 'main.dart'
        (self.root / 'pubspec.yaml').write_text("name: quality_probe\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n")
        self.output = io.StringIO()
        self.stack = contextlib.ExitStack()
        self.addCleanup(self.stack.close)
        self.stack.enter_context(contextlib.redirect_stdout(self.output))
        self.stack.enter_context(contextlib.redirect_stderr(self.output))

    def analyze(self, source):
        self.source.write_text(source)
        return gate.run([self.dart, 'analyze', '--format', 'machine', '--fatal-infos'], self.root)

    def format(self, source):
        self.source.write_text(source)
        return gate.run([self.dart, 'format', '--output=none', '--set-exit-if-changed', 'main.dart'], self.root)

    def remember(self, result):
        self.baseline['diagnostics'] = [list(k) + [v] for k, v in gate.diagnostics(result.stdout, self.root).items()]

    def test_clean_analyzer_passes(self):
        gate.check_analysis(self.analyze('void main() {}\n'), self.baseline, self.root)

    def test_real_warning_rejected_even_if_total_budget_exists_elsewhere(self):
        result = self.analyze("import 'dart:math';\nvoid main() {}\n")
        self.remember(result)
        self.assertEqual(result.returncode, 2)
        gate.check_analysis(result, self.baseline, self.root)
        self.baseline['diagnostics'][0][3] = 'other.dart'
        with self.assertRaisesRegex(ValueError, 'new/error'):
            gate.check_analysis(result, self.baseline, self.root)

    def test_real_info_rejected(self):
        (self.root / "analysis_options.yaml").write_text("linter:\n  rules:\n    - valid_regexps\n")
        result = self.analyze("void main() { RegExp('['); }\n")
        self.assertEqual(result.returncode, 1)
        with self.assertRaisesRegex(ValueError, 'new/error'):
            gate.check_analysis(result, self.baseline, self.root)

    def test_correctness_policy_rejects_real_lint_fixtures(self):
        (self.root / 'analysis_options.yaml').write_bytes((gate.ROOT / 'analysis_options.yaml').read_bytes())
        cases = {
            'VALID_REGEXPS': "void main() { RegExp('['); }\n",
            'HASH_AND_EQUALS': 'class Bad { @override bool operator ==(Object other) => true; }\n',
            'COLLECTION_METHODS_UNRELATED_TYPE': "void main() { <int>[1].contains('x'); }\n",
            'UNRELATED_TYPE_EQUALITY_CHECKS': "void main() { print(1 == 'x'); }\n",
        }
        for code, source in cases.items():
            with self.subTest(code=code):
                result = self.analyze(source)
                self.assertIn(code, result.stdout)
                with self.assertRaisesRegex(ValueError, 'new/error'):
                    gate.check_analysis(result, self.baseline, self.root)

    def test_real_error_never_baselined(self):
        result = self.analyze('void main() { missing(); }\n')
        self.assertEqual(result.returncode, 3)
        self.remember(result)
        with self.assertRaisesRegex(ValueError, 'Only explicit warning/info'):
            gate.check_analysis(result, self.baseline, self.root)

    def test_resolved_diagnostic_requires_baseline_removal(self):
        self.remember(self.analyze("import 'dart:math';\nvoid main() {}\n"))
        with self.assertRaisesRegex(ValueError, '1 resolved'):
            gate.check_analysis(self.analyze('void main() {}\n'), self.baseline, self.root)

    def test_location_shift_is_not_new_debt(self):
        self.remember(self.analyze("import 'dart:math';\nvoid main() {}\n"))
        gate.check_analysis(self.analyze("// comment\nimport 'dart:math';\nvoid main() {}\n"), self.baseline, self.root)

    def test_duplicate_count_cannot_grow(self):
        result = self.analyze("import 'dart:math';\nvoid main() {}\n")
        self.remember(result)
        result.stdout += result.stdout
        with self.assertRaisesRegex(ValueError, '1 new/error'):
            gate.check_analysis(result, self.baseline, self.root)

    def test_malformed_or_truncated_output_fails(self):
        for output, code in [('crash\n', 0), ('', 2), ('', -9), ('', 64)]:
            with self.subTest(output=output, code=code), self.assertRaises(ValueError):
                gate.check_analysis(subprocess.CompletedProcess([], code, output), self.baseline, self.root)

    def test_machine_protocol_escapes(self):
        self.assertEqual(gate.fields(r'INFO|HINT|CODE|/tmp/a.dart|1|2|3|pipe\|slash\\line\nend')[-1], 'pipe|slash\\line\nend')
        with self.assertRaises(ValueError):
            gate.fields(r'INFO|HINT|CODE|/tmp/a.dart|1|2|3|bad\q')

    def test_outside_repository_diagnostic_fails(self):
        result = subprocess.CompletedProcess([], 1, 'INFO|HINT|CODE|/outside.dart|1|1|1|message\n')
        with self.assertRaises(ValueError):
            gate.check_analysis(result, self.baseline, self.root)

    def test_real_format_fixture_rejected_without_writing(self):
        source = 'void main( ){print( "hello" );}\n'
        result = self.format(source)
        self.assertEqual(result.returncode, 1)
        with self.assertRaisesRegex(ValueError, 'main.dart'):
            gate.check_format(result, ['main.dart'], self.baseline, self.root)
        self.assertEqual(self.source.read_text(), source)

    def test_legacy_format_allowed_only_at_exact_bytes(self):
        source = 'void main( ){print( "hello" );}\n'
        result = self.format(source)
        self.baseline['unformatted_sha256']['main.dart'] = hashlib.sha256(self.source.read_bytes()).hexdigest()
        gate.check_format(result, ['main.dart'], self.baseline, self.root)
        with self.assertRaisesRegex(ValueError, 'main.dart'):
            gate.check_format(self.format(source + '// edit\n'), ['main.dart'], self.baseline, self.root)

    def test_resolved_format_requires_baseline_removal(self):
        self.baseline['unformatted_sha256']['main.dart'] = 'a' * 64
        with self.assertRaisesRegex(ValueError, 'Remove these resolved'):
            gate.check_format(self.format('void main() {}\n'), ['main.dart'], self.baseline, self.root)

    def test_clean_format_passes(self):
        gate.check_format(self.format('void main() {}\n'), ['main.dart'], self.baseline, self.root)

    def test_syntax_error_cannot_pass_format(self):
        with self.assertRaises(ValueError):
            gate.check_format(self.format('void main( {\n'), ['main.dart'], self.baseline, self.root)

    def test_formatter_missing_duplicate_or_unexpected_output_fails(self):
        for output, code in [('', 0), ('Formatted 0 files (0 changed) in 0.00 seconds.\n', 0),
                             ('Changed main.dart\nChanged main.dart\n', 1),
                             ('unknown output\n', 0), ('Formatted 1 file (0 changed) in 0.00 seconds.\n', 65)]:
            with self.subTest(output=output), self.assertRaises(ValueError):
                gate.format_changes(subprocess.CompletedProcess([], code, output), ['main.dart'])

    def test_deleted_and_symlink_sources_fail(self):
        subprocess.run(['git', 'init', '-q'], cwd=self.root, check=True)
        self.source.write_text('void main() {}\n')
        subprocess.run(['git', 'add', 'main.dart'], cwd=self.root, check=True)
        self.assertEqual(gate.tracked_dart(self.root), ['main.dart'])
        self.source.unlink()
        with self.assertRaises(ValueError):
            gate.tracked_dart(self.root)
        self.source.symlink_to(self.root / 'pubspec.yaml')
        with self.assertRaises(ValueError):
            gate.tracked_dart(self.root)


if __name__ == '__main__':
    unittest.main()
