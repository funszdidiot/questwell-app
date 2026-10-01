# Cosmetic effects pass

Victory Sparkle: two staggered golden four-point star flourishes with tiny drifting flecks, fading into a quiet interval in a six-second cycle. Focus Tonic: slow sage-green bubbles with highlights and occasional small gold glints. Both stay beside the avatar silhouette, leaving face and clothing readable. Existing 16-bit Market/Inventory icons and all catalog restrictions/prices remain unchanged. Cosmetic-only; no gameplay advantage or inventory grants.

Implementation is native Canvas animation in `lib/widgets/questwell_cosmetic_effect.dart`, shared through the production equipment renderer in Adventurer and Hearth. The AnimationController drives CustomPainter repaint directly inside a RepaintBoundary, with no per-frame widget rebuild. Reduced motion supplies a stable visible frame. Inactive TickerMode stops the clock; unequip disposes it. No generated raster assets needed for these existing code-native effects.

Review route: `?review=effects`, offering both effects, all three bodies, try-on/unequip, motion toggle and Hearth view. Tests cover phase changes, face clearance, sparkle rest interval, stable reduced-motion pixels, paused ticker and unequip cleanup. Founder visual review pending. Development preview only.
