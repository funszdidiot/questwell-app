# Staging application

Candidate; hosted acceptance and recovery are not yet passed.

The existing Pages artifact includes two independently compiled bundles. Root
remains live_beta; /questwell-app/staging/ targets only the founder-created
hpjzfytwivlpsdhiupyd project. Both compile in PR CI. Public signup stays disabled;
only existing synthetic accounts may be used. No live data is copied.

The staging build uses hash routes so navigation reloads stay at the staging
entry point. Build/path mismatches fail before backend initialization. A STAGING
banner and distinct document/install name identify the target. Monitoring uses
the staging environment. Root application settings and prices are unchanged.

SharedPreferences 2.5.3 setPrefix runs before any preferences/Supabase instance;
all staging preferences use flutter.questwell.staging. Existing live preferences
retain their prior keys. Supabase Flutter 2.9.0 additionally keys sessions by
project reference (verified in its published source). The two bundles still
share a browser origin; this is backend and storage namespace separation, not a
security origin boundary. Do not deploy untrusted code to either path.

The pinned Supabase SDK consumes implicit Auth callbacks during initialize but
does not remove their fragments. Staging's hash strategy withholds navigation
and exposes only '/' until consumption finishes; non-route fragments and unsafe
callback query text are then removed before router creation. Recovery intent is
captured using the existing safe flags. Exact redirect allowlist configuration
and real email/recovery tests remain separate requirements.

Required hosted checks: both version manifests/bundles; staging startup and label;
root unchanged; hash reload/back/forward; two-account sign-in/session persistence;
RLS/API isolation; account deletion confined to disposable staging users; Auth
callback/recovery delivery; legacy root service-worker behavior. Existing old
root workers may cover subpaths; do not claim that scenario passed based on a
fresh browser. Same-origin staging is unsuitable for unreviewed builds.

Rollback: revert the staging app PR and rebuild Pages. This removes the staging
bundle; no database reset, account deletion, auth change or DNS edit is involved.
