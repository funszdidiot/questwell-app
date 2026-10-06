# Vendored Flutter installer

`setup.sh` is byte-for-byte from subosito/flutter-action revision
`1a449444c387b1966244ae4d4f8c696479add0b2`, retrieved 2026-10-06.
MIT license is retained alongside it. SHA-256: `35f0cd9e9c1d7a643448223573b4a03879e63676fdc27872de3d0104d5bf89f9`.

Source: https://github.com/subosito/flutter-action/blob/1a449444c387b1966244ae4d4f8c696479add0b2/setup.sh

Do not use the upstream composite: its nested mutable action references are
resolved before step conditions. This local wrapper calls the reviewed installer
with exact version and architecture, and invokes only pinned JavaScript cache
actions. Changes to the vendored script require explicit upstream comparison,
license retention, review and Linux/macOS CI. The script still trusts the official
Flutter release manifest and archives; this change does not attest those upstream
SDK downloads or hosted runner images.
