# Home screen lower sections

Development-only cleanup requested September 29, 2026.

- Removed repeated board scenes and duplicate quest action.
- One parchment empty state with one Add quest action.
- Consistent navigation cards; single column on narrow screens or larger text.
- Existing quest queries, completion, campfire selection and route callbacks retained.
- Review fixture: `?review=home`.
- Founder confirmed sign-in, sign-out and signing back in on their device.
- Founder approved the lower-section cleanup ("Much better!"). No merge or launch.

## Campfire atmosphere

- Campfire Mode enables slow, warm square embers behind home content.
- Replaces the separate campfire landscape banner.
- Paint-only animation, no home rebuilds or queries per frame; ignores input.
- Off mode stops animation and removes embers. Reduced-motion preference shows a still atmosphere.
- Interactive review: `?review=home` with Campfire Mode toggle.
- Existing energy-mode persistence remains unchanged.

## Character overview and controls

- Founder approved campfire embers ("I love it").
- Header now includes visible Quests, Chronicle, Adventurer labels below the wordmark.
- Compact level/XP/coin overview and remaining XP to the next level.
- Loadout displays all equipped names with a Customize adventurer route.
- Expandable class collection lists all shop items for the active class, with names and explicit ownership/equipment states. Market link provided.
- Momentum summary emphasizes weekly wins; Campfire control shares a compact panel style.
- Data sources, XP formula, energy persistence, and approved Hearth/avatars retained.
- Review fixture uses sample profile/item data, not an account. Actual account navigation and persistence still require user verification.
