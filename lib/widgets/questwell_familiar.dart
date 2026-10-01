import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Equipped artwork is separate from the compact, 16-bit inventory icons.
class QuestwellFamiliarLayer extends StatelessWidget {
  const QuestwellFamiliarLayer({super.key, required this.slug});
  final String slug;
  static const names = <String, String>{
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
    return IgnorePointer(child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final left = (constraints.maxWidth - 240 * scale) / 2;
      final top = constraints.maxHeight - 320 * scale;
      final width = dragon ? 72.0 : hovering ? 57.0 : 56.0;
      final height = dragon ? 80.0 : hovering ? 54.0 : slug == 'glass-slime' ? 43.0 : 67.0;
      final x = dragon ? 164.0 : 178.0;
      final bottom = hovering ? 151.0 : 307.0;
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
          scaleY: 1 + wave * (slime ? -.04 : .018), child: child));
    }));
}
