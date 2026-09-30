# Adventurer back navigation — 2026-09-30

Founder reported the top back arrow did nothing in the signed-in Adventurer
screen. Its callback used Navigator.maybePop, which cannot leave a root route
after direct entry or a browser refresh.

Changed the callback to the existing router-aware context.safePop helper. It
pops an available route, otherwise goes to `/`, where the existing app router
selects the Hearth for signed-in users. Authentication behavior is unchanged.

Added tests that tap the real Adventurer view's back button with a minimal
GoRouter in both direct-entry and pushed-route configurations. These tests use
sample data and do not access or change accounts.

Scope: development preview only; no merge to flutterflow and no launch.
