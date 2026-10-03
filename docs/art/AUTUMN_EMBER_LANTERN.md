# Autumn Ember Lantern

Midnight Harvest seasonal room cosmetic, rare, class-neutral, 240 earned coins. Built-in ImageGen source `exec-49d254f7-bdf4-4ed0-867d-a257b7c21c63.png`: front-facing copper lantern with oak-leaf metalwork and amber glass. Detailed 64-bit-style sprite; separate hand-painted 32px Market icon. Runtime WebP quality 92, alpha preserved. Canvas 935×1681; visible alpha>128 bounds (129,37)–(807,1605). Feet anchor at row 1605 on floor depth .72.

Nine oak leaves rise in orbit, alternating behind and in front of the lantern; warm light varies smoothly inside the glass. One six-second AnimationController drives two CustomPainters directly without rebuilding the sprite or avatar. RepaintBoundary isolates painting. Reduced motion and inactive TickerMode stop the clock; app lifecycle pauses it in the background; removal disposes it. Static mode retains the artwork and frozen leaves. No broad-screen effects, timers or additional avatar rebuilds. No physical-device battery benchmark claimed.

Left/right placement uses the shared Hearth renderer, floor shadow and avatar foreground order. Existing purchase/retry/placement/removal APIs and ownership remain unchanged. QA uses rolled-back synthetic users. Catalog staged inactive pending checks; free founder grant stays unequipped. Development only; no merge or launch.
