import 'package:flutter/material.dart';
import 'questwell_destination_entrance.dart';
import 'questwell_market_motion.dart';

class QuestwellMarketShopfront extends StatelessWidget {
  const QuestwellMarketShopfront({super.key, required this.coins, this.onHome});
  final int coins;
  final VoidCallback? onHome;
  @override
  Widget build(BuildContext context) => QuestwellDestinationEntrance(
      destination: 'market',
      onHome: onHome,
      title: 'MARKET',
      subtitle: 'Rare finds, class gear, and questionable fashion choices.',
      ambience: const QuestwellMarketAmbience(),
      footer: QuestwellCoinBalance(coins: coins));
}
