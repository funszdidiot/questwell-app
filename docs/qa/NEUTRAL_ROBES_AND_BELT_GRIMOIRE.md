# Development app verification — 2026-10-03 America/New_York

Build `9a392250d588799e49cc72a005036202767b62ee` deployed successfully through Questwell Preview run `37167441982`. The published Git tree exactly matches the locally verified tree `9000534322290a80565a6a983f485ef504303d72`.

Live browser review confirmed:

- `?review=neutral-robes` displays Scout, Scholar, Alchemist, Guardian and Wanderer with matching body, registration, silhouette and complete cuffs.
- `?review=grimoire&body=neutral` displays the book on its belt loop, clear of both unchanged hands. Equip/remove/restore controls work in the sample review.
- Female and male selection also show the belt-mounted book with full visible hands. The review is a sample try-on with no account, equipment or currency mutation.
- No application errors were observed during these checks. Browser extension metadata errors were unrelated to the app.

Screenshots: `questwell-neutral-robes-live-9a39225.jpg` and `questwell-grimoire-belt-live-9a39225.jpg` in this directory.

The first Flutter Check run (`37167441975`) passed asset verification, eight JavaScript tests and analysis, then passed 323 Flutter tests with one timeout in the new Market retirement test. The test now uses the same disabled-animation wrapper as the existing Market suite; its item visibility, zero-write and unchanged-ownership assertions remain intact. The subsequent development CI run verifies this test-only correction.

Remote publication uses the existing `funszdidiot/questwell-app` repository's `questwell-dev` branch. Prior user authorization for that exact avatar-preview destination was recovered and its ownership verified through the connected GitHub account. The GitHub connector published the exact file tree because shell Git has no credential helper in this workspace. No production branch merge or account/database mutation occurred.
