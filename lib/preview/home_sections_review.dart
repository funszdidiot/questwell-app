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
        home: Scaffold(
          backgroundColor: const Color(0xFF101A28),
          body: QuestwellCampfireBackground(
              active: _campfire,
              child: SafeArea(
                  child: QuestwellHomeCanvas(children: [
                Text('Sample Hearth · Changes stay in this preview',
                    textAlign: TextAlign.center,
                    style: QuestwellTypography.body(
                        fontSize: 12, color: const Color(0xFFB9C7D7))),
                const SizedBox(height: 12),
                const QuestwellHomeHeader(),
                const SizedBox(height: 2),
                const QuestwellPixelDivider(accent: Color(0xFFD6A84B)),
                const SizedBox(height: 6),
                QuestwellHomeRoomFrame(
                    child: QuestwellHearthPixelScene(
                        height:
                            MediaQuery.sizeOf(context).width < 430 ? 342 : 392,
                        archetype: widget.loadout?.archetype ?? 'scout',
                        avatarBodyType: widget.loadout?.body ?? 'neutral',
                        showRelic: widget.loadout?.mastered
                                .contains(widget.loadout?.archetype) ??
                            false,
                        equippedSlugs: widget.loadout?.equipment ?? const {})),
                const SizedBox(height: 24),
                QuestwellHomeCampfireControl(
                    active: _campfire,
                    onChanged: (value) => setState(() => _campfire = value)),
                const SizedBox(height: 24),
                Text(_campfire ? 'ONE SMALL WIN' : 'YOUR NEXT WIN',
                    style: QuestwellTypography.sectionHeading(
                        color: const Color(0xFFF2D9A0))),
                const SizedBox(height: 14),
                QuestwellHomeFocusLayout(
                  nextWin: const QuestwellHomeEmptyBoard(),
                  emphasizeAddQuest: true,
                  overview: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QuestwellHomeCharacter(
                          archetype: widget.loadout?.archetype ?? 'scout',
                          className: _classLabel,
                          level: 3,
                          xp: 95,
                          coins: 49,
                          mastered: widget.loadout?.mastered
                                  .contains(widget.loadout?.archetype) ??
                              false,
                          equippedNames: [
                            for (final e in (widget.loadout?.equipment ??
                                    <String, String>{})
                                .entries)
                              if (!e.key.startsWith('room') &&
                                  !e.key.startsWith('wall_art'))
                                e.value
                          ],
                          decorNames: [
                            for (final e in (widget.loadout?.equipment ??
                                    <String, String>{})
                                .entries)
                              if (e.key.startsWith('room') ||
                                  e.key.startsWith('wall_art'))
                                e.value
                          ],
                          collection: const [
                            HomeCollectionItem(
                                name: 'Scout cloak',
                                slug: 'scout_cloak',
                                category: 'outfit',
                                archetype: 'scout',
                                owned: false,
                                equipped: false),
                            HomeCollectionItem(
                                name: 'Trail accessory',
                                slug: 'trail_accessory',
                                category: 'accessory',
                                archetype: 'scout',
                                owned: true,
                                equipped: false),
                          ],
                          onCustomize: () => QuestwellNavigationScope.open(
                              context, QuestwellDestination.adventurer),
                          onMarket: () => QuestwellNavigationScope.open(
                              context, QuestwellDestination.market)),
                      const SizedBox(height: 12),
                      QuestwellHomeMomentum(
                          wins: 4,
                          bosses: 0,
                          onOpen: () => QuestwellNavigationScope.open(
                              context, QuestwellDestination.chronicle)),
                    ],
                  ),
                  onOpen: (key) => QuestwellNavigationScope.open(
                      context,
                      key == 'quests'
                          ? QuestwellDestination.quests
                          : QuestwellDestination.expedition),
                ),
              ]))),
        ),
      );
}
