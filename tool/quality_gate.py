#!/usr/bin/env python3
"""Fail closed on new Dart diagnostics or formatting debt; never edit source."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BASELINE = ROOT / 'tool/quality_baseline.json'


def run(args, root):
    result = subprocess.run(args, cwd=root, text=True, capture_output=True,
                            timeout=180, check=False)
    if result.stderr:
        print(result.stderr, file=sys.stderr, end='')
    return result


def fields(line):
    """Decode the Dart machine protocol's escaped separators and newlines."""
    parts = ['']
    escaped = False
    for char in line:
        if escaped:
            if char not in {'n', 'r', '\\', '|'}:
                raise ValueError('Unknown machine-output escape')
            parts[-1] += {'n': '\n', 'r': '\r'}.get(char, char)
            escaped = False
        elif char == '\\':
            escaped = True
        elif char == '|':
            parts.append('')
        else:
            parts[-1] += char
    if escaped or len(parts) != 8:
        raise ValueError('Malformed analyzer machine output: ' + line)
    return parts


def diagnostics(output, root):
    result = Counter()
    for line in output.splitlines():
        if not line:
            continue
        severity, kind, code, path, row, column, length, message = fields(line)
        if severity not in {'ERROR', 'WARNING', 'INFO'} or not kind or not code or not message:
            raise ValueError('Invalid diagnostic fields')
        if not all(re.fullmatch(r'[0-9]+', x) for x in (row, column, length)):
            raise ValueError('Invalid diagnostic location')
        relative = Path(path).resolve().relative_to(root.resolve()).as_posix()
        result[(severity, kind, code, relative, message)] += 1
    return result


def expected_diagnostics(baseline):
    result = Counter()
    for entry in baseline['diagnostics']:
        if len(entry) != 6 or entry[0] not in {'WARNING', 'INFO'}:
            raise ValueError('Only explicit warning/info baseline entries are allowed')
        if not all(isinstance(x, str) and x for x in entry[:5]):
            raise ValueError('Invalid diagnostic baseline')
        count = entry[5]
        key = tuple(entry[:5])
        if type(count) is not int or count < 1 or key in result:
            raise ValueError('Invalid or duplicate baseline count')
        result[key] = count
    return result


def check_analysis(result, baseline, root):
    actual = diagnostics(result.stdout, root)
    # With --fatal-infos Dart returns 1 for infos, 2 for warnings, 3 for errors.
    expected_exit = max(({'INFO': 1, 'WARNING': 2, 'ERROR': 3}[x[0]]
                         for x in actual), default=0)
    if result.returncode != expected_exit:
        raise ValueError(f'Analyzer failed or output is incomplete (exit {result.returncode}, expected {expected_exit})')
    expected = expected_diagnostics(baseline)
    for key, count in actual.items():
        print(f'{count} x ' + ' | '.join(key))
    extra, stale = actual - expected, expected - actual
    if extra or stale:
        raise ValueError(f'Analyzer baseline mismatch: {sum(extra.values())} new/error findings, '
                         f'{sum(stale.values())} resolved entries to remove.\n'
                         f'New: {list(extra.items())}\nResolved: {list(stale.items())}')
    print(f'Analyzer: {sum(actual.values())} existing findings remain visible; no new findings.')


def tracked_dart(root):
    result = run(['git', 'ls-files', '-z', '--', '*.dart'], root)
    if result.returncode:
        raise ValueError('Cannot enumerate tracked Dart files')
    files = result.stdout.rstrip('\0').split('\0')
    if not files or files == ['']:
        raise ValueError('No tracked Dart files')
    for name in files:
        path = root / name
        if not path.is_file() or path.is_symlink():
            raise ValueError('Missing or symlinked Dart source: ' + name)
    return files


def format_changes(result, files):
    changed = set()
    summary = None
    for line in result.stdout.splitlines():
        if line.startswith('Changed '):
            name = line[len('Changed '):]
            if name not in files or name in changed or summary is not None:
                raise ValueError('Unexpected formatter file: ' + name)
            changed.add(name)
        else:
            match = re.fullmatch(r'Formatted (\d+) files? \((\d+) changed\) in [0-9.]+ seconds?\.', line)
            if not match or summary is not None:
                raise ValueError('Unexpected formatter output: ' + line)
            summary = tuple(map(int, match.groups()))
    if summary != (len(files), len(changed)) or result.returncode != int(bool(changed)):
        raise ValueError('Formatter failed or did not check every tracked Dart file')
    return changed


def check_format(result, files, baseline, root):
    changed = format_changes(result, files)
    allowed = baseline['unformatted_sha256']
    if not isinstance(allowed, dict) or not all(isinstance(k, str) and isinstance(v, str)
            and re.fullmatch(r'[0-9a-f]{64}', v) for k, v in allowed.items()):
        raise ValueError('Invalid formatting baseline')
    stale = set(allowed) - changed
    debt = [name for name in sorted(changed)
            if hashlib.sha256((root / name).read_bytes()).hexdigest() != allowed.get(name)]
    if debt or stale:
        raise ValueError(f'Format these new/edited files: {debt}\n'
                         f'Remove these resolved/deleted formatting baseline entries: {sorted(stale)}')
    print(f'Format: {len(files)} tracked files checked; {len(changed)} unchanged legacy files remain. '
          'No source was written.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dart', default='dart')
    args = parser.parse_args()
    baseline = json.loads(BASELINE.read_text())
    if baseline['schema'] != 1:
        raise ValueError('Unsupported quality baseline schema')
    version = run([args.dart, '--version'], ROOT)
    if version.returncode or not version.stdout.startswith('Dart SDK version: ' + baseline['dart_version'] + ' '):
        raise ValueError('Use the pinned Flutter/Dart SDK; review baseline changes when upgrading')
    options_hash = hashlib.sha256((ROOT / 'analysis_options.yaml').read_bytes()).hexdigest()
    if options_hash != baseline['analysis_options_sha256']:
        raise ValueError('Analysis policy changed; explicitly review the policy and baseline together')
    check_analysis(run([args.dart, 'analyze', '--format', 'machine', '--fatal-infos'], ROOT), baseline, ROOT)
    files = tracked_dart(ROOT)
    check_format(run([args.dart, 'format', '--output=none', '--set-exit-if-changed', *files], ROOT),
                 files, baseline, ROOT)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError, subprocess.SubprocessError) as error:
        print('QUALITY GATE FAILED: ' + str(error), file=sys.stderr)
        sys.exit(1)
