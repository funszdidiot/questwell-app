#!/usr/bin/env python3
"""Package the separate, compiled staging app; never reuse the live bundle."""
import json
import os
from pathlib import Path
import re
import shutil
from stamp_staging_artifact import stamp


def package(root, revision):
    if not re.fullmatch(r'[a-f0-9]{40}', revision):
        raise ValueError('Expected a full build revision')
    source = root / 'build/staging'
    target = root / 'build/web/staging'
    html = (source / 'index.html').read_text()
    if '<base href="/questwell-app/staging/">' not in html:
        raise ValueError('Staging base path was not compiled correctly')
    if not (source / 'main.dart.js').is_file() or target.exists():
        raise ValueError('Missing staging bundle or unexpected target')
    stamp(source, revision)
    html = (source / 'index.html').read_text()
    html = html.replace('manifest.json', f'manifest.json?rev={revision}')
    html = html.replace('__QUESTWELL_BUILD__', revision)
    html = html.replace('<title> Questwell </title>', '<title>Questwell Staging</title>')
    html = html.replace('content="Questwell"', 'content="Questwell Staging"')
    if '__QUESTWELL_BUILD__' in html:
        raise ValueError('Unresolved staging build token')
    (source / 'index.html').write_text(html)
    manifest_path = source / 'manifest.json'
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    manifest.update(name='Questwell Staging', short_name='QW Staging',
                    start_url='./', scope='./', display='standalone')
    manifest_path.write_text(json.dumps(manifest))
    shutil.copytree(source, target)


if __name__ == '__main__':
    package(Path(__file__).resolve().parents[1], os.environ['GITHUB_SHA'])
