# In-app beta feedback

Entry: Explore -> Send feedback. The sheet stays above the current screen;
opening it does not navigate away or end an expedition.

Two required text fields ask what the tester tried to do and what happened.
Categories: Something broke, Hard to understand, An idea, Worked well.
Expected behavior, repeat steps, device/browser detail, and reply email are optional.
The feature label, coarse platform, and compiled build revision are included and
shown before submission. Quest text, full URLs/query strings, passwords, browser
history, and screenshots are not captured automatically.

## Founder review

In the existing Project Momentum Supabase dashboard, open Table Editor and choose
public.beta_feedback ([verified table view](https://supabase.com/dashboard/project/bdzcazkyypopbanbjnud/editor/18018)). Sort created_at descending; filter status = new for unread
reports. Read goal/message first, then optional expected/steps and context fields.
Use the existing project-owner dashboard access to set status to reviewed or
resolved. No admin role or extra permissions are granted to app users.

Reports are private to their submitting account and project administrators.
The database owns created_at and the initial status. Authenticated clients have
only column-limited INSERT and own-row SELECT access, with no UPDATE or DELETE.
Reports cascade on auth-account deletion. The optional reply address is voluntary;
the app does not copy the account email into a report automatically.

## Drafts and retries

- Drafts persist on this device under a key scoped to the account ID. A different
  signed-in account cannot restore the draft through the app.
- Closing the sheet saves the draft; connectivity failure leaves its text intact.
- Sending disables repeat taps and closing. An unchanged retry reuses the request
  UUID, including after reopening. A duplicate response is accepted only after
  an own-row lookup confirms that exact UUID was received.
- Editing after an attempted send generates a new UUID because the old request
  may have reached the server. This represents a revised report.
- Successful delivery clears the draft. Account deletion clears its device copy.
- At most 10 new reports per account per hour; retries with an existing UUID still
  reach duplicate detection. No automatic retry of network writes.
- Visual review routes use a clearly labeled local-only preview and never submit
  reports or require an account.

## Verification

Applied the CLI-created migration 20261002033649_questwell_beta_feedback.sql to
Project Momentum using execute_sql. The SQL source is committed for reproducibility;
it was not registered through a separate remote migration-history operation.

tool/qa/feedback_security_check.sql passed in a rollback-only transaction:
own INSERT/SELECT, cross-account isolation, anonymous denial, duplicate UUID,
client status override denial, blank/oversized validation, client UPDATE/DELETE
denial, hourly limit, and duplicate retry at the limit. Confirmed RLS enabled,
account-deletion cascade, and zero report rows after rollback. Security advisor
returned only the previously recorded leaked-password protection warning.

test/feedback_test.dart covers draft isolation/clearing, failure/reopen/retry,
required fields and duplicate taps, and a 320px enlarged-text form.
Commit 810c911 passed Flutter Check 36962307387 and Preview 36962307357.
The browser sample confirmed required-field validation, close/reopen draft recovery,
and the local-only success state. The final 390px preview form rendered cleanly.
The existing signed-in founder dashboard can open beta_feedback in Table Editor.
A real authenticated submission from the founder's test account remains pending;
no sample preview submission writes a database report.

No external beta invitation, production-branch merge, or launch is authorized.
