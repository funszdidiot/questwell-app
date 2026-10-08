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
  Widget build(BuildContext context) => Material(
        color: QuestwellHearthMaterial.timber,
        shape: QuestwellHearthMaterial.shape,
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          foregroundPainter: const _HearthFramePainter(),
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
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

class _HearthFramePainter extends CustomPainter {
  const _HearthFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 20 || size.height < 20) return;
    final bounds = Offset.zero & size;
    final paint = Paint()..isAntiAlias = false;
    canvas.save();
    canvas.clipRect(bounds);
    // Paint rails inside the existing margin without reducing layout width.
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = QuestwellHearthMaterial.timber;
    canvas.drawRect(bounds.deflate(4.5), paint);
    // Stepped highlights suggest carved rails without texture behind text.
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF8D633C);
    canvas.drawRect(bounds.deflate(1.5), paint);
    paint.color = const Color(0xFF241B18);
    canvas.drawRect(bounds.deflate(4.5), paint);
    paint.color = const Color(0xFF90744B);
    canvas.drawRect(bounds.deflate(9.5), paint);
    paint.style = PaintingStyle.fill;
    for (final corner in [
      const Offset(1, 1),
      Offset(size.width - 11, 1),
      Offset(1, size.height - 11),
      Offset(size.width - 11, size.height - 11),
    ]) {
      paint.color = QuestwellHearthMaterial.brass;
      canvas.drawRect(corner & const Size(10, 10), paint);
      paint.color = const Color(0xFFF1D394);
      canvas.drawRect((corner + const Offset(1, 1)) & const Size(6, 1), paint);
      paint.color = const Color(0xFF694925);
      canvas.drawRect((corner + const Offset(3, 3)) & const Size(2, 2), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HearthFramePainter oldDelegate) => false;
}

/// Bundled serif means the Hearth never depends on a network font request.
class QuestwellHearthButton extends StatelessWidget {
  const QuestwellHearthButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
              color: Color(0x55261B0D), blurRadius: 3, offset: Offset(0, 3)),
        ]),
        child: CustomPaint(
            foregroundPainter: const _HearthButtonPainter(),
            child: FilledButton(
                onPressed: onPressed,
                style: QuestwellHearthMaterial.primaryButton().copyWith(
                    textStyle: WidgetStatePropertyAll(
                        QuestwellHearthMaterial.serif(21))),
                child: Text(label, textAlign: TextAlign.center))),
      );
}

class _HearthButtonPainter extends CustomPainter {
  const _HearthButtonPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    p.color = const Color(0xFF927A45);
    canvas.drawRect((Offset.zero & size).deflate(3), p);
    p.color = const Color(0x663F8B6F);
    canvas.drawLine(const Offset(6, 6), Offset(size.width - 6, 6), p);
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
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: QuestwellHearthFrame(
                  warm: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: QuestwellTypography.sectionHeading(size: 10)))),
          Transform.translate(
              offset: const Offset(0, -5),
              child: QuestwellHearthFrame(
                  parchment: true,
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
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
    for (double y = 0; y < size.height; y += 36) {
      p.color = const Color(0xFF1D1512);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), p);
      p.color = const Color(0xFF65422C);
      canvas.drawRect(Rect.fromLTWH(0, y + 2, size.width, 1), p);
      for (var i = 0; i < 6; i++) {
        p.color = i.isEven ? const Color(0x256F482E) : const Color(0x3518100D);
        final x = ((y * 7 + i * 71) % 113) - 30;
        canvas.drawRect(
            Rect.fromLTWH(x, y + 6 + i * 4, size.width * .78, 1), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HearthTimberPainter oldDelegate) => false;
}
