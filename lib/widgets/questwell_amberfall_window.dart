import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'questwell_catalog_equipment.dart';

/// Approved autumn scenery and leaves, clipped to the authored window glass.
class QuestwellAmberfallWindow extends StatefulWidget {
  const QuestwellAmberfallWindow({super.key, this.hallowed = false});
  final bool hallowed;
  static const asset =
      'assets/images/questwell/hearth/amberfall_scenery_candidate_v1.png';

  @override
  State<QuestwellAmberfallWindow> createState() => _AmberfallState();
}

class _AmberfallState extends State<QuestwellAmberfallWindow>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _wind =
      AnimationController(vsync: this, duration: const Duration(seconds: 18));
  bool _foreground = true;
  bool _motionAllowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }

  void _syncMotion() {
    if (_foreground && _motionAllowed) {
      if (!_wind.isAnimating) _wind.repeat();
    } else {
      _wind.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncMotion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motionAllowed = !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    _syncMotion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wind.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: LayoutBuilder(builder: (context, constraints) {
            final size = constraints.biggest;
            final clipper = AmberfallGlassClipper(hallowed: widget.hallowed);
            final bounds = clipper.getClip(size).getBounds();
            return ClipPath(
              clipper: clipper,
              child: Stack(fit: StackFit.expand, children: [
                Positioned.fromRect(
                  rect: bounds,
                  child: RepaintBoundary(
                    child: Image.asset(QuestwellAmberfallWindow.asset,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.none,
                        excludeFromSemantics: true),
                  ),
                ),
                RepaintBoundary(
                  child: CustomPaint(
                    painter:
                        AmberfallLeafPainter(_wind, hallowed: widget.hallowed),
                  ),
                ),
              ]),
            );
          }),
        ),
      );
}

class AmberfallGlassClipper extends CustomClipper<Path> {
  const AmberfallGlassClipper({this.hallowed = false});
  final bool hallowed;

  @override
  Path getClip(Size size) {
    final source = hallowed ? const Size(1536, 1024) : const Size(768, 768);
    final scale =
        math.max(size.width / source.width, size.height / source.height);
    final dx = (size.width - source.width * scale) / 2;
    final dy = (size.height - source.height * scale) * .52;
    return QuestwellRainyWindowOverlay.panesFor(hallowed).transform(
      Float64List.fromList([
        scale,
        0,
        0,
        0,
        0,
        scale,
        0,
        0,
        0,
        0,
        1,
        0,
        dx,
        dy,
        0,
        1,
      ]),
    );
  }

  @override
  bool shouldReclip(covariant AmberfallGlassClipper oldClipper) =>
      oldClipper.hallowed != hallowed;
}

/// Only the leaf layer repaints. The scene and window plate stay cached.
class AmberfallLeafPainter extends CustomPainter {
  AmberfallLeafPainter(this.phase, {this.hallowed = false})
      : super(repaint: phase);
  final Animation<double> phase;
  final bool hallowed;
  static const _leaf = ['..x..', 'x.xxx', 'xxxxx', '.xxx.', '..x..', '..x..'];
  static const _colors = [
    Color(0xFFFFCA60),
    Color(0xFFD96932),
    Color(0xFFAA3F35)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final source = hallowed ? const Size(1536, 1024) : const Size(768, 768);
    final scale =
        math.max(size.width / source.width, size.height / source.height);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - source.width * scale) / 2,
        (size.height - source.height * scale) * .52);
    canvas.scale(scale);
    final glass = QuestwellRainyWindowOverlay.panesFor(hallowed);
    canvas.clipPath(glass);
    final bounds = glass.getBounds();
    final paint = Paint()..isAntiAlias = false;
    final count = hallowed ? 24 : 14;
    // Wrap happens above/below the glass, never in the visible leaf trajectory.
    for (var i = 0; i < count; i++) {
      final near = i.isEven;
      final t = ((phase.value % 1) * (near ? 2 : 1) + i * .137) % 1;
      final angle = 2 * math.pi * (t + i * .11);
      final x = bounds.left +
          bounds.width * ((i * .381966) % 1) +
          math.sin(angle) * (hallowed ? 12 : 5);
      final y = bounds.top - 24 + t * (bounds.height + 48);
      final pixel = near ? 2.5 : 1.5;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.sin(angle) * .7);
      paint.color = _colors[i % _colors.length];
      for (var row = 0; row < _leaf.length; row++) {
        for (var col = 0; col < _leaf[row].length; col++) {
          if (_leaf[row][col] == 'x') {
            canvas.drawRect(
                Rect.fromLTWH(
                    (col - 2) * pixel, (row - 2) * pixel, pixel, pixel),
                paint);
          }
        }
      }
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AmberfallLeafPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.hallowed != hallowed;
}
