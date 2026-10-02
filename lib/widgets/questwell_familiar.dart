import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Equipped artwork is separate from the compact, 16-bit inventory icons.
class QuestwellFamiliarLayer extends StatelessWidget {
  const QuestwellFamiliarLayer({super.key, required this.slug});
  final String slug;
  static const names = <String, String>{
    'pumpkin-sprite': 'Pumpkin Sprite',
    'emerald-dragon': 'Emerald Dragon',
    'mushroom-familiar': 'Mushroom Familiar',
    'tiny-owl-familiar': 'Tiny Owl',
    'archive-owl': 'Archive Owl',
    'glass-slime': 'Glass Slime',
    'signal-fox': 'Signal Fox',
    'moss-moth': 'Moss Moth',
  };
  static String asset(String slug) =>
      'assets/images/questwell_familiar_${slug}_v1.webp';

  @override
  Widget build(BuildContext context) {
    if (!names.containsKey(slug)) return const SizedBox.shrink();
    final hovering = slug == 'moss-moth';
    final dragon = slug == 'emerald-dragon';
    final pumpkin = slug == 'pumpkin-sprite';
    return IgnorePointer(child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final left = (constraints.maxWidth - 240 * scale) / 2;
      final top = constraints.maxHeight - 320 * scale;
      final width = pumpkin ? 64.0 : dragon ? 72.0 : hovering ? 57.0 : 56.0;
      final height = pumpkin ? 64.0 : dragon ? 80.0 : hovering ? 54.0 : slug == 'glass-slime' ? 43.0 : 67.0;
      final x = pumpkin ? 170.0 : dragon ? 164.0 : 178.0;
      // Pumpkin feet end at 1186/1254 of its transparent canvas.
      final bottom = pumpkin ? 307.0 + 64 * (1 - 1186 / 1254) : hovering ? 151.0 : 307.0;
      return Stack(clipBehavior: Clip.none, children: [
        if (!hovering)
          Positioned(left: left + (x + 5) * scale,
            top: top + 304 * scale, width: (width - 10) * scale, height: 7 * scale,
            child: DecoratedBox(decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const RadialGradient(colors: [Color(0x70201712), Color(0x00201712)],
                radius: .6)))),
        Positioned(left: left + x * scale, top: top + (bottom - height) * scale,
          width: width * scale, height: height * scale,
          child: _FamiliarIdle(key: ValueKey(slug), slug: slug,
            child: Image.asset(asset(slug), fit: BoxFit.contain,
              alignment: Alignment.bottomCenter, filterQuality: FilterQuality.medium,
              semanticLabel: names[slug]))),
      ]);
    }));
  }
}

class _FamiliarIdle extends StatefulWidget {
  const _FamiliarIdle({super.key, required this.slug, required this.child});
  final String slug;
  final Widget child;
  @override
  State<_FamiliarIdle> createState() => _FamiliarIdleState();
}
class _FamiliarIdleState extends State<_FamiliarIdle> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this,
    duration: Duration(milliseconds: widget.slug == 'moss-moth' ? 2600 : 3800));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _clock.stop();
      _clock.value = 0;
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }
  @override
  void dispose() { _clock.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RepaintBoundary(child: AnimatedBuilder(
    animation: _clock, child: widget.child,
    builder: (context, child) {
      final wave = math.sin(_clock.value * math.pi * 2);
      final hover = widget.slug == 'moss-moth';
      final slime = widget.slug == 'glass-slime';
      return Transform.translate(offset: Offset(0, hover ? wave * 3 : 0),
        child: Transform.scale(alignment: Alignment.bottomCenter,
          scaleX: 1 + wave * (hover ? .05 : slime ? .035 : .006),
          scaleY: 1 + wave * (slime ? -.04 : .018),
          child: widget.slug == 'emerald-dragon'
            ? Stack(clipBehavior: Clip.none, fit: StackFit.expand, children: [
                child!,
                IgnorePointer(child: CustomPaint(
                  painter: QuestwellDragonSmokePainter(phase: _clock.value))),
              ])
            : hover
              ? Stack(clipBehavior: Clip.none, fit: StackFit.expand, children: [
                  CustomPaint(painter: QuestwellMothMagicPainter(phase: _clock.value)),
                  child!,
                ])
              : child));
    }));
}

/// Staggered golden wing-dust: drifts outward and falls away as the moth hovers.
/// Uses the familiar's clock, including its reduced-motion and offscreen pause.
class QuestwellMothMagicPainter extends CustomPainter {
  const QuestwellMothMagicPainter({required this.phase});
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 57, size.height / 54);
    final paint = Paint()..isAntiAlias = false;
    for (var i = 0; i < 14; i++) {
      final age = (phase + i / 14) % 1;
      final side = i.isEven ? -1.0 : 1.0;
      final shimmer = math.sin(age * math.pi);
      final opacity = math.pow(shimmer, .7).toDouble() * .95;
      final x = 28.5 + side * (16 + i % 3 * 3 + age * 5) +
          math.sin((age + i * .17) * math.pi * 2) * 3;
      final y = 12 + i % 4 * 7 + age * 24;
      final radius = (i % 4 == 0 ? 1.5 : .85) + shimmer * .4;
      // A restrained amber halo and crisp stepped cores suit the retro artwork.
      paint.color = const Color(0xFFFFBA43).withValues(alpha: opacity * .14);
      canvas.drawCircle(Offset(x, y), radius * 2.6, paint);
      paint.color = const Color(0xFFFFD76A).withValues(alpha: opacity);
      if (i % 3 == 0) {
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y),
          width: radius * 2.8, height: .85), paint);
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y),
          width: .85, height: radius * 2.8), paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y),
          width: radius * 1.4, height: radius * 1.4), paint);
      }
      paint.color = const Color(0xFFFFF3BC).withValues(alpha: opacity);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: .8, height: .8), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant QuestwellMothMagicPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// A brief, three-puff exhale registered to the sprite's visible nostril.
/// Shares the breathing transform so the origin never slides off the nose.
class QuestwellDragonSmokePainter extends CustomPainter {
  const QuestwellDragonSmokePainter({required this.phase});
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 72, size.height / 80);
    final paint = Paint()..isAntiAlias = false;
    for (var i = 0; i < 3; i++) {
      final age = (phase - i * .075) / .59;
      if (age <= 0 || age >= 1) continue;
      final opacity = math.sin(age * math.pi) * .68;
      final x = 18.0 - age * 23;
      final y = 25.2 - age * 18 - math.sin(age * math.pi) * 2;
      final puff = 1.1 + age * 3.6;
      paint.color = const Color(0xFFC5C9BD).withValues(alpha: opacity);
      // Softly shaded clusters retain the stepped edges of the retro artwork.
      canvas.drawRect(Rect.fromLTWH(x-puff, y-puff*.5, puff*2, puff), paint);
      canvas.drawRect(Rect.fromLTWH(x-puff*.55, y-puff, puff*1.1, puff*2), paint);
      paint.color = const Color(0xFFE8E5D7).withValues(alpha: opacity * .55);
      canvas.drawRect(Rect.fromLTWH(x-puff*.55, y-puff*.6, puff, puff*.65), paint);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellDragonSmokePainter oldDelegate) =>
    oldDelegate.phase != phase;
}
