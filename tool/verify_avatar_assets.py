"""Verify frozen bases and fitted Scholar assets without modifying them."""
import hashlib
import json
from pathlib import Path


def verify(root: Path) -> None:
    manifest = json.loads((root / 'tool/avatar_assets.json').read_text())
    for entry in manifest.get('locked_fit_inputs', []):
        data = (root / entry['path']).read_bytes()
        if hashlib.sha256(data).hexdigest() != entry['sha256']:
            raise ValueError(f'{entry["path"]}: differs from founder-approved Scholar fit')
        print(f'Verified locked Scholar fit: {entry["path"]}')
    for entry in manifest['assets']:
        path = root / entry['path']
        data = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != entry['sha256']:
            raise ValueError(f'{entry["path"]}: differs from reviewed asset manifest')
        if data[:4] != b'RIFF' or data[8:12] != b'WEBP':
            raise ValueError(f'{entry["path"]}: expected WebP')
        if data[12:16] == b'VP8X':
            width = int.from_bytes(data[24:27], 'little') + 1
            height = int.from_bytes(data[27:30], 'little') + 1
            alpha = bool(data[20] & 0x10)
        elif data[12:16] == b'VP8L' and data[20] == 0x2f:
            bits = int.from_bytes(data[21:25], 'little')
            width = (bits & 0x3fff) + 1
            height = ((bits >> 14) & 0x3fff) + 1
            alpha = bool((bits >> 28) & 1)
        else:
            raise ValueError(f'{entry["path"]}: unsupported WebP header')
        if (width, height) != (240, 320):
            raise ValueError(f'{entry["path"]}: expected 240 x 320, got {width} x {height}')
        if not alpha:
            raise ValueError(f'{entry["path"]}: transparency is required')
        print(f'Verified {path.name}: 240 x 320, alpha, SHA-256 matched')


if __name__ == '__main__':
    verify(Path(__file__).resolve().parents[1])
