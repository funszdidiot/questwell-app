# Beta audio — October 9, 2026

Status: QA — PR #111; hosted checks in progress.
Tanya requested all four soundscapes now for beta feedback.
Development implementation is authorized; production promotion is excluded.

## Contract

- Hearth: Hearthlight, plus separately controlled fireplace ambience.
- Market: Little Wonders Market. Expedition: Quiet Trail, plus woodland ambience.
- Boss Battles: A Little Courage. Other destinations are quiet; Account uses
  Hearth for auditioning controls. Auth and unknown routes are always quiet.
- Music and ambience start disabled, with independent volume and enable settings.
  Preferences are local to this installation, not a cloud/account promise.
- Each new app session requires a sound gesture even with preferences saved.
- One controller owns two channels. Serialize changes and invalidate outdated
  loads; page rebuilds and battle attacks do not restart a track.
- Pause when the app leaves the foreground. No background execution/permission.
- No schema, reward, inventory, auth, timer or economy contract changes.
  RLS and Edge Function additions are therefore not applicable.
- Audio assets are bundled, not remotely streamed or dependent on expiring links.
- Generation provenance and hashes accompany assets. Generated music is a beta
  candidate; generation is not a human listening or seamless-loop certification.

## Planned files

`assets/audios/*_v1.mp3`, `lib/services/questwell_audio*.dart`,
`lib/widgets/questwell_audio*.dart`, `lib/main.dart`,
`lib/widgets/questwell_app_navigation.dart`,
`lib/widgets/questwell_account_settings.dart`, `lib/main_preview.dart`,
`lib/preview/audio_review.dart`, `pubspec.yaml`, `pubspec.lock`, audio tests,
this record and the production dashboard.

## Verification gates

Controller tests: defaults, persistence, routing, stale loads, rapid navigation,
mute, lifecycle, load/save failures and disposal. Widget checks: accessibility,
small-screen controls and entry points. Build/analyzer and repository CI remain
required. Actual Safari/iPhone playback, other-app audio coexistence, full-track
listening and loop seams must be reported separately from unit tests.

Rollback: revert the single feature PR; disable both controls for immediate
silence. No backend rollback or data deletion is needed.

## Current evidence and blockers

- All four generated tracks and both generated ambience files were downloaded.
  Quiet-level normalization and end-to-start blends produce six versioned MP3
  candidates; the asset manifest records task IDs, SHA256, duration, target
  loudness, peak level and processing limitations. All decode without clipping.
- Draft implementation: shared audio owner, route changes, independent controls
  in Explore and Account, lifecycle pausing, local preference persistence,
  explicit session activation, account-free `?review=audio` listening room.
- Initial hosted candidate run `37970399846`: 12 tests passed; the large-text
  widget test needed scrolling before tapping its offscreen switch. Corrected.
  Added regression coverage for volume/ambience changes preserving track position.
- Hosted dependency resolution supplied the reviewed lock. Main package stays
  exactly `audioplayers: 6.5.1`; locked web adapter `5.3.0` includes GainNode
  volume control and Safari AudioContext reuse. No other package was upgraded.
- Automatic approval review rejected local Flutter execution because it accessed
  a cloud metadata endpoint with credential risk. Hosted CI is used instead.
- Tanya explicitly authorized feature publication and requested Settings toggle
  and volume. PR #111 supersedes the earlier publication authorization blocker.
- Full required CI, delivered runtime and physical-device checks remain pending.
  Initial checks alone do not establish a build or listening pass.
- Remaining beta acceptance: Safari/iPhone first-start and interruptions, own-music
  coexistence, full-track musical fit and loop seams. Playback failures surface a
  retry control; no audible autoplay occurs from saved preferences alone.

## Sources checked

- https://pub.dev/packages/audioplayers/versions/6.5.1
- Published archives `audioplayers-6.5.1` and
  `audioplayers_platform_interface-7.1.1`: player and context APIs.
- Existing pins `shared_preferences: 2.5.3`, `go_router: 12.1.3`.
- Installed FFmpeg help for loudness normalization and audio encoding.

- Published `audioplayers_web-5.3.0` source verified GainNode volume and context reuse.
