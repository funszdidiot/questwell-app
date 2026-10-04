# Questwell Visual Production Lessons Learned

These are process controls derived from failures encountered during avatar production.

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
