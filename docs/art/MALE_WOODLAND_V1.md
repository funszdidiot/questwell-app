# Male Woodland Scout v1 — development candidate

The male-specific Woodland Scout outfit is one coherent overlay on locked male v3. Tanya's requested avatar sequence and autonomous development mandate authorize this candidate build and development integration. It is not a founder-locked template or an account wardrobe rollout.

The design inherits Woodland's moss waistcoat, brass closures, restrained botanical stitching, rolled ivory sleeves with matching tabs, reinforced brown trousers and folded leather boots. Female Woodland supplies design reference only. All artwork was generated specifically for the male body using the built-in image-generation workflow; no female or neutral clothing pixels are reused.

`tool/male_woodland_fit_reference.json` records the exact body, identity, Everyday, source, registered outfit and export references. `tool/export_male_woodland_v1.cjs` performs one continuous registration of the entire generated outfit. The shared field follows the male legs, covers the locked undergarments, lowers the connected crotch join and clears both hands. It never masks or edits anatomy, splits clothes into components or assembles garment fragments. The runtime order is body → one outfit → original identity on the same 240 × 320 canvas with no fitting transforms.

Initial uniform registration exposed shorts, inner calf and heel pixels. A second generated redraw missed placement and was rejected. Independent QA also caught a buckle touching the left hand and a translucent crotch seam. The final continuous registration resolves those defects. `tool/qa/male_woodland_v1_export_review.json` records independent PASS with native/enlarged light/dark inspection, unchanged body/identity, complete tested coverage and zero changes to both isolated opaque hands. Earlier failures remain explicitly historical QA evidence.

The development route is `?review=male-woodland`. The shared male review switches among Body only, Outfit (approved Everyday), Robe and Woodland, with light/dark and enlarged views. Explicit stage state prevents accidental combinations. The Belt grimoire control uses the existing book-only accessory renderer and its unchanged male belt anchor; it hides on Body only and cannot alter account equipment. Route recreation restores the requested candidate; inspection selections are local and never become account equipment.

Inventory/catalog, class restrictions, equipment policy, ownership, economy and backend persistence are unchanged. Woodland account support remains female Scout only; neutral and male candidates remain unavailable in account equipment. Existing regression gates verify those boundaries. The grimoire remains belt-mounted and Pathfinder boots remain retired.

Development deployment and live runtime evidence are recorded separately in `docs/qa/MALE_WOODLAND_V1_INTEGRATION.md`. Source art, a QA PASS or a successful build does not establish founder approval or complete delivery.
