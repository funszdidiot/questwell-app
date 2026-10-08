import '../widgets/questwell_app_navigation.dart';
import 'package:flutter/material.dart';
import 'review_loadout.dart';
import '../widgets/questwell_home_sections.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_home_overview.dart';
import '../widgets/questwell_home_quest.dart';
import '../widgets/questwell_typography.dart';
import '../widgets/questwell_campfire_background.dart';

class HomeSectionsReviewApp extends StatefulWidget {
  const HomeSectionsReviewApp(
      {super.key, this.loadout, this.startEmpty = false});
  final QuestwellReviewLoadout? loadout;
  final bool startEmpty;
  @override
  State<HomeSectionsReviewApp> createState() => _HomeSectionsReviewAppState();
}

class _HomeSectionsReviewAppState extends State<HomeSectionsReviewApp> {
  bool _campfire = false;
  bool _completed = false;
  String get _classLabel {
    final value = widget.loadout?.archetype ?? 'scout';
    return value[0].toUpperCase() + value.substring(1);
  }

  void _open(QuestwellDestination destination) =>
      QuestwellNavigationScope.open(context, destination);
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          backgroundColor: const Color(0xFF201813),
          bottomNavigationBar: QuestwellAppNavigation(
              current: QuestwellDestination.hearth, onSelect: _open),
          body: QuestwellCampfireBackground(
              active: _campfire,
              child: SafeArea(
                  child: QuestwellHomeCanvas(children: [
                LayoutBuilder(
                    builder: (context, bounds) => QuestwellHomeHero(
                        room: QuestwellHearthPixelScene(
                            immersive: true,
                            height: bounds.maxWidth * .72 + 40,
                            archetype: widget.loadout?.archetype ?? 'scout',
                            avatarBodyType: widget.loadout?.body ?? 'neutral',
                            showRelic: widget.loadout?.mastered
                                    .contains(widget.loadout?.archetype) ??
                                false,
                            equippedSlugs:
                                widget.loadout?.equipment ?? const {}))),
                const SizedBox(height: 8),
                QuestwellHomeFocusLayout(
                  overview: QuestwellHomeCharacter(
                      compact: true,
                      archetype: widget.loadout?.archetype ?? 'scout',
                      className: _classLabel,
                      level: 3,
                      xp: _completed ? 105 : 95,
                      coins: _completed ? 51 : 49,
                      mastered: widget.loadout?.mastered
                              .contains(widget.loadout?.archetype) ??
                          false,
                      equippedNames: const [],
                      collection: const [],
                      onCustomize: () => _open(QuestwellDestination.adventurer),
                      onMarket: () => _open(QuestwellDestination.market)),
                  nextWin: _completed || widget.startEmpty
                      ? const QuestwellHomeEmptyBoard()
                      : QuestwellHearthQuestContent(
                          title: 'Clear one small corner of your desk.',
                          xp: 10,
                          coins: 2,
                          onComplete: () => setState(() => _completed = true)),
                  emphasizeAddQuest: _completed || widget.startEmpty,
                  gentle: _campfire,
                  campfire: QuestwellHomeCampfireControl(
                      active: _campfire,
                      onChanged: (value) => setState(() => _campfire = value)),
                  secondary: QuestwellHomeMomentum(
                      wins: _completed ? 5 : 4,
                      bosses: 0,
                      onOpen: () => _open(QuestwellDestination.chronicle)),
                  onOpen: (key) => _open(key == 'quests'
                      ? QuestwellDestination.quests
                      : QuestwellDestination.expedition),
                ),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Sample Hearth · Changes stay in this preview',
                        textAlign: TextAlign.center,
                        style: QuestwellTypography.body(
                            fontSize: 11, color: const Color(0xFFB9C7D7)))),
              ]))),
        ),
      );
}
