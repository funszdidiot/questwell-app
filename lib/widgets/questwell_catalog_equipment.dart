import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_cosmetic_effect.dart';

/// New catalog layers use the same authored 240×320 registration as the avatar.
/// Garments are continuous canvas shapes; familiars have a dedicated art layer.
class QuestwellCatalogEquipment extends StatelessWidget {
  const QuestwellCatalogEquipment(
      {super.key,
      required this.equipment,
      required this.body,
      this.rear = false});
  final Map<String, String> equipment;
  final String body;
  final bool rear;
  @override
  Widget build(BuildContext context) {
    final slug = equipment['effect'];
    if (rear || (slug != 'victory-sparkle' && slug != 'focus-tonic')) {
      return const SizedBox.shrink();
    }
    return QuestwellCosmeticEffect(key: ValueKey(slug), slug: slug!);
  }
}

/// The window occupies its own architectural slot; lanterns use floor spots.
class QuestwellCatalogRoomArt extends StatelessWidget {
  const QuestwellCatalogRoomArt({super.key, required this.slug});
  final String slug;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RoomArt(slug));
}

class _RoomArt extends CustomPainter {
  const _RoomArt(this.slug);
  final String slug;
  @override
  void paint(Canvas c, Size size) {
    c.save();
    c.scale(size.width / 100, size.height / 140);
    final p = Paint()..isAntiAlias = true;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      c.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    if (slug == 'rainy-window') {
      rect(2, 2, 96, 136, const Color(0xFF332820));
      rect(5, 5, 90, 126, const Color(0xFF996A43));
      rect(11, 11, 78, 114, const Color(0xFF1E3545));
      p.shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF24384D), Color(0xFF537277)])
          .createShader(const Rect.fromLTWH(13, 13, 74, 110));
      c.drawRect(const Rect.fromLTWH(13, 13, 74, 110), p);
      p.shader = null;
      for (var i = 0; i < 20; i++) {
        final x = 17.0 + (i * 19) % 66, y = 18.0 + (i * 31) % 94;
        p.color = const Color(0x667FC6D5);
        p.strokeWidth = .9;
        c.drawLine(Offset(x, y), Offset(x - 3, y + 8), p);
      }
      rect(46, 10, 7, 116, const Color(0xFF886144));
      rect(10, 64, 80, 6, const Color(0xFF886144));
      rect(7, 128, 88, 4, const Color(0xFFBF9063));
      rect(0, 133, 100, 5, const Color(0xFF4B3425));
    } else {
      p.color = const Color(0x55201810);
      c.drawOval(const Rect.fromLTWH(13, 128, 74, 9), p);
      p.shader =
          const RadialGradient(colors: [Color(0xAAFFE3A2), Color(0x00F9CB75)])
              .createShader(const Rect.fromLTWH(0, 15, 100, 110));
      c.drawOval(const Rect.fromLTWH(0, 15, 100, 110), p);
      p.shader = null;
      p.color = const Color(0xFFBC9C60);
      p.style = PaintingStyle.stroke;
      p.strokeWidth = 4;
      c.drawOval(const Rect.fromLTWH(35, 6, 30, 29), p);
      p.style = PaintingStyle.fill;
      rect(25, 33, 50, 6, const Color(0xFFBE9A57));
      rect(20, 39, 60, 5, const Color(0xFF51412D));
      p.shader = const LinearGradient(
              colors: [Color(0xFF87673B), Color(0xFFF2D492), Color(0xFF8B6734)])
          .createShader(const Rect.fromLTWH(26, 44, 48, 75));
      c.drawRect(const Rect.fromLTWH(26, 44, 48, 75), p);
      p.shader = null;
      rect(32, 48, 36, 64, const Color(0xFF294D43));
      rect(37, 51, 26, 56, const Color(0xFF5F8C68));
      p.color = const Color(0xFFE8F0B3);
      c.drawOval(const Rect.fromLTWH(44, 65, 13, 36), p);
      rect(45, 96, 11, 12, const Color(0xFFFFEDC4));
      rect(25, 118, 50, 6, const Color(0xFFD6B671));
      rect(21, 125, 58, 7, const Color(0xFF55422C));
    }
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _RoomArt oldDelegate) =>
      oldDelegate.slug != slug;
}

/// Only the glass layer repaints; room art and wooden framing remain cached.
class QuestwellRainyWindow extends StatefulWidget {
  const QuestwellRainyWindow({super.key, this.hallowed = false});
  final bool hallowed;
  @override
  State<QuestwellRainyWindow> createState() => _QuestwellRainyWindowState();
}

class _QuestwellRainyWindowState extends State<QuestwellRainyWindow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rain =
      AnimationController(vsync: this, duration: const Duration(seconds: 6));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _rain.stop();
      _rain.value = 0;
    } else if (!_rain.isAnimating) {
      _rain.repeat();
    }
  }

  @override
  void dispose() {
    _rain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: RepaintBoundary(
          child: AnimatedBuilder(
              animation: _rain,
              builder: (context, _) => CustomPaint(
                  painter: QuestwellRainyWindowOverlay(
                      phase: _rain.value, hallowed: widget.hallowed)))));
}

/// Glass coordinates are registered to hearth_environment_v2's 768px canvas.
/// Match its cover crop exactly, leaving every wooden mullion unobscured.
class QuestwellRainyWindowOverlay extends CustomPainter {
  const QuestwellRainyWindowOverlay({this.phase = 0, this.hallowed = false});
  final double phase;
  final bool hallowed;

  /// Authored glass only; shared by rain and preview-only autumn effects.
  static Path panesFor(bool hallowed) {
    final panes = Path();
    void pane(List<Offset> points) {
      panes.addPolygon(points, true);
    }

    if (hallowed) {
      // Source-art tracing, including the uninterrupted tall central pane.
      // The old mask invented a horizontal mullion through that pane and
      // stopped short of the arch, leaving purple scenery around the autumn.
      panes.addPath(
        Path()
          ..moveTo(979, 264)
          ..quadraticBezierTo(980, 223, 1008, 189)
          ..lineTo(1021, 203)
          ..lineTo(1033, 218)
          ..lineTo(1033, 316)
          ..lineTo(979, 316)
          ..close(),
        Offset.zero,
      );
      pane(const [Offset(1017, 181), Offset(1033, 165), Offset(1033, 201)]);
      pane(const [Offset(1054, 154), Offset(1068, 164), Offset(1054, 186)]);
      panes.addPath(
        Path()
          ..moveTo(1053, 222)
          ..quadraticBezierTo(1054, 201, 1074, 178)
          ..quadraticBezierTo(1096, 200, 1098, 221)
          ..lineTo(1098, 316)
          ..lineTo(1053, 316)
          ..close(),
        Offset.zero,
      );
      panes.addPath(
        Path()
          ..moveTo(1114, 229)
          ..quadraticBezierTo(1114, 184, 1164, 152)
          ..quadraticBezierTo(1183, 165, 1198, 181)
          ..lineTo(1198, 450)
          ..lineTo(1114, 450)
          ..close(),
        Offset.zero,
      );
      panes.addPath(
        Path()
          ..moveTo(1211, 207)
          ..quadraticBezierTo(1233, 237, 1233, 266)
          ..lineTo(1233, 314)
          ..lineTo(1211, 318)
          ..close(),
        Offset.zero,
      );
      pane(const [
        Offset(979, 329),
        Offset(1033, 329),
        Offset(1033, 445),
        Offset(979, 445),
      ]);
      pane(const [
        Offset(1053, 330),
        Offset(1098, 330),
        Offset(1098, 446),
        Offset(1053, 446),
      ]);
      pane(const [
        Offset(1211, 332),
        Offset(1233, 327),
        Offset(1233, 443),
        Offset(1211, 440),
      ]);
      // Small tracery lights above the two pointed arches.
      pane(const [Offset(1073, 144), Offset(1090, 134), Offset(1083, 153)]);
      pane(const [Offset(1123, 135), Offset(1140, 145), Offset(1130, 151)]);
      panes.addPath(
        Path()
          ..moveTo(1105, 133)
          ..quadraticBezierTo(1117, 147, 1108, 152)
          ..quadraticBezierTo(1125, 156, 1109, 163)
          ..lineTo(1107, 177)
          ..lineTo(1101, 167)
          ..lineTo(1100, 160)
          ..quadraticBezierTo(1084, 158, 1099, 152)
          ..quadraticBezierTo(1093, 144, 1105, 133)
          ..close(),
        Offset.zero,
      );
    } else {
      pane(const [
        Offset(725, 151),
        Offset(724, 132),
        Offset(731, 104),
        Offset(744, 83),
        Offset(750, 80),
        Offset(750, 145)
      ]);
      pane(const [
        Offset(759, 72),
        Offset(768, 66),
        Offset(768, 143),
        Offset(758, 145)
      ]);
      pane(const [
        Offset(724, 166),
        Offset(750, 158),
        Offset(750, 222),
        Offset(725, 225)
      ]);
      pane(const [
        Offset(759, 156),
        Offset(768, 153),
        Offset(768, 221),
        Offset(759, 222)
      ]);
      pane(const [
        Offset(725, 236),
        Offset(750, 232),
        Offset(750, 297),
        Offset(725, 298)
      ]);
      pane(const [
        Offset(759, 232),
        Offset(768, 230),
        Offset(768, 297),
        Offset(759, 297)
      ]);
      pane(const [
        Offset(725, 308),
        Offset(750, 306),
        Offset(750, 372),
        Offset(725, 370)
      ]);
      pane(const [
        Offset(759, 306),
        Offset(768, 306),
        Offset(768, 375),
        Offset(759, 373)
      ]);
    }
    return panes;
  }

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
    canvas.clipPath(panesFor(hallowed));
    final p = Paint()..color = const Color(0x99435762);
    canvas.drawRect(
        hallowed
            ? const Rect.fromLTWH(970, 170, 270, 280)
            : const Rect.fromLTWH(720, 60, 50, 320),
        p);
    p.isAntiAlias = true;
    for (var i = 0; i < (hallowed ? 100 : 40); i++) {
      final near = i % 3 == 0;
      final travel = ((i * 37) + phase * 320 * (near ? 2 : 1)) % 320;
      final x = (hallowed ? 978.0 : 726.0) +
          (i * 13) % (hallowed ? 252 : 48) -
          travel * .025;
      final y = (hallowed ? 140.0 : 60.0) + travel;
      p.color = near ? const Color(0xCDD3ECE7) : const Color(0x808EBACB);
      p.strokeWidth = near ? 1.8 : 1.1;
      canvas.drawLine(Offset(x, y), Offset(x - 2.5, y + (near ? 13 : 8)), p);
    }
    // A few slower beads slide down the inside of the glass.
    for (var i = 0; i < 5; i++) {
      final y = (hallowed ? 140.0 : 60.0) + (i * 67 + phase * 320) % 320;
      final x = (hallowed ? 984.0 : 729.0) +
          (i * (hallowed ? 53 : 11)) % (hallowed ? 240 : 38);
      p.color = const Color(0x809CBBC9);
      p.strokeWidth = 2.2;
      canvas.drawLine(Offset(x, y - 18), Offset(x, y), p);
      p.color = const Color(0xCCD4E4E5);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 2.6, height: 4), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant QuestwellRainyWindowOverlay oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.hallowed != hallowed;
}
