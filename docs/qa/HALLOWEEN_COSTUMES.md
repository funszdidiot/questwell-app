# Halloween complete outfits — v1

Status: QA. Shared runtime integration prepared; activation waits for client delivery and checks.

Tanya approved the two design studies and requested integrated blouses and masks, then authorized production fitting and development integration. Each costume is one outfit, intended for all classes and female, neutral and male bodies. Tanya subsequently directed pricing and app rollout under the same Halloween collection rules. Both rare, nonpremium outfits cost 180 coins, matching the existing Midnight Harvest Coat, and join midnight-harvest through November 8 Chicago with permanent ownership. Activation is authorized subject to required checks.

Midnight Masquerade includes a smoky-plum gathered blouse under a plum velvet robe and a black/copper bat mask. Pumpkin Court includes a cream blouse with green collar/placket under an orange/green robe and a copper/green leaf mask. Both retain trousers and boots.

## Fit and provenance

`tool/art_assets/halloween_costumes_v1/locked_inputs.json` records 24 immutable inputs. `exports.json` records each generated surface, mask source, runtime asset hash and 22 exact robe-alpha checks. The six individual ImageGen surface sources and approved studies are retained beside these records. The simplified `mask_source_v2.png` files supersede the detailed first mask sources.

Female uses the accepted alchemist v7 fit; neutral uses robe v11; male uses the accepted v3 fit with the separately authorized edge repair. Existing male garment-only occlusion is baked into the underlay. No body is clipped, transformed or changed. Runtime order is rear, full locked body, underlay, front, identity, optional collar, cuffs, mask.

Independent reviewer `/root/halloween_review` passed all six native and enlarged light/dark exports on October 8, 2026 after mask simplification. Eyes remain visible; blouse continuity, boots, hands and rear hems pass. 24 source hashes and 22 robe alpha checks pass. This is preview QA, not a new founder template lock.

## Review and remaining checks

Dedicated route: `?review=halloween-costumes`. Supports complete-outfit and dark-backdrop toggles for all six fits. The universal gallery deliberately rejects layered robes; the release manifest therefore omits single-overlay wearable metadata. `exports.json` is the layered asset preflight record.

Tests cover all 34 runtime assets decoding at 240×320 and preservation of all six bodies through equip/unequip and backdrop changes at 320px and 1200px. CI execution and served-render verification are pending. No local Flutter setup was attempted after the earlier automatic approval rejection. A pre-existing standalone Dart formatter was used.

Shared runtime and renderer capability support both chest outfits. The exact catalog-only activate.sql adds two rows without altering existing catalog, schema or ownership. It copies the Hallowed Hearth start/end, stops on window drift/closure, and validates idempotent retries. CI tests all class/body purchase/equip/unequip/restoration and post-cutoff owned retries. Live execution and served verification remain pending.
