"""Read-only delivered revision and all ten neutral review asset checks."""
import argparse
import concurrent.futures
import hashlib
import json
from pathlib import Path
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument('revision')
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
site = 'https://funszdidiot.github.io/questwell-app/'
base = 'assets/images/questwell/avatar/'
paths = [base + suffix for suffix in [
    'base/paper_doll_neutral_v4.webp',
    'base/paper_doll_neutral_identity_v4.webp',
    'woodland_scout_unified_neutral_v3.webp',
    'everyday_top_neutral_v3.webp',
    'everyday_trousers_neutral_v3.webp',
    'everyday_boots_neutral_v3.webp',
    'classes/scout/scout_robe_neutral_v1.webp',
    'classes/scout/scout_robe_rear_neutral_v1.webp',
    'classes/scout/scout_robe_cuff_front_neutral_v1.webp',
    'classes/scout/scout_robe_collar_neutral_v1.webp',
]]


def fetch(url):
    with urllib.request.urlopen(url, timeout=40) as response:
        return response.read()


version = json.loads(fetch(site + 'questwell-version.json?rev=' + args.revision))
if version['revision'] != args.revision:
    raise ValueError(f'Wrong delivered version: {version}')


def verify(path):
    data = fetch(site + 'assets/' + path + '?rev=' + args.revision)
    digest = hashlib.sha256(data).hexdigest()
    if digest != hashlib.sha256((root / path).read_bytes()).hexdigest():
        raise ValueError(f'Wrong delivered asset: {path}')
    return {'path': path, 'sha256': digest, 'bytes': len(data)}


with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
    results = list(pool.map(verify, paths))
print(json.dumps({'revision': args.revision, 'result': 'PASS',
                  'assetsMatched': len(results), 'assets': results}, indent=2))
