# Account deletion

Adventurer → Delete account → type DELETE → Permanently delete.

The authenticated delete-account Edge Function verifies the bearer token through Auth, rejects caller-supplied account IDs, revokes all refresh sessions, then hard-deletes only the verified Auth user through the Admin API. The service-role key remains in the Edge Function environment.

Existing foreign-key cascades remove profile, tasks (including set-aside quests), boss battles and steps, cosmetics ownership, reward events, and progression history. The application has no user upload feature; no user-owned Storage objects existed when this was implemented. If uploads are introduced, add Storage API cleanup before Auth deletion. Shared cosmetic assets are retained.

The client clears its local auth session and account-specific pinned-quest preferences only after confirmed success. A failed or timed-out request never claims success; a server timeout may still have completed deletion.

Development preview uses a clearly labeled simulation with no account writes. Do not test by deleting a founder or tester account.

Validation: Node handler authorization/confirmation tests; Flutter confirmation, cancellation, duplicate-click and error tests; isolated disposable-account integration test. Production branch remains unmerged.

Auth deletion bypasses furniture rearrangement in private.return_unsupported_trophy only when the DELETE is executed by supabase_auth_admin. Ordinary inventory updates and removals retain the existing invoker-rights behavior. No new database grants or security-definer privileges were introduced.
