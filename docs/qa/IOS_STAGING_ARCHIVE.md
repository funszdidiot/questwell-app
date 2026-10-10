# Staging-only iOS archive preparation

Scope approved by Tanya on October 10, 2026 (America/Chicago): prepare a
staging-only build workflow **for review**. This does not authorize merge,
workflow registration/activation, signing dispatch, Apple upload, tester access,
production exports, auth changes, or production promotion.

## Proposed contract

The dedicated `questwell-ios-staging.yml` has only manual source SHA and build
number inputs. It reuses the protected `ios-testflight` environment and signing
implementation, without modifying the existing live-beta workflow. Both workflows
share a non-canceling concurrency group. Required quality checks run first.

The new entrypoint always selects `staging`; there is no caller-selectable backend
input or environment-variable fallback. Effective Xcode Dart defines must contain
exactly one matching environment, source SHA and decorator flag. The existing
compiled staging profile selects project `hpjzfytwivlpsdhiupyd`; endpoint/key/auth
configuration is unchanged. No privileged database key is introduced.

Before credentials are read, the request must match the repository, development
branch, exact event SHA, dedicated workflow reference and first run attempt.
`IOS_SIGNING_ENABLED=true` is still required. A separate protected-environment
variable `IOS_STAGING_APPROVED_SHA` must equal the reviewed source. It is not set
by this change. Live upload approval cannot authorize a staging archive.

The staging entrypoint rejects Apple upload requests, upload approval and an
Apple API private key. The workflow contains no upload input, Apple API secret,
Apple upload command or delivery module. The existing live-beta uploader also
rejects staging evidence. No protections are weakened or bypassed.

## Output and limits

This is an archive-only preparation path, **not an installable delivery**.
The local App Store-profile IPA and archive are disposable. Only sanitized
validation, native dependency lock, privacy inventory and tool-help evidence are
retained for seven days. The report records `environment: staging` and
`uploaded: false`. Neither the IPA nor signing material is uploaded as an artifact.

The current approved bundle/team identity is reused. A future staging build with
that same identity cannot be assumed to install alongside the live app or have
separate local application storage. No installation or upgrade/downgrade safety
is claimed here. Review that choice explicitly before delivery.

Native authentication returns remain web-oriented and unverified. No auth URL,
policy, deep link, entitlement, profile or Apple resource is changed. Native
privacy/API review, actual archive review, distribution approval and physical
device acceptance remain separate requirements. An unsigned compile does not
prove signing, runtime endpoint routing or native export save/cancel recovery.

## Verification and next gates

Credential-free tests cover exact staging approval, trusted workflow/branch,
reruns, absent or crossed upload approval, duplicate/wrong Dart defines, the
unchanged live-beta default, staging evidence rejection by the live uploader,
and synthetic archive/export plus cleanup on failure for both profiles.
The shared PR checks run these tests and compile staging iOS without signing.
Actual CI results and independent review belong in the PR evidence.

After review, merge needs its own authorization. Initial manual registration on
the default branch needs a separately reviewed fail-closed stub; do not promote
the app or change the default branch. Before any archive dispatch, verify current
environment protections, exact-source checks/reviews, Apple account requirements
and unused build number, then obtain the specific staging archive approval and
set only its exact SHA gate. None of these operations is performed by this PR.

After an approved real archive, review native dependencies, privacy/API usage,
authentication and backend isolation before proposing any delivery route. Device
export testing must include save/cancel, force quit during picker, relaunch,
preservation of the user's saved copy and sandbox inspection of owned cache data.

Rollback: clear the staging approval variable if later configured, and revert
this increment through review. Preserve live-beta configuration and credentials.
