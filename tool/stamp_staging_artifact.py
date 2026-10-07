#!/usr/bin/env python3
"""Validate and identify a staging-only web artifact; never deploy it."""
import hashlib
import json
from pathlib import Path
import re
import sys

BASE = '/questwell-app/staging/'
PROJECT = 'hpjzfytwivlpsdhiupyd'
LIVE_PROJECT = 'bdzcazkyypopbanbjnud'


def stamp(root, revision):
    if not re.fullmatch(r'[0-9a-f]{40}', revision):
        raise ValueError('Expected a full lowercase Git revision')
    root = Path(root)
    index = root / 'index.html'
    bundle = root / 'main.dart.js'
    if index.is_symlink() or bundle.is_symlink():
        raise ValueError('Artifact entrypoints cannot be symlinks')
    html = index.read_text()
    javascript = bundle.read_bytes()
    if html.count(f'<base href="{BASE}">') != 1:
        raise ValueError('Incorrect staging base path')
    if html.count('<body>') != 1 or 'data-questwell-staging' in html:
        raise ValueError('Missing body or already stamped artifact')
    if PROJECT.encode() not in javascript or LIVE_PROJECT.encode() in javascript:
        raise ValueError('Bundle must contain staging, never the live project')
    if '__QUESTWELL_BUILD__' not in html:
        raise ValueError('Missing version marker')
    # Fixed copy only: never interpolate account data or callback parameters.
    notice = (
        '<aside data-questwell-staging role="note" '
        'style="position:fixed;z-index:2147483647;top:0;right:0;'
        'background:#fff1a8;color:#231f10;padding:4px 8px;'
        'font:12px system-ui;pointer-events:none">'
        'STAGING — synthetic test accounts only</aside>'
    )
    html = html.replace('__QUESTWELL_BUILD__', revision)
    html = html.replace('main.dart.js', f'main.dart.js?rev={revision}')
    html = html.replace('<body>', '<body>' + notice)
    index.write_text(html)
    (root / 'questwell-version.json').write_text(json.dumps({
        'revision': revision,
        'environment': 'staging',
        'project': PROJECT,
        'base_path': BASE,
        'bundle_sha256': hashlib.sha256(javascript).hexdigest(),
    }) + '\n')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('Usage: stamp_staging_artifact.py BUILD_DIR REVISION')
    stamp(sys.argv[1], sys.argv[2])
    print('Staging-only artifact identified; deployment/acceptance not implied.')
