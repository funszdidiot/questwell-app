# Neutral robe fitting v6 — review candidate

**Rejected and superseded by the v7 fitting candidate:** Tanya identified a disconnected neck and hands. The foundation is now approved as neutral v4 and the everyday fit as v3. V7 corrects the cuff depth-export bug while retaining the intact registered cloth artwork. Do not use the v6 split masks as a template or treat the earlier coverage check as visual acceptance. See `NEUTRAL_ROBE_V7_CANDIDATE.md`.

Continues the 3 October neutral-first paper-doll work. The everyday v2 fitting is retained as a candidate, and the rustic Scout robe now has a body-specific fitting to review before any class geometry is locked. No founder acceptance is inferred from the instruction to continue.

## Artwork and depth

- The complete approved 240 × 320 neutral body and original identity are read-only. Their SHA-256 checks pass; no generated anatomy is used.
- Built-in imagegen repaired the garment source: soft wrist hems replace the circular pipe openings, and the skirt decoration runs continuously. Olive cloth, flax embroidery, brown edging, lower pockets and the open-front silhouette are retained.
- The exporter registers cloth to the collar, shoulders, wrists and hem. Each lower sleeve is fitted separately without shifting the skirt. The shoulders cover the everyday shirt.
- The central rear lining renders behind the entire body. The front robe and attached cuff lips render above it; the dark cuff undersides sit behind the wrists. No ellipse is cut through the foreground cuff, no extra inner flap is drawn, and the body is never clipped.
- The three everyday garments remain separate. Boots render beneath the trouser hems. The robe is shown over the latest everyday candidate, not over the Woodland vest and reinforced trousers.

## Reproduce and inspect

Run `node tool/export_neutral_robe_v6.cjs` using Node and Sharp. The imagegen prompt and source are retained under `tool/art_assets/neutral_robe_v6/`. Everyday candidate dependencies and their source are under `tool/art_assets/neutral_everyday_v2/`.

The exporter produces three full-canvas lossless WebP layers plus:

- `neutral_everyday_and_robe_v6.png`: equal-scale everyday and robe comparison.
- `neutral_robe_review_v6.png` and `neutral_robe_review_v6_light.png`: actual layered full-figure renders.
- `neutral_cuff_detail_v6.png`: enlarged wrist review.
- `verification.json`: body checks, exported asset hashes and stack order.

Native coverage inspection found no uncovered opaque arm pixels in the tested sleeve region. The approved-asset manifest verification passes. The full comparison and wrist detail were visually checked after fixing an initial shoulder reveal and an isolated-sleeve registration discontinuity. These are garment assets and offline renders; no Flutter/runtime changes or live-app validation are included.

## Next review

Tanya reviews the everyday fit and this neutral robe silhouette/cuff fit. Only after acceptance should these depth masks become the neutral template for the other class colors and patterns. Woodland Scout remains in the neutral work sequence; male outfits remain deferred. This candidate does not replace the app wardrobe, change accounts or Market items, merge into `flutterflow`, or authorize a launch.
