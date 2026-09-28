# Questwell Avatar Art Push Checklist

## Objective
Promote the upgraded high-detail modular Adventurer art into the live Questwell experience without breaking equip/unequip behavior or Safari/web rendering.

## Visual target
- High-detail 64-bit-era fantasy RPG presentation
- Adventurer must visually belong in the Hearth environment
- No baked-in secondary character in Hearth
- Base character and cosmetics must remain modular
- Dark round glasses are the default glasses treatment
- Emerald scarf and leather satchel remain independently equipable
- No gray/opaque placeholder rectangles
- Same character state must render consistently across Hearth, Adventurer/Inventory, and Market previews

## 1. Asset structure

Create/update these assets:

### Base
- `assets/avatars/base/adventurer_base.png`

### Wearable slots
- `assets/avatars/slots/head/`
- `assets/avatars/slots/face/glasses_round_dark.png`
- `assets/avatars/slots/neck/scarf_emerald.png`
- `assets/avatars/slots/chest/`
- `assets/avatars/slots/hands/`
- `assets/avatars/slots/legs/`
- `assets/avatars/slots/feet/`
- `assets/avatars/slots/back/satchel_leather.png`

### Future modular slots
- `assets/avatars/slots/familiar/`
- `assets/avatars/slots/room/`
- `assets/avatars/slots/effects/`

### Market previews
- `assets/market/previews/`

## 2. Base Adventurer integration

Replace the temporary/fallback avatar rendering path with the upgraded base Adventurer art.

Primary integration points:
- `lib/widgets/questwell_pixel_art.dart`
- `lib/pages/home_page/home_page_widget.dart`
- `lib/pages/adventurer_page/adventurer_page_widget.dart`

Requirements:
- Preserve current archetype/profile state
- Maintain correct mobile scaling
- Keep character anchored consistently in Hearth and Adventurer/Profile
- Do not flatten accessories into the base image
- Base asset must have transparent background

## 3. Modular equipment layers

Use the existing equipment categories:
- head
- face
- neck
- chest
- hands
- legs
- feet
- back
- familiar
- room
- effect

Current priority overlays:
- Face: Round Scholar Glasses — dark charcoal / near-black
- Neck: Emerald Scholar Scarf
- Back: Leather Satchel

Requirements:
- Each slot toggles independently
- Unequipping removes only that item
- Multiple compatible slots render simultaneously
- Layer order must prevent clipping and overlap errors
- Legacy accessory/outfit data remains supported until all cosmetics are migrated

Recommended visual layer order:
1. back
2. base body
3. legs
4. feet
5. chest
6. neck
7. hands
8. face
9. head
10. effect
11. familiar where scene placement requires foreground rendering

## 4. Hearth integration

Target:
- Character-free Hearth background
- Live equipped Adventurer is the only primary character
- Avatar placement must feel native to the room composition

Validate:
- character scale
- floor contact / grounding
- lighting direction
- shadow placement
- visual hierarchy
- no competing focal character
- no gray image canvases
- no opaque sprite backgrounds

## 5. Adventurer / Inventory integration

Use the same live avatar stack as Hearth.

Requirements:
- Preview current equipped loadout
- Tapping equip/unequip immediately updates avatar preview
- Slot labels remain:
  - HEAD
  - FACE
  - NECK
  - CHEST
  - HANDS
  - LEGS
  - FEET
  - BACK
  - FAMILIAR
  - ROOM
  - EFFECT

No separate fake preview character should be used.

## 6. Market integration

Market item cards must show the same cosmetic artwork used by the avatar.

Priority previews:
- Round Scholar Glasses
- Emerald Scholar Scarf
- Leather Satchel

Requirements:
- Preview art is visually representative of equipped result
- Locked state overlays do not destroy item readability
- No placeholder block art for upgraded cosmetics once real art exists

## 7. Safari / web rendering gate

Before promotion:
- iPhone Safari
- desktop Safari
- Chrome
- Flutter web preview

Confirm:
- no gray rectangles
- no opaque black/white backgrounds
- no failed image decode state
- no stretched avatar
- no layer misalignment
- no flicker on equip/unequip
- no missing item after refresh

## 8. Technical validation

Required before merge:
- Questwell Flutter Check ✅
- Questwell Preview ✅
- Hearth renders upgraded avatar ✅
- Adventurer/Profile renders same avatar ✅
- glasses equip/unequip ✅
- scarf equip/unequip ✅
- satchel equip/unequip ✅
- multiple items equipped together ✅
- mobile scaling verified ✅

## 9. Promotion sequence

1. Commit upgraded avatar assets to `questwell-dev`
2. Wire assets into modular avatar renderer
3. Update Hearth
4. Update Adventurer/Profile
5. Update Market previews
6. Run Flutter Check
7. Run Questwell Preview
8. Inspect iPhone Safari preview
9. Fix any visual/rendering issue
10. Merge validated commit into `flutterflow`

## 10. Release rule

Passing CI is not visual completion.

Do not mark Hearth or the Adventurer graphics benchmark-complete until:
- the upgraded art is live,
- the modular equipment behaves correctly,
- Safari/web rendering is clean,
- and the result materially matches the founder-approved high-detail 64-bit visual standard.
