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

## Typography correction

Founder approved the new layout, with a correction to retain the established typography rules. Questwell wordmark stays unchanged. Section headings use Press Start 2P; subheaders, descriptions, controls and supporting text retain Roboto. Restored pixel headings for class, loadout, collection, weekly momentum, Campfire Mode and the empty-board title. Shared section-heading style and regression assertions protect this hierarchy.

## Final header polish

- Reduced total spacing above/below header navigation by 22 logical pixels; retained 48-pixel tap targets.
- Removed gear count from Hearth portrait badge; class and earned Mastered status remain.
- Integrated the approved Hearth into the home review fixture for full header/scene inspection.
- Read-only persistence review: energy mode writes to the signed-in user's row; avatar body uses the existing set_avatar_body_type RPC. Home loads both values from the profile on startup. This confirms the code paths, not a live authenticated refresh. Real-account persistence remains unverified in the agent's browser.
