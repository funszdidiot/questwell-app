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
                    ? const [Color(0xFFF0E0BA), Color(0xFFE7D3A7)]
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
      ..strokeWidth = 6
      ..color = QuestwellHearthMaterial.timber;
    canvas.drawRect(bounds.deflate(3), paint);
    // Stepped highlights suggest carved rails without texture behind text.
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF8D633C);
    canvas.drawRect(bounds.deflate(1.5), paint);
    paint.color = const Color(0xFF241B18);
    canvas.drawRect(bounds.deflate(4.5), paint);
    paint.color = const Color(0xFF90744B);
    canvas.drawRect(bounds.deflate(6.5), paint);
    paint.style = PaintingStyle.fill;
    for (final corner in [
      const Offset(1, 1),
      Offset(size.width - 9, 1),
      Offset(1, size.height - 9),
      Offset(size.width - 9, size.height - 9),
    ]) {
      paint.color = QuestwellHearthMaterial.brass;
      canvas.drawRect(corner & const Size(8, 8), paint);
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
