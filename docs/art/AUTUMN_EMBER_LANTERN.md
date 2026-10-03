# Autumn Ember Lantern

Midnight Harvest seasonal room cosmetic, rare, class-neutral, 240 earned coins. Built-in ImageGen source `exec-49d254f7-bdf4-4ed0-867d-a257b7c21c63.png`: front-facing copper lantern with oak-leaf metalwork and amber glass. Detailed 64-bit-style sprite; separate hand-painted 32px Market icon. Runtime WebP quality 92, alpha preserved. Canvas 935×1681; visible alpha>128 bounds (129,37)–(807,1605). Feet anchor at row 1605 on floor depth .72.

Nine oak leaves rise in orbit, alternating behind and in front of the lantern; warm light varies smoothly inside the glass. One six-second AnimationController drives two CustomPainters directly without rebuilding the sprite or avatar. RepaintBoundary isolates painting. Reduced motion and inactive TickerMode stop the clock; app lifecycle pauses it in the background; removal disposes it. Static mode retains the artwork and frozen leaves. No broad-screen effects, timers or additional avatar rebuilds. No physical-device battery benchmark claimed.

Left/right placement uses the shared Hearth renderer, floor shadow and avatar foreground order. Existing purchase/retry/placement/removal APIs and ownership remain unchanged. QA uses rolled-back synthetic users. Catalog staged inactive pending checks; free founder grant stays unequipped. Development only; no merge or launch.

Mobile-scale refinement: leaf silhouettes enlarged to roughly 11–14 px at normal room size, outlined in warm gold, with a 1.55× wider effect canvas to orbit beyond the copper frame. The sprite keeps its original scale; contact shadow width compensates for the wider canvas.

## Release verification

Final release `fcc41b76aeb7b98917e835aafa6d257e7d490c6f`: Flutter Check `37083941211` and Preview `37083941216` succeeded. New animation tests verify changing leaf/light painting, reduced-motion and TickerMode pause, background/resume, and ticker disposal on removal. Shared Market suite covers all 43 items on three bodies. SQL purchase/retry/placement/removal checks passed in rolled-back fixtures; security advisors returned zero findings.

Live `?review=autumn-lantern` review verified larger moving leaves around both placements, floor contact, room/character clearance, and still-mode presentation. Catalog active at 240 earned coins; founder copy verified owned, free and unequipped, balance unchanged at 847. Screenshot: `questwell-autumn-ember-lantern.jpg`. The planned Midnight Harvest collection is delivered; clean avatar bases are the next queued workstream. Founder in-app visual feedback remains welcome; no merge or public launch.

## Founder-requested scale and stand correction

Founder found the original floor lantern too large for the room and requested a smaller lantern on a stand. Built-in ImageGen edited the original into a tabletop-size copper lantern resting on a slim walnut pedestal with copper trim, source `exec-4bd4d1a2-4c07-4f0a-969a-d72effd5442a.png`. Versioned runtime art: `autumn_ember_lantern_stand_v2.webp`, 935×1681, alpha>128 bounds (229,54)–(706,1605).

The whole piece is .52 avatar height instead of .66; the lantern itself occupies approximately 45% of the source object's height, making it about one-third of its former rendered height. Stand floor anchor stays at row 1605; narrower shadow follows its base. Flame/glow center moves to (.50,.30), and rising leaves stay in the upper .06–.45 canvas region around the lamp rather than the pedestal. The 16-bit icon now includes the stand. Existing item identity, price, ownership and equipment are retained. No database change required.

Stand correction release `03b97b19da3573d0d96d03f3a8dd6d94d5e2f799`: Flutter Check `37084634731` and Preview `37084634735` succeeded. Live review confirmed smaller lantern, visible walnut stand, level floor contact, and leaves/glow around the lamp at both left/right placements beside the avatar and Harvest Apothecary Display. Screenshot: `questwell-lantern-on-stand.jpg`. Existing owners receive the updated rendering automatically after refresh; no database or inventory mutation was needed.
