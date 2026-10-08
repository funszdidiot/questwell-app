import '../widgets/questwell_app_style.dart';
import 'package:flutter/material.dart';
import '../pages/chronicle_page/chronicle_page_widget.dart';
import '../services/questwell_cosmetic_service.dart';
import '../services/questwell_chronicle_service.dart';
import '../widgets/questwell_next_reward.dart';
import '../widgets/questwell_home_overview.dart';
import '../widgets/questwell_chronicle_entry.dart';
import '../widgets/questwell_adventurer_view.dart';

class MilestoneRoadmapReviewApp extends StatefulWidget {
  const MilestoneRoadmapReviewApp({super.key});
  @override
  State<MilestoneRoadmapReviewApp> createState() =>
      _MilestoneRoadmapReviewAppState();
}

class _MilestoneRoadmapReviewAppState extends State<MilestoneRoadmapReviewApp> {
  String state = 'Preview copy';
  double width = 390;
  @override
  Widget build(BuildContext context) {
    final earned = state == 'Level 5 earned';
    final owned = state != 'Before level 5';
    final profile = QuestwellProfile(
        level: earned ? 5 : 4,
        totalXp: earned ? 445 : 355,
        levelXpOffset: 45,
        coinBalance: 79,
        currentEnergyMode: 'normal',
        onboardingCompleted: true,
        adventurerArchetype: 'alchemist',
        avatarBodyType: 'male');
    final trophy = QuestwellCosmetic.fromJson({
      'id': 'trophy',
      'slug': 'first-journey-trophy',
      'name': 'First Journey',
      'category': 'room',
      'unlock_method': 'level_milestone',
      'milestone_level': 5,
    },
        owned: owned,
        equipped: owned,
        roomSlot: owned ? 'bookshelf_top' : null,
        source: earned ? 'level_milestone' : 'founder_testing_grant',
        unlockedAt: owned ? DateTime(2026, 9, 30, 17, 55) : null);
    final orrery = QuestwellCosmetic.fromJson({
      'id': 'orrery',
      'slug': 'starlit-orrery',
      'name': 'Starlit Orrery',
      'category': 'room',
      'unlock_method': 'level_milestone',
      'milestone_level': 10,
    });
    final entries = [
      if (owned)
        ChronicleWin(
            kind: 'milestone_reward',
            title: 'First Journey',
            completedAt: DateTime(2026, 9, 30, 17, 55),
            xp: 0,
            coins: 0,
            level: 5,
            cosmeticSlug: trophy.slug,
            source: trophy.source),
      if (earned)
        ChronicleWin(
            kind: 'level_up',
            title: 'Level 5 reached',
            completedAt: DateTime(2026, 9, 30, 17, 55),
            xp: 0,
            coins: 0,
            level: 5),
      ChronicleWin(
          kind: 'quest',
          title: 'Make time for a small win',
          completedAt: DateTime(2026, 9, 30, 17, 54),
          xp: 20,
          coins: 10),
    ];
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: QuestwellAppStyle.theme(),
        home: Builder(
            builder: (ctx) => QuestwellScaffold(
                backgroundColor: const Color(0xFF111827),
                body: SingleChildScrollView(
                    child: Center(
                        child: Column(children: [
                  const SizedBox(height: 16),
                  const Text('Simplified Hearth · sample profile'),
                  Wrap(spacing: 12, children: [
                    DropdownButton<String>(
                        value: state,
                        items: [
                          'Before level 5',
                          'Preview copy',
                          'Level 5 earned'
                        ]
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (s) => setState(() => state = s!)),
                    TextButton(
                        onPressed: () =>
                            setState(() => width = width == 390 ? 320 : 390),
                        child: Text('${width.toInt()} px')),
                    TextButton(
                        onPressed: () => Navigator.push(
                            ctx,
                            MaterialPageRoute<void>(
                                builder: (_) => ChroniclePageWidget(
                                    previewData: ChronicleSnapshot.fromWins(
                                        entries,
                                        now: DateTime(2026, 9, 30))))),
                        child: const Text('Open Chronicle')),
                  ]),
                  Wrap(
                      spacing: 20,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        SizedBox(
                            width: width,
                            child: Column(children: [
                              QuestwellHomeCharacter(
                                  archetype: 'alchemist',
                                  className: 'Alchemist',
                                  level: profile.level,
                                  xp: profile.xpIntoLevel,
                                  coins: 79,
                                  mastered: false,
                                  equippedNames: const [],
                                  decorNames: owned
                                      ? const ['First Journey']
                                      : const [],
                                  collection: const [],
                                  nextReward: QuestwellNextReward(
                                      cosmetics: [trophy, orrery]),
                                  onCustomize: () => Navigator.push(
                                      ctx,
                                      MaterialPageRoute<void>(
                                          builder: (pageContext) =>
                                              QuestwellScaffold(
                                                  backgroundColor:
                                                      const Color(0xFF111827),
                                                  body: QuestwellAdventurerView(
                                                    archetype: 'alchemist',
                                                    bodyType: 'male',
                                                    level: profile.level,
                                                    xp: profile.totalXp,
                                                    coins: 79,
                                                    description:
                                                        'Sample profile',
                                                    mastered: false,
                                                    collectionOwned: 0,
                                                    collectionTotal: 0,
                                                    relicName: 'Relic',
                                                    canClaim: false,
                                                    onClaim: () {},
                                                    onBody: (_) {},
                                                    onClass: (_) {},
                                                    onEquip: (_) {},
                                                    onUnequip: (_) {},
                                                    onMarket: () {},
                                                    onBack: () => Navigator.pop(
                                                        pageContext),
                                                    items: [
                                                      AdventurerInventoryItem(
                                                          id: trophy.id,
                                                          name: trophy.name,
                                                          slug: trophy.slug,
                                                          category:
                                                              trophy.category,
                                                          description:
                                                              'Earned at level 5. Display on your bookcase or mantel.',
                                                          owned: trophy.owned,
                                                          equipped:
                                                              trophy.equipped,
                                                          classLocked: false,
                                                          shop: false,
                                                          roomSlot:
                                                              trophy.roomSlot,
                                                          milestoneLevel: trophy
                                                              .milestoneLevel,
                                                          unlockedAt:
                                                              trophy.unlockedAt,
                                                          source: trophy.source)
                                                    ],
                                                  )))),
                                  onMarket: () {}),
                            ])),
                        SizedBox(
                            width: width,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CHRONICLE'),
                                  const SizedBox(height: 12),
                                  for (final entry in entries) ...[
                                    QuestwellChronicleEntry(win: entry),
                                    const SizedBox(height: 10)
                                  ],
                                ])),
                      ]),
                  const SizedBox(height: 24),
                ]))))));
  }
}
