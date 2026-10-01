import 'package:flutter/material.dart';
import 'questwell_typography.dart';

/// A responsive shop façade built on the same crisp pixel grid as Market items.
/// Keep the sign and supporting copy as real text for accessibility and scaling.
class QuestwellMarketShopfront extends StatelessWidget {
  const QuestwellMarketShopfront({super.key, required this.coins,
    required this.owned, required this.total});
  final int coins, owned, total;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF192F2C),
      border: Border.all(color: const Color(0xFF816343), width: 2),
      boxShadow: const [BoxShadow(color: Color(0x60000000), offset: Offset(0, 5))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AspectRatio(aspectRatio: 180 / 86, child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          const Positioned.fill(child: ExcludeSemantics(child:
            CustomPaint(painter: _ShopfrontPainter()))),
          Positioned(left: constraints.maxWidth * 40 / 180,
            right: constraints.maxWidth * 40 / 180,
            top: constraints.maxHeight * 41 / 86,
            bottom: constraints.maxHeight * 18 / 86,
            child: Center(child: Semantics(header: true, child: Text('MARKET',
              textAlign: TextAlign.center,
              style: QuestwellTypography.sectionHeading(size: 14,
                color: const Color(0xFFF5D898)))))),
        ]))),
      Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(children: [
          Text('Rare finds, class gear, and questionable fashion choices.',
            textAlign: TextAlign.center,
            style: QuestwellTypography.body(color: const Color(0xFFD8D2B9))),
          const SizedBox(height: 15),
          Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF102420),
                  border: Border.all(color: const Color(0xFF61745B))),
                child: Text('◈  $coins coins', style: QuestwellTypography.body(
                  color: const Color(0xFFE0BF79), fontWeight: FontWeight.w700,
                  fontSize: 16))),
              Text('$owned / $total collected', style: QuestwellTypography.body(
                color: const Color(0xFFBBC6B4), fontSize: 12)),
            ]),
        ])),
    ]));
}

class _ShopfrontPainter extends CustomPainter {
  const _ShopfrontPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 180, size.height / 86);
    final paint = Paint()..isAntiAlias = false;
    void block(double x, double y, double w, double h, int color) {
      paint.color = Color(color);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
    }
    // Shadowed plaster, walnut framing, and horizontal wall boards.
    block(0, 0, 180, 86, 0xFF142824);
    block(5, 12, 170, 69, 0xFF294137);
    for (var y = 20; y < 81; y += 12) {
      block(7, y.toDouble(), 166, 1, 0xFF1B302A);
      block(7, y + 1.0, 166, 1, 0xFF364D3E);
    }
    for (final x in [3.0, 172.0]) {
      block(x, 5, 5, 76, 0xFF573E2D);
      block(x, 5, 1, 76, 0xFF99764B);
      block(x + 3, 8, 1, 70, 0xFF352C25);
    }
    // Glowing display windows frame the wooden shop sign.
    for (final x in [11.0, 145.0]) {
      block(x, 45, 24, 31, 0xFF0C1B1C);
      block(x + 2, 47, 20, 26, 0xFF766340);
      block(x + 3, 48, 18, 24, 0xFFAE9155);
      block(x + 4, 49, 16, 9, 0xFFC7AE6B);
      block(x + 11, 47, 2, 26, 0xFF4C3C2B);
      block(x + 2, 60, 20, 2, 0xFF4C3C2B);
      block(x - 1, 74, 26, 3, 0xFF9C7446);
      block(x + 3, 64, 3, 8, 0xFF36594B);
      block(x + 6, 65, 3, 7, 0xFF693F3C);
      block(x + 15, 65, 4, 7, 0xFF4F6678);
      block(x + 16, 63, 2, 3, 0xFF394C56);
    }
    // Brass lanterns, with stepped amber glass instead of blurred glow.
    for (final x in [22.0, 158.0]) {
      block(x - 1, 29, 2, 5, 0xFFAC8850);
      block(x - 4, 34, 8, 2, 0xFF352C25);
      block(x - 3, 36, 6, 8, 0xFFCB984B);
      block(x - 2, 36, 4, 6, 0xFFF3CC72);
      block(x - 1, 37, 2, 4, 0xFFFFE6A1);
      block(x - 4, 43, 8, 2, 0xFF49372B);
    }
    // Short chains suspend a substantial, brass-edged walnut sign.
    for (final x in [51.0, 127.0]) {
      block(x, 26, 2, 14, 0xFF33291F);
      for (var y = 28; y < 40; y += 4) {
        block(x, y.toDouble(), 2, 2, 0xFFC2A066);
      }
    }
    block(38, 41, 106, 31, 0xFF0C1D1B);
    block(36, 38, 108, 31, 0xFF372D25);
    block(38, 39, 104, 28, 0xFFAB824B);
    block(40, 41, 100, 24, 0xFF553C2C);
    block(41, 42, 98, 1, 0xFF795537);
    block(41, 52, 98, 1, 0xFF493426);
    block(41, 63, 98, 1, 0xFF332B24);
    for (final x in [39.0, 138.0]) {
      block(x, 40, 2, 2, 0xFFE0BB78);
      block(x, 64, 2, 2, 0xFFE0BB78);
    }
    // Stepped forest-green and parchment awning, supported by a timber beam.
    block(1, 4, 178, 4, 0xFF9B7548);
    block(3, 8, 174, 3, 0xFF392E25);
    for (var i = 0; i < 10; i++) {
      final x = i * 18.0;
      final green = i.isEven;
      block(x + 2, 10, 14, 4, green ? 0xFF4D7560 : 0xFFC8B585);
      block(x + 1, 14, 16, 5, green ? 0xFF426650 : 0xFFBBA574);
      block(x, 19, 18, 6, green ? 0xFF365541 : 0xFFA58B5D);
      block(x, 25, 18, 2, 0xFF21382D);
      block(x + 1, 27, 16, 4, green ? 0xFF54765A : 0xFFD1BB83);
      block(x + 3, 31, 12, 2, green ? 0xFF36513E : 0xFFAC925E);
      block(x + 2, 14, 1, 10, green ? 0xFF688B6A : 0xFFE5D3A0);
    }
    block(3, 79, 174, 3, 0xFF735336);
    block(5, 79, 170, 1, 0xFFAE8750);
    block(3, 82, 174, 2, 0xFF10231F);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _ShopfrontPainter oldDelegate) => false;
}
