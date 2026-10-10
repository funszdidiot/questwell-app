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
