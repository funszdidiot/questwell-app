# Questwell Visual Production Lessons Learned

These are process controls derived from failures encountered during avatar production.

**Coat wrist continuity — 2026-10-05:** a correctly drawn cuff cavity can still
look disconnected when the original-hand foreground region starts below it.
Inspect the uninterrupted skin contour from inside the opening to the fingers;
reject floating skin tabs, horizontal cutoffs and dark bands across exposed
wrists. Fit the duplicate original-pixel depth boundary to each opening while
retaining the complete underlying body. Native gallery QA missed this defect;
inspect enlarged wrists in the actual Hearth as well.

**Standing founder direction — 2026-10-05:** cloaks, capes, robes and mantles
must fall naturally. Broad triangular flare is not a shortcut for arm/hand
coverage: it makes the avatar appear artificially wide. Preserve shoulder
contact, let cloth hang predominantly downward, use modest hem ease, and check
the silhouette on each complete locked body. Existing locked robe templates
remain immutable unless a scoped revision is explicitly requested. The male
coat correction also establishes that cuff width belongs at the wrist opening,
not as a ballooned elbow; cavity cloth belongs behind the wrist and the finishing
lip in front. Passing coverage tests alone does not establish either fit.

1. **Lock the body before clothing.** Changing anatomy while fitting garments creates cascading drift.
2. **Fit bodies independently.** Female, male and neutral proportions require separate garment registration.
3. **Concept quality does not guarantee production fit.** Always inspect the actual runtime composite.
4. **Cuffs are a high-risk seam.** Detached, incomplete, hand-covering and outward-widened cuffs repeatedly failed review. Preserve the approved inward/wrist-wrap geometry.
5. **Rear panels matter.** Robes need continuous fabric behind the body; trim must not cross exposed legs unnaturally.
6. **Do not hide problems with clipping.** Fix garment geometry; preserve hands and anatomy.
7. **One coherent outfit is safer than independently stretched fragments.** Fragment scaling created seams, bulges and mismatched silhouettes.
8. **Check hips, crotch, inner legs and footwear.** These areas exposed old layers and registration errors.
9. **Runtime policy can invalidate good art.** An asset can exist and render correctly in a review while equipment eligibility still blocks it in the app. Verify the complete path.
10. **A GitHub asset is not a deployment.** Verify the branch, renderer route, inventory/catalog eligibility and actual development preview.
11. **Freeze approved geometry.** Seasonal/class variants should change surface design, not repeatedly reopen fit.
12. **Keep provenance.** Source, prompt/edit method, version, fit reference, verification and approval state should travel with the asset.
13. **Separate technical and aesthetic gates.** CI/Preview can pass while the visual still needs work; conversely active visual work is not automatically a founder blocker.
14. **Design for replaceability.** Layouts and visuals should be modular so future redesigns do not implode core systems.

15. **Verify the same body across states, not just immutable files.** Male Everyday v2 was briefly wired to male v3 while unequip restored legacy anatomy. Both files could pass hash checks while the interaction violated the paper-doll contract. Keep a dedicated fixed-body review until every supported account transition uses the coherent approved foundation.
16. **Review capability is not account capability.** Neutral Woodland is an unaccepted candidate. Its explicit development renderer does not authorize expansion of female-only account eligibility. Approved Everyday support is tracked separately.
17. **Preserve real test view dimensions.** A test-only `MediaQueryData(disableAnimations: true)` override reset the viewport to zero and made a Market modal untappable. Copy the real media data and alter only the intended property; exercise actual visible taps rather than suppressing missed-hit warnings.
18. **Check backing behind translucent hand edges.** The male robe's shared rear mask left tiny page-background holes beside both thumbs despite matching masks and an initial visual PASS. Compare both light/dark backgrounds and inspect connected lining behind the intact hands. Repair the full connected rear region, preserve intentional underarm space and add a regression at the actual defect coordinates.
19. **Register surface motifs continuously.** Row-wise class texture registration created jagged trim seams. Continuous affine RGB registration with bilinear sampling resolved the defect while preserving every approved alpha value.
20. **Check complete garment containment, including the undergarments.** An attractive Woodland source still exposed shorts and strips of calf/heel after uniform registration. Fit the complete connected outfit to its own body, then check the whole covered region and both intact hands. A small buckle can overlap a hand even when the sleeves pass. Preserve one coherent overlay and record actual defect regressions.


### Legacy fits on locked bodies — 2026-10-04 America/Chicago

A historical full-body suit image cannot be made a reliable garment by coarse head/hand cuts: it can leak old anatomy and miss the current feet/inner legs. Use a coherent garment-only overlay registered independently to each locked body. Closed cloaks must cover the full arms with cloth; never restore a historical body-hiding mask. Satchel foreground-arm restoration must stay disabled under closed cloth. A generic head crop can cut the newer neutral jaw even when body hashes pass. Keep the exact complete identity above the collar and fit neck-only foreground contours per body; inspect the actual enlarged renderer. Garment registration can distort embroidered motifs even after coverage passes—review surface shapes again after every contour adjustment.


## Superseding founder correction — 2026-10-05

Tanya rejected the mantle, cloak and coat shapes despite prior technical and visual QA. Replacement status is BUILDING. Each of these three garments needs its own direct fit for each locked body. Cloak and mantle must conceal arms and hands; Harvest Coat must leave hands exposed (confirmed “Yes”). Business Suit was not included in this rejection. No pending founder clarification blocks this work.

Coverage alone is insufficient: broad transforms and corrective warps can create ballooned sleeves, distorted motifs and unnatural drape. Review natural garment construction as well as coverage. Keep complete original bodies byte-for-byte unchanged and visible underneath; never clip anatomy to solve clothing. Historical deployment evidence below/above does not establish visual acceptance of the rejected fits.
