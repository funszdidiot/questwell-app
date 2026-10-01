import '../widgets/questwell_app_navigation.dart';
import 'package:flutter/material.dart';
import 'review_loadout.dart';
import '../widgets/questwell_home_sections.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_home_overview.dart';
import '../widgets/questwell_typography.dart';
import '../widgets/questwell_campfire_background.dart';

class HomeSectionsReviewApp extends StatefulWidget {
  const HomeSectionsReviewApp({super.key, this.loadout});
  final QuestwellReviewLoadout? loadout;
  @override
  State<HomeSectionsReviewApp> createState() => _HomeSectionsReviewAppState();
}

class _HomeSectionsReviewAppState extends State<HomeSectionsReviewApp> {
  bool _campfire = false;
  String get _classLabel {
    final value = widget.loadout?.archetype ?? 'scout';
    return value[0].toUpperCase() + value.substring(1);
  }
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(backgroundColor: const Color(0xFF101A28),
      body: QuestwellCampfireBackground(active: _campfire, child: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const QuestwellHomeHeader(),
const SizedBox(height: 2),
          const QuestwellPixelDivider(accent: Color(0xFFD6A84B)),
          const SizedBox(height: 6),
          QuestwellHearthPixelScene(height: 342,
            archetype: widget.loadout?.archetype ?? 'scout', avatarBodyType: widget.loadout?.body ?? 'neutral',
            showRelic: widget.loadout?.mastered.contains(widget.loadout?.archetype) ?? false,
            equippedSlugs: widget.loadout?.equipment ?? const {}),
          const SizedBox(height: 16),
          QuestwellHomeCharacter(archetype: widget.loadout?.archetype ?? 'scout',
            className: _classLabel,
            level: 3, xp: 95, coins: 49, mastered: widget.loadout?.mastered.contains(widget.loadout?.archetype) ?? false, equippedNames: [for (final e in (widget.loadout?.equipment ?? <String, String>{}).entries)
              if (!e.key.startsWith('room') && !e.key.startsWith('wall_art')) e.value],
            decorNames: [for (final e in (widget.loadout?.equipment ?? <String, String>{}).entries)
              if (e.key.startsWith('room') || e.key.startsWith('wall_art')) e.value],
            collection: const [
              HomeCollectionItem(name: 'Scout cloak', slug: 'scout_cloak', category: 'outfit',
                archetype: 'scout', owned: false, equipped: false),
              HomeCollectionItem(name: 'Trail accessory', slug: 'trail_accessory', category: 'accessory',
                archetype: 'scout', owned: true, equipped: false),
            ], onCustomize: () => QuestwellNavigationScope.open(context, QuestwellDestination.adventurer), onMarket: () => QuestwellNavigationScope.open(context, QuestwellDestination.market)),
          const SizedBox(height: 12),
          QuestwellHomeMomentum(wins: 4, bosses: 0, onOpen: () => QuestwellNavigationScope.open(context, QuestwellDestination.chronicle)),
          const SizedBox(height: 12),
          QuestwellHomeCampfireControl(active: _campfire,
            onChanged: (value) => setState(() => _campfire = value)),
          const SizedBox(height: 24),
          Text('YOUR NEXT WIN', style: QuestwellTypography.sectionHeading(
            color: const Color(0xFFF2D9A0))),
          const SizedBox(height: 14),
          const QuestwellHomeEmptyBoard(),
          const SizedBox(height: 14),
          QuestwellHomeActions(onOpen: (key) => QuestwellNavigationScope.open(context, switch (key) {
              'quest' || 'quests' => QuestwellDestination.quests,
              'boss' => QuestwellDestination.bosses,
              'expedition' => QuestwellDestination.expedition,
              'market' => QuestwellDestination.market,
              'chronicle' => QuestwellDestination.chronicle,
              _ => QuestwellDestination.adventurer,
            })),
        ]),
      )))),
    ),
  );
}

