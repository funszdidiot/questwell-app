#!/usr/bin/env python3
"""Report measured client line/branch coverage, never infer backend coverage."""
import argparse
import json
from pathlib import Path, PurePosixPath
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def integer(value):
    if not re.fullmatch(r'[0-9]+', value):
        raise ValueError('Invalid nonnegative LCOV integer: ' + value)
    return int(value)


def source_path(value):
    path = PurePosixPath(value)
    if path.is_absolute() or '..' in path.parts or not value.startswith('lib/') or '\\' in value:
        raise ValueError('Expected repository-relative lib/ source: ' + value)
    return path.as_posix()


def parse_lcov(text, *, flutter_lcov=False):
    records = {}
    current = None
    for line in text.splitlines():
        if not line or line.startswith('TN:'):
            continue
        if line.startswith('SF:'):
            if current is not None:
                raise ValueError('Unterminated LCOV record')
            current = {'path': source_path(line[3:]), 'lines': {}, 'branches': {}, 'summary': {}}
        elif line == 'end_of_record':
            if current is None or not current['lines']:
                raise ValueError('Missing or empty source record')
            expected = {'LF': len(current['lines']), 'LH': sum(v > 0 for v in current['lines'].values()),
                        'BRF': len(current['branches']), 'BRH': sum(v > 0 for v in current['branches'].values())}
            for key, value in current['summary'].items():
                if expected[key] != value:
                    raise ValueError('Inconsistent LCOV ' + key)
            required = {'LF', 'LH'}
            branch_totals = {'BRF', 'BRH'} & current['summary'].keys()
            # Dart coverage 1.15.0 emits BRDA but omits BOTH branch totals.
            # Only the explicit pinned-producer mode permits that exact dialect.
            if branch_totals or (current['branches'] and not flutter_lcov):
                required |= {'BRF', 'BRH'}
            if not required.issubset(current['summary']):
                raise ValueError('Missing LCOV line/branch totals')
            record = records.setdefault(current['path'], {'lines': {}, 'branches': {}})
            for kind in ('lines', 'branches'):
                for key, hits in current[kind].items():
                    record[kind][key] = max(record[kind].get(key, 0), hits)
            current = None
        elif current is None:
            raise ValueError('LCOV data outside source record: ' + line)
        elif line.startswith('DA:'):
            parts = line[3:].split(',')
            if len(parts) not in (2, 3):
                raise ValueError('Malformed line coverage')
            number, hits = map(integer, parts[:2])
            if not number or number in current['lines']:
                raise ValueError('Invalid/duplicate source line')
            current['lines'][number] = hits
        elif line.startswith('BRDA:'):
            parts = line[5:].split(',')
            if len(parts) != 4:
                raise ValueError('Malformed branch coverage')
            key = tuple(integer(v) for v in parts[:3])
            hits = 0 if parts[3] == '-' else integer(parts[3])
            if not key[0] or key in current['branches']:
                raise ValueError('Invalid/duplicate branch')
            current['branches'][key] = hits
        elif line.split(':', 1)[0] in {'LF', 'LH', 'BRF', 'BRH'}:
            key, value = line.split(':', 1)
            if key in current['summary']:
                raise ValueError('Duplicate LCOV total')
            current['summary'][key] = integer(value)
        elif line.split(':', 1)[0] in {'FN', 'FNDA', 'FNF', 'FNH'}:
            pass  # Function coverage is not represented as line or branch coverage.
        else:
            raise ValueError('Unsupported LCOV field: ' + line)
    if current is not None or not records:
        raise ValueError('Incomplete or empty LCOV report')
    return records


def metric(hits):
    values = list(hits)
    covered = sum(v > 0 for v in values)
    return {'covered': covered, 'total': len(values),
            'percent': round(100 * covered / len(values), 2) if values else None}


def report(records, groups):
    if not isinstance(groups, dict) or not groups:
        raise ValueError('Empty coverage scope')
    result = {'scope': 'Focused Dart VM critical-client suite only; not full-suite, SQL, Edge, Chrome, native or device coverage', 'groups': {}}
    seen = set()
    for group, paths in groups.items():
        if not isinstance(group, str) or not group or not isinstance(paths, list) or not paths:
            raise ValueError('Invalid coverage group')
        files = {}
        all_lines, all_branches = [], []
        for path in paths:
            path = source_path(path)
            if path in seen or path not in records:
                raise ValueError('Duplicate scope or missing instrumented source: ' + path)
            seen.add(path)
            data = records[path]
            all_lines.extend(data['lines'].values())
            all_branches.extend(data['branches'].values())
            files[path] = {'lines': metric(data['lines'].values()), 'branches': metric(data['branches'].values()),
                           'uncovered_lines': sorted(k for k, v in data['lines'].items() if v == 0),
                           'uncovered_branches': [list(k) for k, v in sorted(data['branches'].items()) if v == 0]}
        result['groups'][group] = {'lines': metric(all_lines), 'branches': metric(all_branches), 'files': files}
    if not any(g['branches']['total'] for g in result['groups'].values()):
        raise ValueError('No branch data; run Flutter with --branch-coverage')
    return result


def display(value):
    return f"{value['covered']}/{value['total']} ({value['percent']:.2f}%)" if value['total'] else 'N/A (no instrumented branches)'


def markdown(data):
    lines = ['# Critical client coverage', '', data['scope'], '',
             '| Area | Lines | Branches |', '| --- | --- | --- |']
    for name, group in data['groups'].items():
        lines.append(f"| {name} | {display(group['lines'])} | {display(group['branches'])} |")
    lines += ['', 'These are measured results, not a release-pass threshold. Missing paths or invalid/incomplete reports fail the reporting step.',
              'Uncovered line and branch coordinates are retained per file in the JSON artifact.', '',
              'Server reward authority and deletion are checked separately by the isolated backend harness; no backend coverage percentage is inferred.', '']
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('lcov', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--flutter-lcov', action='store_true',
                        help='Accept pinned Flutter exporter omission of both BRF/BRH; derive totals from BRDA')
    args = parser.parse_args()
    groups = json.loads((ROOT / 'tool/critical_coverage.json').read_text())
    result = report(parse_lcov(args.lcov.read_text(), flutter_lcov=args.flutter_lcov), groups)
    result['lcov_dialect'] = 'Flutter: branch totals derived from BRDA' if args.flutter_lcov else 'LCOV: branch totals required'
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.with_suffix('.json').write_text(json.dumps(result, indent=2) + '\n')
    rendered = markdown(result)
    args.output.with_suffix('.md').write_text(rendered)
    print(rendered)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError) as error:
        print('COVERAGE REPORT FAILED: ' + str(error), file=sys.stderr)
        sys.exit(1)
