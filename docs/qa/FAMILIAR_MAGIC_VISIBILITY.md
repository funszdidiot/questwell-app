# Familiar magic visibility

Tanya reported invisible pet effects and approved the proposed visibility fix
on October 9, 2026 (America/New_York).

Cause: normal animation painted no accent outside a 1–1.13-second action window
in each approximately ten-second loop. Small low-opacity marks were easy to miss.

Both pets now retain ambient magic from the first frame. Larger golden sparkles
and a lavender crescent/silver motes stay in sprite margins; the existing action
window boosts opacity. The existing animation clock and fixed artwork are reused.
Reduced-motion presentation is static, with a seamless ambient loop otherwise.

Validation: Dart formatting and git diff whitespace checks passed locally.
Flutter pixel tests require visible alpha throughout the loop, seamless endpoints,
unchanged face clearance and deterministic reduced motion. Existing widget tests
cover pause, removal and compact bounds. Review captures cover all three bodies,
light/dark backgrounds, normal/enlarged size and still/ordinary idle phases.
Flutter execution, image inspection and delivered-runtime verification pending.

Scope: client presentation only; no database/API/schema/RLS, catalog, purchase,
price or ownership changes. Backend tests remain part of repository CI.
Rollback: revert this scoped PR; no data rollback needed.
