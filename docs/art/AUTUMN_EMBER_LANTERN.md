# Autumn Ember Lantern

Midnight Harvest seasonal room cosmetic, rare, class-neutral, 240 earned coins. Built-in ImageGen source `exec-49d254f7-bdf4-4ed0-867d-a257b7c21c63.png`: front-facing copper lantern with oak-leaf metalwork and amber glass. Detailed 64-bit-style sprite; separate hand-painted 32px Market icon. Runtime WebP quality 92, alpha preserved. Canvas 935×1681; visible alpha>128 bounds (129,37)–(807,1605). Feet anchor at row 1605 on floor depth .72.

Nine oak leaves rise in orbit, alternating behind and in front of the lantern; warm light varies smoothly inside the glass. One six-second AnimationController drives two CustomPainters directly without rebuilding the sprite or avatar. RepaintBoundary isolates painting. Reduced motion and inactive TickerMode stop the clock; app lifecycle pauses it in the background; removal disposes it. Static mode retains the artwork and frozen leaves. No broad-screen effects, timers or additional avatar rebuilds. No physical-device battery benchmark claimed.

Left/right placement uses the shared Hearth renderer, floor shadow and avatar foreground order. Existing purchase/retry/placement/removal APIs and ownership remain unchanged. QA uses rolled-back synthetic users. Catalog staged inactive pending checks; free founder grant stays unequipped. Development only; no merge or launch.

Mobile-scale refinement: leaf silhouettes enlarged to roughly 11–14 px at normal room size, outlined in warm gold, with a 1.55× wider effect canvas to orbit beyond the copper frame. The sprite keeps its original scale; contact shadow width compensates for the wider canvas.

## Release verification

Final release `fcc41b76aeb7b98917e835aafa6d257e7d490c6f`: Flutter Check `37083941211` and Preview `37083941216` succeeded. New animation tests verify changing leaf/light painting, reduced-motion and TickerMode pause, background/resume, and ticker disposal on removal. Shared Market suite covers all 43 items on three bodies. SQL purchase/retry/placement/removal checks passed in rolled-back fixtures; security advisors returned zero findings.

Live `?review=autumn-lantern` review verified larger moving leaves around both placements, floor contact, room/character clearance, and still-mode presentation. Catalog active at 240 earned coins; founder copy verified owned, free and unequipped, balance unchanged at 847. Screenshot: `questwell-autumn-ember-lantern.jpg`. The planned Midnight Harvest collection is delivered; clean avatar bases are the next queued workstream. Founder in-app visual feedback remains welcome; no merge or public launch.
