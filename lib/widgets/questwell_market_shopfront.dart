import 'package:flutter/material.dart';
import 'questwell_typography.dart';
import 'questwell_market_motion.dart';

/// Illustrated fantasy shopfront with a live, accessible title overlay.
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
      AspectRatio(aspectRatio: 2, child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          Positioned.fill(child: ExcludeSemantics(child:
            Image.asset('assets/images/questwell_market_shopfront_v3.webp',
              fit: BoxFit.contain, filterQuality: FilterQuality.medium))),
          const Positioned.fill(child:QuestwellMarketAmbience()),
          Positioned(left: constraints.maxWidth * .30,
            right: constraints.maxWidth * .30,
            top: constraints.maxHeight * .32,
            bottom: constraints.maxHeight * .49,
            child: Center(child: Semantics(header: true, child: FittedBox(
              fit: BoxFit.scaleDown, child: Text('MARKET',
              textAlign: TextAlign.center,
              style: QuestwellTypography.sectionHeading(size: 20,
                color: const Color(0xFFF5D898)).copyWith(height: 1.15,
                  shadows: const [Shadow(color: Color(0xFF22180F), offset: Offset(0, 2))])))))),
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
                child: QuestwellCoinBalance(coins:coins)),
              Text('$owned / $total collected', style: QuestwellTypography.body(
                color: const Color(0xFFBBC6B4), fontSize: 12)),
            ]),
        ])),
    ]));
}
