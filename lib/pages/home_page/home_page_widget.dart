import '/widgets/questwell_home_quest.dart';
import '/widgets/questwell_app_navigation.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/questwell_task_service.dart';
import '/services/questwell_open_task_list.dart';
import '/services/questwell_progression.dart';
import '/services/questwell_milestone_service.dart';
import '/services/questwell_cosmetic_service.dart';
import '/services/questwell_onboarding_session.dart';
import '/widgets/questwell_onboarding_panel.dart';
import '/services/questwell_chronicle_service.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_next_reward.dart';
import '/widgets/questwell_home_sections.dart';
import '/widgets/questwell_home_overview.dart';
import '/widgets/questwell_campfire_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({
    super.key,
    this.loadAppearance = QuestwellCosmeticService.load,
    this.loadMomentum = QuestwellChronicleService.load,
    this.loadTasks = QuestwellOpenTaskList.loadCurrent,
    this.completeTask = QuestwellTaskService.completeTask,
  });

  final Future<QuestwellCosmeticsSnapshot> Function() loadAppearance;
  final Future<ChronicleSnapshot> Function() loadMomentum;
  final Future<List<TasksRow>> Function() loadTasks;
  final Future<QuestwellTaskCompletionResult> Function(String) completeTask;

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _completingTask = false;
  bool _campfireMode = false;
  bool _changingEnergyMode = false;
  bool _onboardingCompleted = true;
  QuestwellOnboardingSession? _onboardingSession;
  late Future<QuestwellCosmeticsSnapshot> _homeSnapshotFuture;
  late Future<ChronicleSnapshot> _momentumFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _loadHomeData();
    QuestwellCosmeticService.changes.addListener(_cosmeticsChanged);
  }

  void _loadHomeData() {
    _loadCosmetics();
    _momentumFuture = widget.loadMomentum();
    // Keep early refresh errors observed until FutureBuilder attaches.
    // The same future still exposes its error to the momentum retry UI.
    _momentumFuture.ignore();
  }

  void _cosmeticsChanged() {
    if (mounted) setState(_loadCosmetics);
  }

  void _loadCosmetics() {
    final request = widget.loadAppearance();
    _homeSnapshotFuture = request;
    _homeSnapshotFuture.then((data) {
      if (!mounted || !identical(request, _homeSnapshotFuture)) return;
      if (_campfireMode != data.profile.campfireMode ||
          _onboardingCompleted != data.profile.onboardingCompleted) {
        setState(() {
          _campfireMode = data.profile.campfireMode;
          _onboardingCompleted = data.profile.onboardingCompleted;
        });
      }
    }, onError: (Object error, StackTrace stackTrace) {
      // FutureBuilder displays the load error. Handle this side-effect future
      // too so a failed profile sync is not reported as an uncaught exception.
    });
  }

  Future<QuestwellOnboardingResult> _finishOnboarding(String? starterKey) {
    if (_onboardingSession?.ownerId != currentUserUid) {
      _onboardingSession = QuestwellCosmeticService.newOnboardingSession();
    }
    final session =
        _onboardingSession ??= QuestwellCosmeticService.newOnboardingSession();
    return session.finish(starterKey);
  }

  void _onboardingFinished() {
    if (!mounted) return;
    setState(() {
      _onboardingCompleted = true;
      _loadHomeData();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Setup complete. Your quest board is ready.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _setCampfireMode(bool enabled) async {
    if (_changingEnergyMode) return;
    setState(() => _changingEnergyMode = true);

    try {
      await QuestwellCosmeticService.setEnergyMode(
        enabled ? 'campfire' : 'normal',
      );
      if (!mounted) return;
      setState(() {
        _campfireMode = enabled;
        _loadHomeData();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not change energy mode. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _changingEnergyMode = false);
    }
  }

  @override
  void dispose() {
    QuestwellCosmeticService.changes.removeListener(_cosmeticsChanged);
    _model.dispose();
    super.dispose();
  }

  String _archetypeLabel(String value) {
    switch (value) {
      case 'scholar':
        return 'Scholar';
      case 'scout':
        return 'Scout';
      case 'alchemist':
        return 'Alchemist';
      case 'guardian':
        return 'Guardian';
      default:
        return 'Wanderer';
    }
  }

  IconData _archetypeIcon(String value) {
    switch (value) {
      case 'scholar':
        return Icons.menu_book_outlined;
      case 'scout':
        return Icons.explore_outlined;
      case 'alchemist':
        return Icons.science_outlined;
      case 'guardian':
        return Icons.shield_outlined;
      default:
        return Icons.hiking_outlined;
    }
  }

  String _frictionLabel(int? level) {
    switch (level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Annoying';
      case 3:
        return 'Hard to Start';
      case 4:
        return 'Brain Says Absolutely Not';
      default:
        return 'Quest';
    }
  }

  Future<void> _completeTask(TasksRow task) async {
    final taskId = task.id;
    if (taskId == null || _completingTask) return;

    setState(() => _completingTask = true);

    try {
      final profile = (await _homeSnapshotFuture).profile;
      final reward = await widget.completeTask(taskId);

      if (!mounted) return;

      final previousXp = reward.totalXp - reward.xpAwarded;
      final previousLevel = QuestwellProgression.levelForXp(previousXp,
          legacyOffset: profile.levelXpOffset);
      final newLevel = QuestwellProgression.levelForXp(reward.totalXp,
          legacyOffset: profile.levelXpOffset);
      final leveledUp = newLevel > previousLevel;
      final firstWin = previousXp == 0 && reward.xpAwarded > 0;

      setState(_loadHomeData);

      if (await showQuestwellMilestones(context,
          previousLevel: previousLevel,
          level: newLevel,
          xpAwarded: reward.xpAwarded,
          coinsAwarded: reward.coinsAwarded)) {
        if (mounted) setState(_loadHomeData);
        return;
      }

      if (!mounted) return;
      final nextAction = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          final dialogTheme = FlutterFlowTheme.of(dialogContext);
          return AlertDialog(
            backgroundColor: dialogTheme.secondaryBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  leveledUp ? Icons.auto_awesome : Icons.task_alt,
                  color: dialogTheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    firstWin
                        ? 'Your First Win!'
                        : leveledUp
                            ? 'Level Up!'
                            : 'Quest Complete!',
                    style: dialogTheme.titleLarge.override(
                      font: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                      ),
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const QuestwellVictoryPixelArt(
                  height: 100,
                  bossVictory: false,
                ),
                const SizedBox(height: 14),
                Text(
                  firstWin
                      ? 'That is the loop: do one real thing, earn progress, and keep the momentum.'
                      : leveledUp
                          ? 'Your adventurer reached Level $newLevel.'
                          : 'A small win became real momentum.',
                  style: dialogTheme.bodyMedium.override(
                    font: GoogleFonts.roboto(),
                    color: dialogTheme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RewardChip(
                      icon: Icons.auto_awesome,
                      label: '+${reward.xpAwarded} XP',
                    ),
                    _RewardChip(
                      icon: Icons.monetization_on_outlined,
                      label: '+${reward.coinsAwarded} coins',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Balance: ${reward.coinBalance} coins • ${reward.totalXp} total XP',
                  style: dialogTheme.labelMedium.override(
                    font: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                    ),
                    color: dialogTheme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('chronicle'),
                child: const Text('See Chronicle'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('add'),
                child: const Text('Add Next Quest'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop('continue'),
                child: Text(
                  firstWin
                      ? 'Keep Going'
                      : leveledUp
                          ? 'Continue Adventure'
                          : 'Claim Win',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      if (nextAction == 'add') {
        await context.pushNamed(QuestBoardPageWidget.routeName);
        if (mounted) setState(_loadHomeData);
      } else if (nextAction == 'chronicle') {
        await context.pushNamed(ChroniclePageWidget.routeName);
        if (mounted) setState(_loadHomeData);
      }
    } catch (_) {
      if (!mounted) return;
      // A rejected/lost reply can follow a committed completion. Reconcile
      // server state and totals without sending the completion again.
      setState(_loadHomeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completion was not confirmed. Check the refreshed board before trying again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _completingTask = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final openTasks = widget.loadTasks();

    final overview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder<QuestwellCosmeticsSnapshot>(
          future: _homeSnapshotFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return QuestwellRetroPanel(
                padding: const EdgeInsets.all(14),
                accent: const Color(0xFFE87947),
                background: const Color(0xFF1A1512),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off_outlined, color: theme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'The Hearth could not refresh right now.',
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.roboto(),
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(_loadHomeData),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const QuestwellRetroPanel(
                padding: EdgeInsets.all(20),
                accent: Color(0xFF8E6B35),
                child: SizedBox(
                  height: 64,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final data = snapshot.data!;
            final profile = data.profile;
            final equipped =
                data.cosmetics.where((item) => item.equipped).toList();
            final classMastered = data.cosmetics.any(
              (item) =>
                  item.requiredArchetype == profile.adventurerArchetype &&
                  item.unlockMethod == 'class_mastery' &&
                  item.owned,
            );
            final xpIntoLevel = profile.xpIntoLevel;

            return QuestwellHomeCharacter(
              compact: true,
              archetype: profile.adventurerArchetype,
              className: _archetypeLabel(profile.adventurerArchetype),
              level: profile.level,
              xp: xpIntoLevel,
              coins: profile.coinBalance,
              mastered: classMastered,
              equippedNames: equipped
                  .where(
                    (item) =>
                        item.category != 'room' && item.category != 'wall_art',
                  )
                  .map((item) => item.name)
                  .toList(),
              decorNames: equipped
                  .where(
                    (item) =>
                        item.category == 'room' || item.category == 'wall_art',
                  )
                  .map((item) => item.name)
                  .toList(),
              collection: const [],
              nextReward: QuestwellNextReward(cosmetics: data.cosmetics),
              onCustomize: () async {
                await context.pushNamed(AdventurerPageWidget.routeName);
                if (mounted) setState(_loadHomeData);
              },
              onMarket: () async {
                await context.pushNamed(MarketPageWidget.routeName);
                if (mounted) setState(_loadHomeData);
              },
            );
          },
        ),
      ],
    );
    final secondary = Column(children: [
      FutureBuilder<QuestwellCosmeticsSnapshot>(
          future: _homeSnapshotFuture,
          builder: (context, snapshot) => snapshot.hasData
              ? QuestwellNextReward(cosmetics: snapshot.data!.cosmetics)
              : const SizedBox.shrink()),
      FutureBuilder<ChronicleSnapshot>(
        future: _momentumFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final momentum = snapshot.data!;
          return QuestwellHomeMomentum(
            wins: momentum.weekWins,
            bosses: momentum.bossesDefeated,
            onOpen: () async {
              await context.pushNamed(ChroniclePageWidget.routeName);
              if (mounted) setState(_loadHomeData);
            },
          );
        },
      ),
    ]);

    Widget focusLayout(
      Widget nextWin, {
      List<Widget> remainingQuests = const [],
      bool emphasizeAddQuest = false,
    }) =>
        QuestwellHomeFocusLayout(
          nextWin: nextWin,
          overview: overview,
          gentle: _campfireMode,
          secondary: secondary,
          campfire: QuestwellHomeCampfireControl(
              active: _campfireMode,
              onChanged: _changingEnergyMode ? null : _setCampfireMode),
          remainingQuests: remainingQuests,
          emphasizeAddQuest: emphasizeAddQuest,
          onOpen: (destination) async {
            final route = destination == 'quests'
                ? QuestBoardPageWidget.routeName
                : ExpeditionPageWidget.routeName;
            await context.pushNamed(route);
            if (mounted) setState(_loadHomeData);
          },
        );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: const QuestwellAppNavigation(
          current: QuestwellDestination.hearth,
        ),
        key: scaffoldKey,
        backgroundColor: const Color(0xFF111827),
        body: QuestwellCampfireBackground(
          active: _campfireMode,
          child: SafeArea(
            top: true,
            child: QuestwellHomeCanvas(
              children: [
                FutureBuilder<QuestwellCosmeticsSnapshot>(
                  future: _homeSnapshotFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final archetype =
                        data?.profile.adventurerArchetype ?? 'wanderer';
                    final equipped = data?.cosmetics
                            .where((item) => item.equipped)
                            .toList() ??
                        const <QuestwellCosmetic>[];
                    final mastered = data?.cosmetics.any(
                          (item) =>
                              item.requiredArchetype == archetype &&
                              item.unlockMethod == 'class_mastery' &&
                              item.owned,
                        ) ??
                        false;
                    final roomWidth =
                        MediaQuery.sizeOf(context).width.clamp(0.0, 760.0);
                    return QuestwellHomeHero(
                        room: QuestwellHearthPixelScene(
                      immersive: true,
                      height: roomWidth * .72 + 40,
                      archetype: archetype,
                      avatarBodyType: data?.profile.avatarBodyType ?? 'neutral',
                      showRelic: mastered,
                      equippedSlugs: {
                        for (final item in equipped) item.renderKey: item.slug,
                      },
                      hearthProfileBySlug: {
                        for (final item
                            in data?.cosmetics ?? const <QuestwellCosmetic>[])
                          if (item.hearthProfileKey != null)
                            item.slug: item.hearthProfileKey!,
                      },
                      hearthRenderBySlug: {
                        for (final item
                            in data?.cosmetics ?? const <QuestwellCosmetic>[])
                          if (item.hearthRenderSpec != null)
                            item.slug: item.hearthRenderSpec!,
                      },
                    ));
                  },
                ),
                const SizedBox(height: 8),
                if (!_onboardingCompleted) ...[
                  const SizedBox(height: 18),
                  QuestwellOnboardingPanel(
                    key: ValueKey('onboarding-$currentUserUid'),
                    finish: _finishOnboarding,
                    onCompleted: _onboardingFinished,
                  ),
                ],
                FutureBuilder<List<TasksRow>>(
                  future: openTasks,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return focusLayout(
                        QuestwellRetroPanel(
                          padding: const EdgeInsets.all(14),
                          accent: const Color(0xFFE87947),
                          background: const Color(0xFF1A1512),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_off_outlined,
                                color: theme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'The Quest Board could not refresh right now.',
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.roboto(),
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState != ConnectionState.done ||
                        !snapshot.hasData) {
                      return focusLayout(
                        const Padding(
                          padding: EdgeInsets.all(28),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final tasks = snapshot.data!;
                    final visibleTasks = QuestwellTaskService.visibleHomeTasks(
                      tasks,
                      campfireMode: _campfireMode,
                    );

                    if (visibleTasks.isEmpty) {
                      return focusLayout(
                        const QuestwellHomeEmptyBoard(),
                        emphasizeAddQuest: true,
                      );
                    }

                    QuestwellHomeQuestCard card(int index) =>
                        QuestwellHomeQuestCard(
                          task: visibleTasks[index],
                          frictionLabel: _frictionLabel(
                            visibleTasks[index].frictionLevel,
                          ),
                          completing: _completingTask,
                          featured: index == 0,
                          onComplete: () => _completeTask(visibleTasks[index]),
                        );
                    return focusLayout(
                      card(0),
                      remainingQuests: [
                        for (var index = 1;
                            index < visibleTasks.length;
                            index++) ...[
                          card(index),
                          if (index != visibleTasks.length - 1)
                            const SizedBox(height: 10),
                        ],
                        if (tasks.length > visibleTasks.length) ...[
                          const SizedBox(height: 10),
                          Text(
                            _campfireMode
                                ? 'One gentle quest at a time. Your other quests are safe on the board.'
                                : 'More quests are waiting on your board.',
                            style: theme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () async {
                              await context.pushNamed(
                                QuestBoardPageWidget.routeName,
                              );
                              if (mounted) setState(_loadHomeData);
                            },
                            child: const Text('View all quests'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestwellHomeQuestCard extends StatelessWidget {
  const QuestwellHomeQuestCard({
    super.key,
    required this.task,
    required this.frictionLabel,
    required this.completing,
    required this.featured,
    required this.onComplete,
  });

  final TasksRow task;
  final String frictionLabel;
  final bool completing;
  final bool featured;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => QuestwellHearthQuestContent(
      title: (task.title?.trim().isNotEmpty ?? false)
          ? task.title!
          : 'Untitled quest',
      notes: task.notes,
      frictionLabel: frictionLabel,
      pinned: task.pinnedAt != null,
      xp: task.xpValue ?? 0,
      coins: task.coinValue ?? 0,
      completing: completing,
      featured: featured,
      onComplete: onComplete);
}
