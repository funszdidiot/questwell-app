"""Verify delivered garment bytes and fixed foundations; UI QA is separate."""
import argparse
import concurrent.futures
import hashlib
import json
from pathlib import Path
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
BASE = 'https://funszdidiot.github.io/questwell-app/'


def fetch(path, revision):
    with urllib.request.urlopen(BASE + path + '?rev=' + revision, timeout=30) as response:
        return response.read()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('revision')
    parser.add_argument('--output', default='tool/qa/legacy_depth_delivery.json')
    args = parser.parse_args()
    version = json.loads(fetch('questwell-version.json', args.revision))
    assert version['revision'] == args.revision, version
    manifest = json.loads((ROOT / 'tool/art_assets/legacy_depth_v1/exports.json').read_text())
    paths = [asset['path'] for fit in manifest['records'] for asset in fit['runtime'].values()]
    for body, version in [('female', 'v1'), ('male', 'v3'), ('neutral', 'v4')]:
        paths += [f'assets/images/questwell/avatar/base/paper_doll_{body}_{version}.webp',
                  f'assets/images/questwell/avatar/base/paper_doll_{body}_identity_{version}.webp']
    paths += ['assets/images/questwell/avatar/everyday_outfit_male_v2.webp']
    paths += [f'assets/images/questwell/avatar/scout_{part}_female_v6.webp' for part in ['boots', 'trousers', 'top']]
    paths += [f'assets/images/questwell/avatar/everyday_{part}_neutral_v3.webp' for part in ['boots', 'trousers', 'top']]

    def check(path):
        expected = hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
        actual = hashlib.sha256(fetch('assets/' + path, args.revision)).hexdigest()
        assert actual == expected, path
        return {'path': path, 'sha256': actual, 'matched': True}

    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        assets = list(pool.map(check, paths))
    report = {'revision': args.revision, 'status': 'PASS', 'asset_count': len(assets),
              'assets': assets, 'scope': 'Delivered bytes only; see QA record for actual UI verification.'}
    (ROOT / args.output).write_text(json.dumps(report, indent=2) + '\n')
    print(f'PASS: version and {len(assets)} delivered garment/body/identity/Everyday hashes')


if __name__ == '__main__':
    main()
