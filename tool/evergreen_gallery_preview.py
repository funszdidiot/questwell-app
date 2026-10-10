"""Export an offline composition preview; this does not execute Flutter."""
import base64
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets/images/questwell/hearth'
names = {
    'original': 'hearth_environment_v3.webp',
    'hallowed': 'hallowed_hearth_v1.webp',
    'lab': 'mad_alchemists_lab_v1.png',
    'keep': 'guardians_keep_v1.png',
    'macrame': 'hearthwoven_macrame_v1.png',
    'woodland': 'woodland_path_tapestry_v1.png',
    'guardian': 'guardians_oath_tapestry_v1.png',
    'fern': 'fern_study.webp',
    'celestial': 'celestial_study.webp',
}
images = {}
for key, name in names.items():
    mime = 'image/png' if name.endswith('.png') else 'image/webp'
    images[key] = 'data:' + mime + ';base64,' + base64.b64encode((ASSETS / name).read_bytes()).decode('ascii')
template = ROOT / 'docs/releases/evergreen-hearth/gallery-preview.html'
Path(sys.argv[1]).write_text(template.read_text().replace('/* ASSET_DATA */ {}', json.dumps(images)))
