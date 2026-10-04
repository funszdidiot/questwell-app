# Neutral robe v11 — approved and locked class template

Tanya marked both cuff-to-wrist borders because the trim did not look sharp or complete. Inspection of the original generated cloth confirmed that a complete dark lower bevel already existed; the cavity mask cut through that bevel and assigned it behind the wrist.

V11 moves that depth boundary 1.6 source pixels lower along the same curved opening. It retains the existing illustrated finishing edge as foreground cloth. No new art is generated, painted or sharpened. Registration, outer cuff width and the source texture remain fixed. Only source rim pixels untouched by the later v10 join repair are adopted, preserving the completed inner folds and their rear backing.

`node tool/export_neutral_robe_v11.cjs` reproduces the change from the retained v8 source and v10 layers. It recovers 196 rim pixels and changes 191 native composite pixels, all within the cuff-edge regions. No palm pixels or pixels outside those regions change. Main robe front and collar files are byte-identical to v10; the body, identity and approved everyday clothes remain byte-identical to their locks.

Independent review of the actual native and enlarged light/dark composites passed; exact findings are recorded in `visual_review.json`. The QA record reflects its original pre-approval review time. Tanya subsequently approved v11 on 2026-10-03 (America/New_York): “Better. So, now lock this as the robe template for all robes for neutral avatar. You will build all the other class robes now”.

`tool/neutral_robe_fit_reference.json` now locks the exact four v11 files and alpha hashes. Their 240 × 320 registration, silhouette, drape, collar, complete cuff openings/rims and inner joins, hand clearance, rear-panel depth and layer order must be preserved for every neutral class robe. Scout is the approved surface; Alchemist, Scholar, Guardian and Wanderer surface variants are authorized using only colors, patterns and flourishes. The body v4, identity and everyday v3 assets remain immutable.

The v11 fitting review did not itself change runtime integration or remote deployment. Tanya subsequently instructed “and start pushing to the app”, explicitly authorizing development app integration and push for the neutral robe work. Integration status is recorded separately in `PROJECT_STATUS.md`. No merge to `flutterflow`, production launch or Market/account writes are authorized.
