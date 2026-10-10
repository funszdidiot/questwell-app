# B2 destination connection check

Tanya created private encrypted bucket `questwell-backups-20261009` and saved
`B2_KEY_ID` / `B2_APPLICATION_KEY` in the `questwell-backups` GitHub environment.
Both exact secret names were verified in GitHub on 2026-10-10 UTC. Values were
not read. Her subsequent Next continues the proposed small upload/download test.

The dedicated branch workflow uses only these B2 credentials. It validates a
single-bucket and `questwell/` prefix restriction, writes one newly named tiny
synthetic JSON object, checks encryption and upload metadata, downloads the
returned file ID, and requires byte equality. Reports contain only synthetic
object metadata. No provider tokens, source data or raw provider errors are logged.
Redirects and unexpected endpoint domains are rejected. There are no destructive
operations, source-system credentials, package installations or schedules.
The tiny object is retained for evidence; repeated runs use distinct names.

Run locally without credentials:

```sh
python3 -m unittest discover -s tool/backups -p 'test_b2_connection_check.py' -v
```

A passing round trip verifies the backup destination only. Automatic source
backup remains gated on authorized source object access, complete listing and
consistency handling, retention/cost configuration, and a verified scheduled run.
Full account/database/file recovery and release GO remain separate.

API reference: https://www.backblaze.com/apidocs/b2-authorize-account
and the linked get-upload-url, upload-file and download-file-by-id operations.

## Execution result — 2026-10-10 02:06 UTC

- Seven local tests and the same seven GitHub runner tests passed.
- Initial run 38015666561 failed HTTP 401. Diagnostic revision
  b98aa2fa34feed538d3c9501bc153cfc4db6c0d6, run 38015718496,
  job 114105391361, confirms rejection at `b2_authorize_account`, before
  requesting an upload URL or writing an object.
- Secret names exist and both values are nonempty, but B2 rejected the saved
  credential pair. Their correctness, expiry and revoked status cannot be
  inferred from GitHub secret-name presence. No secret values were retrieved.
- Founder action: edit the two GitHub environment secrets using the keyID and
  applicationKey from the same saved Backblaze application-key pair. Do not
  substitute the bucket ID, key name, account login or S3 endpoint. Do not share
  values in chat. Rerun the connection job after correction.
- No object was uploaded by the diagnostic run. Destination verification and
  scheduled source backup remain blocked; no GO is claimed.

## Credential correction and round trip PASSED — 2026-10-10 02:17 UTC

Tanya requested a retry after the credential correction instructions. Run
38015718496, retry job 114107451875, completed successfully. The seven runner
tests passed and the real B2 round trip passed at 02:17:04 UTC.

- Saved credential authentication and single-bucket/questwell-prefix checks passed.
- Uploaded and downloaded 104 synthetic bytes; exact byte equality passed.
- Encryption confirmed: SSE-B2 AES256.
- Object retained: questwell/connection-checks/edb7763e35124e598f3e3f03c1ac1d85.json.
- SHA256: ea0f823c6b6dd78f2ff535dfc572cfb54ea23e10b3a7d6513c5cdfc08ca32915.

This supersedes the credential blocker above. No secret values were read.
The backup destination is verified; scheduled source backup and complete
application recovery remain unverified. No production data was transferred.
