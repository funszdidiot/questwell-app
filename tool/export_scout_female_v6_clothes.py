"""Separate generated clothes from the immutable female paper-doll reference.

This exporter performs alpha selection and canvas normalization only. It does
not transform, repaint, replace, clip, or warp any body pixels. The source is
the generated try-on artwork, normalized to the shared 240 x 320 canvas at 4x.
Run with --source PATH once to import a generated PNG, then without arguments
to reproduce every runtime garment from the checked-in lossless source.
"""

import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tool/art_assets/scout_female_v6"
OUT = ROOT / "assets/images/questwell/avatar"
SCALE = 4
SIZE = (240 * SCALE, 320 * SCALE)

# Coordinates trace the garment seams in the normalized source. The neckline
# is part of the outline, leaving the complete neck and head transparent.
TOP = [
    (107.2, 79.4), (101.5, 80.1), (95.8, 81.5), (91.2, 83.1),
    (88.2, 86.6), (85.7, 94.7), (82.2, 101.6), (86.4, 103.7),
    (96.7, 107.8), (98.0, 113.9), (100.1, 122.6), (100.5, 127.8),
    (99.8, 130.2), (100.1, 132.7), (103.0, 134.7), (111.3, 135.9),
    (120.0, 136.2), (131.2, 135.8), (137.4, 134.3), (139.2, 132.1),
    (138.3, 129.6), (138.9, 125.9), (140.7, 118.2), (142.3, 108.1),
    (149.3, 105.9), (155.8, 102.9), (154.0, 98.4), (151.3, 87.9),
    (148.7, 84.3), (143.9, 82.0), (134.0, 79.8), (133.1, 81.8),
    (131.4, 84.6), (128.9, 86.5), (125.5, 87.4), (120.3, 87.9),
    (115.7, 87.0), (111.6, 84.6), (109.4, 82.0),
]

# The last ankle segments follow the same line as the first boot segments.
# Keeping boot pixels in a separate export lets footwear be toggled alone.
TROUSERS = [
    (100.1, 133.9), (105.8, 135.3), (119.6, 136.3), (131.3, 135.5),
    (138.9, 133.9), (140.9, 141.2), (144.2, 147.9), (147.7, 154.9),
    (150.0, 165.2), (151.0, 176.2), (152.5, 185.1), (153.7, 202.0),
    (155.6, 213.4), (158.0, 219.1), (158.3, 223.4), (161.8, 231.4),
    (164.0, 239.3), (164.5, 250.6), (165.7, 262.2), (168.1, 267.9),
    (167.3, 272.0), (168.2, 277.0), (169.1, 280.1),
    (165.2, 282.0), (159.5, 283.0), (153.4, 282.9), (147.5, 281.6),
    (147.3, 277.8), (146.0, 272.7), (145.2, 266.2), (142.5, 257.3),
    (140.3, 248.3), (138.9, 238.7), (137.5, 231.9), (134.4, 225.4),
    (133.6, 218.1), (131.5, 210.9), (128.5, 200.7), (125.9, 192.2),
    (123.2, 183.1), (120.3, 174.8), (119.6, 168.9),
    (118.7, 181.4), (117.4, 195.2), (116.5, 210.4), (117.2, 218.0),
    (116.1, 223.1), (114.6, 229.9), (115.5, 233.1), (114.8, 245.0),
    (112.7, 256.3), (111.5, 261.7), (112.3, 267.0), (110.7, 271.0),
    (111.0, 274.3), (111.9, 277.8), (108.8, 279.5), (102.4, 280.5),
    (95.5, 280.2), (92.1, 279.0), (92.7, 275.5), (91.0, 272.6),
    (90.6, 268.3), (91.5, 263.6), (90.6, 251.0), (90.1, 240.2),
    (91.2, 233.1), (93.7, 227.5), (93.1, 220.9), (94.6, 214.5),
    (93.9, 208.2), (91.1, 195.5), (89.1, 182.6), (89.0, 172.1),
    (90.0, 161.8), (92.0, 154.0), (95.1, 145.8), (98.2, 140.1),
]
BOOTS = [
    [(92.1, 279.0), (95.5, 280.2), (102.4, 280.5), (108.8, 279.5),
     (111.9, 277.8), (117.0, 290.0), (116.0, 313.0), (78.0, 313.0),
     (78.0, 299.0), (89.0, 289.0)],
    [(147.5, 281.6), (153.4, 282.9), (159.5, 283.0), (165.2, 282.0),
     (169.1, 280.1), (178.0, 292.0), (191.0, 297.0), (193.0, 313.0),
     (146.0, 313.0), (145.0, 292.0)],
]

# Only these small regions may use the targeted generated coverage repair.
# Transparent pixels remain transparent; the exporter never invents garment
# coverage where image generation left an exposed-underwear gap.
COVERAGE_TOP = [
    (132.8, 79.2), (137.0, 80.3), (138.0, 86.6), (128.4, 88.6),
    (128.0, 86.6), (130.2, 84.6), (131.9, 81.7),
]
COVERAGE_RIGHT_BOOT = [
    (147.5, 281.6), (153.4, 282.9), (159.5, 283.0), (165.2, 282.0),
    (169.1, 280.1), (178.0, 292.0), (191.0, 297.0), (193.0, 313.0),
    (142.0, 313.0), (142.0, 287.0),
]


def selected(source, polygons):
    mask = Image.new("L", SIZE, 0)
    draw = ImageDraw.Draw(mask)
    for polygon in polygons:
        draw.polygon([(round(x * SCALE), round(y * SCALE)) for x, y in polygon], fill=255)
    result = source.copy()
    result.putalpha(ImageChops.multiply(source.getchannel("A"), mask))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path)
    parser.add_argument("--coverage-source", type=Path)
    args = parser.parse_args()
    SOURCE.mkdir(parents=True, exist_ok=True)
    if args.source:
        Image.open(args.source).convert("RGBA").resize(SIZE, Image.Resampling.LANCZOS).save(
            SOURCE / "clothes_source.webp", "WEBP", lossless=True, method=6
        )
    if args.coverage_source:
        Image.open(args.coverage_source).convert("RGBA").resize(SIZE, Image.Resampling.LANCZOS).save(
            SOURCE / "clothes_coverage_source.webp", "WEBP", lossless=True, method=6
        )
    source = Image.open(SOURCE / "clothes_source.webp").convert("RGBA")
    assert source.size == SIZE
    layers = [selected(source, [TOP]), selected(source, [TROUSERS]), selected(source, BOOTS)]
    coverage_file = SOURCE / "clothes_coverage_source.webp"
    if coverage_file.exists():
        coverage = Image.open(coverage_file).convert("RGBA")
        assert coverage.size == SIZE
        layers[0].alpha_composite(selected(coverage, [COVERAGE_TOP]))
        # The generated trouser repair retained the coverage gap, so its
        # changed leg artwork is intentionally not used in this garment.
        # The entire right boot is a single coherent clothing item; preserve
        # the original left boot and substitute only the generated right boot.
        layers[2] = selected(source, [BOOTS[0]])
        layers[2].alpha_composite(selected(coverage, [COVERAGE_RIGHT_BOOT]))
    for name, layer in zip(["top", "trousers", "boots"], layers):
        layer.resize((240, 320), Image.Resampling.LANCZOS).save(
            OUT / f"scout_{name}_female_v6.webp", "WEBP", lossless=True, method=6
        )
    # Composite against the canonical body without changing any underlying
    # pixels. Identity is a fixed foreground split of that same base.
    result = Image.open(OUT / "base/paper_doll_female_v1.webp").convert("RGBA").resize(SIZE, Image.Resampling.LANCZOS)
    for layer in layers:
        result.alpha_composite(layer)
    identity = Image.open(OUT / "base/paper_doll_female_identity_v1.webp").convert("RGBA").resize(SIZE, Image.Resampling.LANCZOS)
    result.alpha_composite(identity)
    result.save(SOURCE / "fixed_dressed_reference.png")
    background = Image.new("RGBA", SIZE, "#dedbd1")
    background.alpha_composite(result)
    background.convert("RGB").save("/tmp/female-v6-everyday-qa.png")
    print("Exported independent top, trousers, and boots; canonical base unchanged.")


if __name__ == "__main__":
    main()
