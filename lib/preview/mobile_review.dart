import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'adventurer_review.dart';
import 'chronicle_review.dart';
import 'expedition_review.dart';
import 'home_sections_review.dart';
import 'quest_board_review.dart';
import 'market_catalog.dart';
import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_market_view.dart';

/// Dev-only fixtures. All purchases and equipment changes stay in memory.
class MobileReviewApp extends StatefulWidget {
  const MobileReviewApp({super.key});
  @override
  State<MobileReviewApp> createState() => _MobileReviewAppState();
}

class _MobileReviewAppState extends State<MobileReviewApp> {
  String screen = 'Market';
  double width = 390;
  double scale = 1;
  Widget get scene => switch (screen) {
    'Hearth' => const HomeSectionsReviewApp(),
    'Quests' => const QuestBoardReviewApp(),
    'Adventurer' => const AdventurerReviewApp(),
    'Chronicle' => const ChronicleReviewApp(),
    'Expedition' => const ExpeditionReviewApp(),
    _ => const _SampleMarket(),
  };

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Questwell · Mobile review',
    theme: ThemeData.dark(useMaterial3: true),
    home: KeyedSubtree(key: ValueKey(screen), child: scene),
    builder: (context, navigator) => Scaffold(backgroundColor: const Color(0xFF080F16),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Wrap(
          spacing: 16, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Questwell · Mobile preview'),
            TextButton.icon(
              onPressed: () => setState(() {
                const screens = ['Market', 'Hearth', 'Quests', 'Adventurer', 'Chronicle', 'Expedition'];
                screen = screens[(screens.indexOf(screen) + 1) % screens.length];
              }),
              icon: const Icon(Icons.navigate_next, size: 18), label: Text(screen)),
            TextButton(onPressed: () => setState(() => width = switch (width) {
              320 => 390, 390 => 430, _ => 320,
            }), child: Text('${width.toInt()} px')),
            TextButton(onPressed: () => setState(() => scale = switch (scale) {
              1 => 1.6, 1.6 => 2, _ => 1,
            }), child: Text('${(scale * 100).round()}% text')),
          ])),
        const Padding(padding: EdgeInsets.only(bottom: 8),
          child: Text('Sample content · Changes stay in this preview',
            style: TextStyle(fontSize: 12, color: Color(0xFFB7C4D4)))),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final size = Size(math.min(width, constraints.maxWidth),
            math.min(width == 320 ? 568.0 : 740.0, constraints.maxHeight));
          return Center(child: SizedBox.fromSize(size: size,
            child: ClipRect(child: MediaQuery(
              data: MediaQuery.of(context).copyWith(size: size,
                padding: EdgeInsets.zero, textScaler: TextScaler.linear(scale)),
              child: navigator!,
            ))));
        })),
        const SizedBox(height: 12),
      ])),
    ),
  );
}

class _SampleMarket extends StatefulWidget {
  const _SampleMarket();
  @override
  State<_SampleMarket> createState() => _SampleMarketState();
}
class _SampleMarketState extends State<_SampleMarket> {
  int coins = 650;
  final owned = <String>{};
  final equipped = <String, String>{};
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(backgroundColor: const Color(0xFF0A1419),
      body: QuestwellMarketView(
        data: QuestwellCosmeticsSnapshot(
          profile: QuestwellProfile(level: 4, totalXp: 355, coinBalance: coins,
            currentEnergyMode: 'normal', onboardingCompleted: true,
            adventurerArchetype: 'scholar', avatarBodyType: 'male'),
          cosmetics: marketReviewCatalog.map((row) => QuestwellCosmetic.fromJson(row,
            owned: owned.contains(row['slug']), equipped: equipped[row['category']] == row['slug'])).toList()),
        onRefresh: () async {},
        onPurchase: (item) async { setState(() {
          if (owned.add(item.slug)) coins -= item.price;
        }); },
        onEquip: (item) async { setState(() => equipped[item.category] = item.slug); },
        onUnequip: (item) async { setState(() => equipped.remove(item.category)); },
      )),
  );
}
