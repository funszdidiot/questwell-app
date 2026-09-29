# Epic 3 — Quest Board development review

Founder authorized work after Hearth visual acceptance on 2026-09-29.
Hearth saved-avatar persistence remains unverified. No promotion or launch.

## Implemented
- Compact board introduction puts everyday quests ahead of decorative artwork.
- Boss content appears in its own lane.
- All quests label reflects the existing open-task query; no invented due dates.
- Pinned quests retain existing per-account local favorite storage.
- Shared cards show effort, XP and coins, readable titles, 48 px pin targets and full-width completion actions.
- Completion feedback displays server-returned rewards after success; failures retain retry feedback.
- Other completion actions disable while a request is active.
- Visit completion count is explicitly session-only, not a daily or lifetime metric.
- Quest-load failure shows retry instead of an endless spinner.
- Account-free sample review: `?review=quests`; uses the same heading/card widgets.

## Review gates
- Automated narrow card/large-text and sample completion tests.
- Live preview inspection and founder iPhone review.
- Signed-in task completion/rewards, pinned persistence and boss navigation still require account-level verification.
- Existing query is capped at 50 open quests; pagination is not implemented in this visual pass.
- No new task scheduling, priority schema, or reward backend changes.

## Pinned-paper revision

Founder requested restoring the illustrated noticeboard feel. Shared live/review cards now use opaque parchment, folded corners, subtle paper shadows, drawn brass/steel pin controls, and a wooden plank backdrop. Existing completion and favorite behavior is preserved. Gold pins mark priorities.
