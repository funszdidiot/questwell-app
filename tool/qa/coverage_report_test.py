import sys
from pathlib import Path
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import critical_coverage as coverage

FIXTURE = '''SF:lib/a.dart
DA:1,2
DA:2,0
LF:2
LH:1
BRDA:1,0,0,2
BRDA:1,0,1,-
BRF:2
BRH:1
end_of_record
'''


class CoverageReportTest(unittest.TestCase):
    def test_exact_line_branch_denominators_and_missing_coordinates(self):
        result = coverage.report(coverage.parse_lcov(FIXTURE), {'Rewards': ['lib/a.dart']})
        group = result['groups']['Rewards']
        self.assertEqual(group['lines'], {'covered': 1, 'total': 2, 'percent': 50.0})
        self.assertEqual(group['branches'], {'covered': 1, 'total': 2, 'percent': 50.0})
        self.assertEqual(group['files']['lib/a.dart']['uncovered_lines'], [2])
        self.assertEqual(group['files']['lib/a.dart']['uncovered_branches'], [[1, 0, 1]])
        self.assertIn('not a release-pass threshold', coverage.markdown(result))

    def test_repeated_records_merge_without_inflating_denominator(self):
        second = FIXTURE.replace('DA:1,2', 'DA:1,0').replace('DA:2,0', 'DA:2,5').replace('BRDA:1,0,0,2', 'BRDA:1,0,0,0').replace('BRDA:1,0,1,-', 'BRDA:1,0,1,3')
        group = coverage.report(coverage.parse_lcov(FIXTURE + second), {'Rewards': ['lib/a.dart']})['groups']['Rewards']
        self.assertEqual(group['lines'], {'covered': 2, 'total': 2, 'percent': 100.0})
        self.assertEqual(group['branches']['total'], 2)
        self.assertEqual(group['branches']['covered'], 2)

    def test_pinned_flutter_dialect_requires_explicit_mode_and_rejects_partial_totals(self):
        raw = FIXTURE.replace('BRF:2\n', '').replace('BRH:1\n', '')
        with self.assertRaisesRegex(ValueError, 'Missing LCOV'):
            coverage.parse_lcov(raw)
        result = coverage.report(coverage.parse_lcov(raw, flutter_lcov=True), {'Rewards': ['lib/a.dart']})
        self.assertEqual(result['groups']['Rewards']['branches']['percent'], 50.0)
        for field in ('BRF:2\n', 'BRH:1\n'):
            with self.subTest(field=field), self.assertRaisesRegex(ValueError, 'Missing LCOV'):
                coverage.parse_lcov(FIXTURE.replace(field, ''), flutter_lcov=True)

    def test_separate_group_totals(self):
        other = FIXTURE.replace('lib/a.dart', 'lib/b.dart').replace('DA:2,0', 'DA:2,1').replace('LH:1', 'LH:2')
        result = coverage.report(coverage.parse_lcov(FIXTURE + other), {'Rewards': ['lib/a.dart'], 'Purchases': ['lib/b.dart']})
        self.assertEqual(result['groups']['Rewards']['lines']['percent'], 50.0)
        self.assertEqual(result['groups']['Purchases']['lines']['percent'], 100.0)

    def test_missing_or_duplicate_scope_fails(self):
        for groups in ({'X': ['lib/missing.dart']}, {'X': ['lib/a.dart', 'lib/a.dart']}, {}, {'X': []}):
            with self.subTest(groups=groups), self.assertRaises(ValueError):
                coverage.report(coverage.parse_lcov(FIXTURE), groups)

    def test_absent_branch_instrumentation_fails(self):
        plain = '\n'.join(l for l in FIXTURE.splitlines() if not l.startswith('BR'))
        with self.assertRaisesRegex(ValueError, 'No branch data'):
            coverage.report(coverage.parse_lcov(plain), {'X': ['lib/a.dart']})

    def test_partial_or_invalid_records_fail(self):
        broken = ['', FIXTURE.replace('end_of_record', ''), FIXTURE.replace('LF:2', 'LF:3'),
                  FIXTURE.replace('BRH:1', 'BRH:2'), FIXTURE.replace('LH:1\n', ''),
                  FIXTURE.replace('BRF:2\n', ''), FIXTURE.replace('BRH:1\n', ''),
                  FIXTURE.replace('BRF:2\n', '').replace('BRH:1\n', ''),
                  FIXTURE.replace('DA:2,0', 'DA:1,0'), FIXTURE.replace('DA:2,0', 'DA:2,-1'),
                  FIXTURE.replace('SF:lib/a.dart', 'SF:../a.dart'),
                  FIXTURE.replace('SF:lib/a.dart', 'SF:/lib/a.dart'),
                  FIXTURE.replace('LF:2', 'mystery:2'), FIXTURE.replace('BRDA:1,0,0,2', 'BRDA:1,0,0'),
                  'DA:1,1\n' + FIXTURE]
        for text in broken:
            with self.subTest(text=text), self.assertRaises(ValueError):
                coverage.parse_lcov(text)


if __name__ == '__main__':
    unittest.main()
