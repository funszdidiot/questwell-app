import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'questwell_typography.dart';

/// Presentation-only materials: no scene geometry, assets or game state.
abstract final class QuestwellHearthMaterial {
  static const brass = Color(0xFFC49A55);
  static const ink = Color(0xFFF0E5CC);
  static const evergreen = Color(0xFF244C3E);
  static const timber = Color(0xFF493326);
  static const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(3)),
  );

  static TextStyle serif(double size, {Color color = ink}) => TextStyle(
      fontFamily: 'HearthSerif',
      fontSize: size,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: color);

  static ButtonStyle primaryButton() => FilledButton.styleFrom(
        backgroundColor: evergreen,
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.all(15),
        side: const BorderSide(color: brass),
        shape: shape,
        textStyle: QuestwellTypography.body(
            fontSize: 16, height: 1.3, fontWeight: FontWeight.w700),
      );

  static ButtonStyle secondaryButton() => OutlinedButton.styleFrom(
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.all(15),
        side: const BorderSide(color: brass),
        shape: shape,
        textStyle: QuestwellTypography.body(
            fontSize: 16, height: 1.3, fontWeight: FontWeight.w700),
      );
}

/// A restrained timber rail and brass corner finish around readable content.
/// Native Material/Ink interactions remain above the background, while the
/// decorative foreground occupies the content's existing outer margin.
class QuestwellHearthFrame extends StatelessWidget {
  const QuestwellHearthFrame({
    super.key,
    required this.child,
    this.warm = false,
    this.parchment = false,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final bool warm, parchment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: const BoxDecoration(boxShadow: [
        BoxShadow(
            color: Color(0x660B0806), blurRadius: 5, offset: Offset(0, 3)),
      ]),
      child: Material(
        color: QuestwellHearthMaterial.timber,
        shape: QuestwellHearthMaterial.shape,
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          foregroundPainter: _HearthFramePainter(parchment: parchment),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: parchment
                    ? const [Color(0xFFF4E4BC), Color(0xFFE2C78E)]
                    : warm
                        ? const [Color(0xFF33271F), Color(0xFF231E1D)]
                        : const [Color(0xFF202D37), Color(0xFF17212B)],
              ),
            ),
            child: CustomPaint(
                painter: parchment ? const _ParchmentPainter() : null,
                child: Padding(
                    padding: padding,
                    child: parchment
                        ? Theme(
                            data: Theme.of(context).copyWith(
                                textSelectionTheme:
                                    const TextSelectionThemeData(
                                        cursorColor: Color(0xFF244C3E),
                                        selectionColor: Color(0x55386C54),
                                        selectionHandleColor:
                                            Color(0xFF244C3E))),
                            child: child)
                        : child)),
          ),
        ),
      ));
}

class _HearthFramePainter extends CustomPainter {
  const _HearthFramePainter({this.parchment = false});
  final bool parchment;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 24 || size.height < 24) return;
    final bounds = Offset.zero & size;
    final p = Paint()..isAntiAlias = true;
    canvas.save();
    canvas.clipRect(bounds);
    // Wide carved wood, an illuminated upper lip and a recessed inner edge.
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9D693D), Color(0xFF58351F), Color(0xFF281A15)],
      ).createShader(bounds);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bounds.deflate(4.5), const Radius.circular(3)),
        p);
    p.shader = null;
    p
      ..strokeWidth = 1
      ..color = const Color(0xFFF0CB83);
    canvas.drawLine(const Offset(12, 1.5), Offset(size.width - 12, 1.5), p);
    p.color = const Color(0xFF28160D);
    canvas.drawRect(bounds.deflate(5), p);
    p.color = const Color(0xFFB98A4B);
    canvas.drawRect(bounds.deflate(8), p);
    p.color = const Color(0x990A0806);
    canvas.drawRect(bounds.deflate(10), p);
    // Forged corner brackets have clipped shoulders, light and a dark rivet seat.
    for (final corner in [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      canvas.save();
      canvas.translate(corner.dx, corner.dy);
      canvas.scale(corner.dx == 0 ? 1 : -1, corner.dy == 0 ? 1 : -1);
      final bracket = Path()
        ..moveTo(2, 0)
        ..lineTo(15, 0)
        ..lineTo(15, 5)
        ..lineTo(9, 11)
        ..lineTo(9, 15)
        ..lineTo(0, 15)
        ..lineTo(0, 2)
        ..close();
      p
        ..style = PaintingStyle.fill
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE7A3), Color(0xFFC39A55), Color(0xFF72502A)],
        ).createShader(const Rect.fromLTWH(0, 0, 15, 15));
      canvas.drawPath(bracket, p);
      p
        ..shader = null
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF4D321C)
        ..strokeWidth = 1;
      canvas.drawPath(bracket, p);
      p
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF674627);
      canvas.drawCircle(const Offset(5, 5), 2.3, p);
      p.color = const Color(0xFFF9D78D);
      canvas.drawCircle(const Offset(4.5, 4.3), 1.25, p);
      canvas.restore();
    }
    if (parchment && size.height > 64) {
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = const Color(0x777F5E2D);
      final inner = bounds.deflate(12);
      canvas.drawRRect(
          RRect.fromRectAndRadius(inner, const Radius.circular(5)), p);
      for (final x in [inner.left, inner.right]) {
        for (final y in [inner.top, inner.bottom]) {
          canvas.save();
          canvas.translate(x, y);
          canvas.scale(x == inner.left ? 1 : -1, y == inner.top ? 1 : -1);
          canvas.drawPath(
              Path()
                ..moveTo(0, 15)
                ..lineTo(0, 4)
                ..lineTo(4, 0)
                ..lineTo(15, 0),
              p);
          canvas.restore();
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HearthFramePainter oldDelegate) =>
      parchment != oldDelegate.parchment;
}

/// Quiet, deterministic fibers and edge patina; no visual noise under the copy.
class _ParchmentPainter extends CustomPainter {
  const _ParchmentPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final p = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.25, -.3),
        radius: .85,
        colors: [Color(0x55FFF9DF), Color(0x00F3DBA4), Color(0x337C5226)],
        stops: [0, .72, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, p);
    p.shader = null;
    for (var i = 0; i < 110; i++) {
      final x = 16 + ((i * 73.0) % math.max(1, size.width - 32));
      final y = 16 + ((i * 47.0) % math.max(1, size.height - 32));
      p.color = i.isEven ? const Color(0x12784920) : const Color(0x24FFF8DB);
      canvas.drawLine(Offset(x, y), Offset(x + 2 + i % 4, y + .3), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ParchmentPainter oldDelegate) => false;
}

/// Bundled serif means the Hearth never depends on a network font request.
class QuestwellHearthButton extends StatelessWidget {
  const QuestwellHearthButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: onPressed == null
                ? const [Color(0xFF526057), Color(0xFF333D37)]
                : const [
                    Color(0xFF326D53),
                    Color(0xFF204E3E),
                    Color(0xFF12392F)
                  ],
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x77261B0D), blurRadius: 4, offset: Offset(0, 3))
          ],
        ),
        child: CustomPaint(
            foregroundPainter: const _HearthButtonPainter(),
            child: FilledButton(
                onPressed: onPressed,
                style: QuestwellHearthMaterial.primaryButton().copyWith(
                    backgroundBuilder: (context, states, child) =>
                        child ?? const SizedBox(),
                    backgroundColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 14, vertical: 11)),
                    textStyle: WidgetStatePropertyAll(
                        QuestwellHearthMaterial.serif(19))),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Flexible(child: Text(label, textAlign: TextAlign.center)),
                  const SizedBox(width: 9),
                  const Icon(Icons.chevron_right, size: 23),
                ]))),
      );
}

class _HearthButtonPainter extends CustomPainter {
  const _HearthButtonPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    p.color = const Color(0xFFE6C17C);
    canvas.drawRect((Offset.zero & size).deflate(3), p);
    p.color = const Color(0xAA78A283);
    canvas.drawLine(const Offset(6, 6), Offset(size.width - 6, 6), p);
    p.color = const Color(0xFF0D2B23);
    canvas.drawLine(
        Offset(5, size.height - 5), Offset(size.width - 5, size.height - 5), p);
    p.style = PaintingStyle.fill;
    for (final x in [5.0, size.width - 8]) {
      for (final y in [5.0, size.height - 8]) {
        p.color = const Color(0xFFE7C277);
        canvas.drawRect(Rect.fromLTWH(x, y, 3, 3), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HearthButtonPainter oldDelegate) => false;
}

/// Same lit emerald and metal edge for the current Home destination.
class QuestwellHearthTabSurface extends StatelessWidget {
  const QuestwellHearthTabSurface(
      {super.key, required this.selected, required this.child});
  final bool selected;
  final Widget child;
  @override
  Widget build(BuildContext context) => selected
      ? DecoratedBox(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF315F4C), Color(0xFF142F28)]),
              boxShadow: [
                BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 3,
                    offset: Offset(0, 2))
              ]),
          child: CustomPaint(
              foregroundPainter: const _HearthButtonPainter(), child: child),
        )
      : child;
}

class QuestwellHearthQuestFrame extends StatelessWidget {
  const QuestwellHearthQuestFrame(
      {super.key, required this.child, required this.label});
  final Widget child;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Flow measures the entire plaque at any text scale before the card starts.
          Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.textScalerOf(context).scale(10) > 13
                      ? 24
                      : 52),
              child: QuestwellHearthFrame(
                  warm: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: QuestwellTypography.sectionHeading(size: 10)))),
          Transform.translate(
              offset: const Offset(0, -5),
              child: QuestwellHearthFrame(
                  parchment: true,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: child)),
        ],
      );
}

/// A deterministic carved timber surface, painted behind readable controls.
class QuestwellHearthTimber extends StatelessWidget {
  const QuestwellHearthTimber({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: const _HearthTimberPainter(), child: child);
}

class _HearthTimberPainter extends CustomPainter {
  const _HearthTimberPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final p = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF483024), Color(0xFF251C18), Color(0xFF3D291F)],
      ).createShader(bounds);
    canvas.drawRect(bounds, p);
    p.shader = null;
    for (double y = 0; y < size.height; y += 52) {
      p.color = const Color(0xFF1D1512);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), p);
      p.color = const Color(0xFF65422C);
      canvas.drawRect(Rect.fromLTWH(0, y + 2, size.width, 1), p);
      for (var i = 0; i < 5; i++) {
        p.color = i.isEven ? const Color(0x256F482E) : const Color(0x3518100D);
        final x = ((y * 7 + i * 71) % 113) - 30;
        p
          ..style = PaintingStyle.stroke
          ..strokeWidth = .65;
        canvas.drawPath(
            Path()
              ..moveTo(x, y + 9 + i * 7)
              ..cubicTo(size.width * .28, y + 5 + i * 7, size.width * .52,
                  y + 14 + i * 7, size.width + 20, y + 8 + i * 7),
            p);
        p.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HearthTimberPainter oldDelegate) => false;
}
