# C03 — Retry-safe boss creation

## Scope and contract

A lost response to the old creation RPC can produce a second boss on retry.
PR #26 blocked repeat transport after uncertainty, but could not reconcile it.
This change adds public.create_boss_once(request UUID, expected account UUID,
title, ordered steps, boss type), returning the server-generated boss UUID.
Its private definer validates the owner, live session and deletion fence. A
private RLS-enabled receipt serializes matching owner/request pairs. Its hash
binds the original payload; conflicting reuse fails. Receipt, boss and steps
commit together. The existing creation function retains validation, all eight
level gates and the approved 25 XP / 50 coin reward. Old clients remain compatible
but do not gain durable retry protection. No reward or availability change.

Receipts retain only account/request identifiers, SHA-256 payload hash and boss
ID. They outlive a deleted boss to prevent resurrection, and cascade with Auth
account deletion. No client or service-role table access is granted. A private
provisional ID is replaced with the created boss ID before transaction commit;
any creation/step failure rolls everything back.

Each creation form captures one UUID at opening and passes it on every retry,
even after a background board read acknowledges the boss. The session-local
recovery helper retains request IDs through failed transports,
coalesces concurrent calls, permits a fresh transport after timeout using the
same identity, and keeps confirmed success until the list observes
that exact boss. The form locks its draft during submission/uncertainty and offers
safe retry or a board check. The owner captured at form open is checked before
submission and after the response; the server independently checks expected owner.
Request IDs are not persisted after closing the form or process restart. After
closing an uncertain form or restarting, users must
check their board before recreating an unconfirmed draft; no durable offline-draft
claim is made. A reopened form is a new intentional request; the existing board-refresh guard
remains before reopening after an uncertain outcome. This does not prove a late
write absent, so the exit copy directs users to check their battles.

## Verification

Tests authored before implementation:
- Historical accepted-write/lost-response baseline requires two bosses and records
  the failed one-boss assertion before the new migration is installed.
- Ten real Auth/REST groups: discarded response, eight simultaneous requests,
  intentional duplicate with a new identity, payload mismatch, completed replay,
  deleted replay, account/anonymous isolation, revocation/deletion fence, invalid
  inputs/level gate, and old-client reward compatibility.
- Injected boss and second-step failures must leave no boss, steps or receipt.
- SQL checks: RLS, denied receipt/table access and function grants.
- Recovery tests: pending timeout, retry after rejected transport, empty response,
  separate account identities and observed-boss acknowledgement.
- Widget tests: double taps, immutable uncertain retry, owner switch, dismissal,
  validation and late responses. Existing boss form regressions remain in scope.

Local isolation/catalog checks passed: 19. App/repository Node checks, asset
verification and formatting results are recorded in the handoff. Full Flutter,
backend integration, web build and AI review are pending. Automatic approval
review initially blocked publication to the existing public GitHub repository.
Tanya explicitly approved publishing this C03 source and migration proposal on
October 5, 2026 at 22:35 America/New_York. Full CI and AI review remain required
before the standing development-merge approval can be used. The backend only runs on an approved
GitHub-hosted disposable runner using synthetic data. Local Docker or hosted
Supabase execution is not authorized by this change. Existing asset/dependency
checks and the complete configured Flutter regression suite remain required.

## Rollout and rollback

This is a source/development proposal. Install reviewed hosted migrations and RPC
before any connected updated client; missing RPC fails closed. G3 still gates
hosted rollout and migration-history reconciliation. Roll back the client first
while retaining receipts and the additive RPC. Do not drop receipts or restore
unsafe reward grants. No historical duplicate cleanup, Auth configuration change,
production promotion, keys, paid services or locked artwork changes.

## Route to GO

The authoritative release plan remains FIX_PLAN.md. Development merge is not
release acceptance. Outstanding gate categories:
1. Finish applicable correctness/reliability fixes (including C04 final boss-step
   concurrency, C05 startup recovery, list completeness and domain validation).
2. Establish explicit client environment selection; reconcile hosted migration
   prerequisites and prepare a concrete reviewed rollout/rollback proposal. R01–R03
   and C01–C03 are not declared active in hosted accounts by their source merges.
3. Verify diagnostics, privacy/support, CI protections and a real recovery drill.
4. Produce selected-platform release artifacts: private Android signing, native
   identity/link/privacy attestations and physical-device acceptance.
5. Execute all ten release-critical flows on the actual candidate, including
   account switches, offline/retry, upgrade and large-text cases. Complete release
   checklist with evidence and obtain the release decision. No P0 waiver.

Current decision: NO-GO. Native developer accounts alone do not verify signing,
devices or distribution. This document does not authorize sensitive live rollout.

## Verified API/tool inputs

Existing lockfile retained: Supabase Flutter 2.9.0, Supabase Dart 2.7.0,
PostgREST Dart 2.4.2, uuid 4.6.0. CLI 2.119.0 `migration new --help` verified;
CLI generated the migration filename. Formatter: Dart 3.13.5. RPC signature
verified against https://supabase.com/docs/reference/dart/rpc and UUID API at
https://pub.dev/documentation/uuid/4.6.0/uuid/Uuid/v4.html.
PostgreSQL INSERT conflict semantics: https://www.postgresql.org/docs/17/sql-insert.html.
Supabase changelog checked 2026-10-06. The September 25 PostgreSQL advisory concerns
ltree/legacy PGP ciphers/float GiST/custom operators; none is introduced here.
It does not substitute for a hosted upgrade or restore assessment.
