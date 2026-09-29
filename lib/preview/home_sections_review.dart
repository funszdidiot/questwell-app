import 'package:flutter/material.dart';
import '../widgets/questwell_home_sections.dart';
import '../widgets/questwell_home_overview.dart';
import '../widgets/questwell_typography.dart';
import '../widgets/questwell_campfire_background.dart';

class HomeSectionsReviewApp extends StatefulWidget {
  const HomeSectionsReviewApp({super.key});
  @override
  State<HomeSectionsReviewApp> createState() => _HomeSectionsReviewAppState();
}

class _HomeSectionsReviewAppState extends State<HomeSectionsReviewApp> {
  bool _campfire = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(backgroundColor: const Color(0xFF101A28),
      body: QuestwellCampfireBackground(active: _campfire, child: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          QuestwellHomeHeader(onOpen: (_) {}),
          const SizedBox(height: 14),
          QuestwellHomeCharacter(archetype: 'scout', className: 'Scout',
            level: 3, xp: 95, coins: 49, mastered: false, equippedNames: const [],
            collection: const [
              HomeCollectionItem(name: 'Scout cloak', slug: 'scout_cloak', category: 'outfit',
                archetype: 'scout', owned: false, equipped: false),
              HomeCollectionItem(name: 'Trail accessory', slug: 'trail_accessory', category: 'accessory',
                archetype: 'scout', owned: true, equipped: false),
            ], onCustomize: () {}, onMarket: () {}),
          const SizedBox(height: 12),
          QuestwellHomeMomentum(wins: 4, bosses: 0, onOpen: () {}),
          const SizedBox(height: 12),
          QuestwellHomeCampfireControl(active: _campfire,
            onChanged: (value) => setState(() => _campfire = value)),
          const SizedBox(height: 24),
          Text('YOUR NEXT WIN', style: QuestwellTypography.sectionHeading(
            color: const Color(0xFFF2D9A0))),
          const SizedBox(height: 14),
          const QuestwellHomeEmptyBoard(),
          const SizedBox(height: 14),
          QuestwellHomeActions(onOpen: (_) {}),
        ]),
      )))),
    ),
  );
}
