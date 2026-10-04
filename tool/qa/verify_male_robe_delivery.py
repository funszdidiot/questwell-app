"""Verify the delivered revision and all active male robe files without writes."""
import argparse
import concurrent.futures
import datetime
import hashlib
import json
from pathlib import Path
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument('revision')
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
base = 'https://funszdidiot.github.io/questwell-app/'


def fetch(url):
    with urllib.request.urlopen(url, timeout=40) as response:
        return response.read()


version = json.loads(fetch(base + 'questwell-version.json?rev=' + args.revision))
if version['revision'] != args.revision:
    raise ValueError(f'Expected {args.revision}; delivered {version["revision"]}')
reference = json.loads((root / 'tool/male_robe_edge_repair_reference.json').read_text())
entries = [reference[k] for k in ['body', 'identity', 'outfit']]
for garment in reference['classes'].values():
    entries.extend(garment[k] for k in ['front', 'rear', 'collar', 'cuffs'])


def verify(entry):
    path = entry['path']
    # Scout collar/cuffs reference their historical source copies. The runtime
    # bundles the byte-identical files under assets/images/questwell/avatar.
    if path.startswith('tool/art_assets/male_robe_v3/'):
        path = 'assets/images/questwell/avatar/classes/scout/' + Path(path).name
    url = base + 'assets/' + path + '?rev=' + args.revision
    data = fetch(url)
    digest = hashlib.sha256(data).hexdigest()
    expected = hashlib.sha256((root / path).read_bytes()).hexdigest()
    if digest != expected or digest != entry['sha256']:
        raise ValueError(f'Delivered asset differs: {path}')
    return {'path': path, 'sha256': digest, 'bytes': len(data), 'matches': True}


with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
    assets = list(pool.map(verify, entries))
print(json.dumps({
    'revision': args.revision,
    'verifiedAtUTC': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'assetVerification': 'PASS', 'assetsMatched': len(assets), 'assets': assets,
}, indent=2))
