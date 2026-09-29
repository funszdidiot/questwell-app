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
