import 'dart:async';
import '/widgets/questwell_account_dialog_flow.dart';
import '/widgets/questwell_quest_completion.dart';
import '/widgets/questwell_decorate_hearth.dart';
import '../../widgets/questwell_hearth_material.dart';
import '../../widgets/questwell_app_style.dart';
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
    this.currentOwner = _currentOwner,
    this.accountChanges,
  });

  final Future<QuestwellCosmeticsSnapshot> Function() loadAppearance;
  final Future<ChronicleSnapshot> Function() loadMomentum;
  final Future<List<TasksRow>> Function() loadTasks;
  final Future<QuestwellTaskCompletionResult> Function(String) completeTask;
  final String? Function() currentOwner;
  final Listenable? accountChanges;
  static String? _currentOwner() => currentUserUid;

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  bool _openingDecorator = false;

  Future<void> _decorateHearth() async {
    if (_openingDecorator) return;
    setState(() => _openingDecorator = true);
    try {
      final (appearance, layouts) = await (
        widget.loadAppearance(),
        QuestwellCosmeticService.loadHearthLayouts(),
      ).wait;
      if (!mounted) return;
      await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => QuestwellDecorateHearth(
              snapshot: appearance,
              layouts: layouts,
              onSave: (layout) =>
                  QuestwellCosmeticService.saveHearthLayout(layouts, layout)));
    } catch (_) {
      if (mounted)
        _showHomeFeedback(const SnackBar(
            content: Text('Could not open your room. Please try again.')));
    } finally {
      if (mounted) setState(() => _openingDecorator = false);
    }
  }

  late HomePageModel _model;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool _completingTask = false;
  QuestwellAccountDialogFlow? _completionFlow;
  var _homeMessenger = GlobalKey<ScaffoldMessengerState>();
  bool _campfireMode = false;
  bool _changingEnergyMode = false;
  bool _onboardingCompleted = true;
  QuestwellOnboardingSession? _onboardingSession;
  QuestwellProfile? _completionProfile;
  late Future<QuestwellCosmeticsSnapshot> _homeSnapshotFuture;
  late Future<ChronicleSnapshot> _momentumFuture;
  late Future<List<TasksRow>> _tasksFuture;
  String? _owner;
  int _accountGeneration = 0;
  bool _accountReconciliationScheduled = false;
  Listenable get _accountChanges =>
      widget.accountChanges ?? AppStateNotifier.instance;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _owner = widget.currentOwner();
    _refreshTasksAndHome();
    QuestwellCosmeticService.changes.addListener(_cosmeticsChanged);
    _accountChanges.addListener(_accountChanged);
  }

  @override
  void didUpdateWidget(covariant HomePageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountChanges != widget.accountChanges) {
      (oldWidget.accountChanges ?? AppStateNotifier.instance)
          .removeListener(_accountChanged);
      _accountChanges.addListener(_accountChanged);
    }
    _accountChanged();
  }

  void _accountChanged() {
    if (!mounted || _owner == widget.currentOwner()) return;
    _completionFlow?.cancel();
    _completionFlow = null;
    scaffoldKey = GlobalKey<ScaffoldState>();
    _homeMessenger = GlobalKey<ScaffoldMessengerState>();
    setState(() {
      _owner = widget.currentOwner();
      _accountGeneration++;
      _completingTask = false;
      _campfireMode = false;
      _onboardingCompleted = true;
      _onboardingSession = null;
      _refreshTasksAndHome();
    });
  }

  void _scheduleAccountReconciliation() {
    if (_accountReconciliationScheduled) return;
    _accountReconciliationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accountReconciliationScheduled = false;
      _accountChanged();
    });
  }

  void _loadTasks() {
    final owner = _owner;
    final generation = _accountGeneration;
    _tasksFuture = Future<List<TasksRow>>.sync(widget.loadTasks).then((tasks) {
      if (owner != widget.currentOwner() || generation != _accountGeneration) {
        throw StateError('The quest account changed. Reload your quests.');
      }
      return tasks;
    });
    _tasksFuture.ignore();
  }

  void _refreshTasksAndHome() {
    _loadTasks();
    _loadHomeData();
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
    _completionProfile = null;
    final request = widget.loadAppearance();
    _homeSnapshotFuture = request;
    _homeSnapshotFuture.then((data) {
      if (!mounted || !identical(request, _homeSnapshotFuture)) return;
      _completionProfile = data.profile;
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
      _refreshTasksAndHome();
    });
    _showHomeFeedback(
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
      _showHomeFeedback(
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
    _completionFlow?.cancel();
    _accountChanges.removeListener(_accountChanged);
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

  void _showHomeFeedback(SnackBar snackBar) {
    _homeMessenger.currentState?.showSnackBar(snackBar);
  }

  Future<void> _completeTask(
      TasksRow task, String? owner, int generation) async {
    bool isCurrentAccount() {
      final current = mounted &&
          owner == widget.currentOwner() &&
          generation == _accountGeneration;
      if (mounted && !current && _owner != widget.currentOwner()) {
        _scheduleAccountReconciliation();
      }
      return current;
    }

    if (!isCurrentAccount()) return;
    final taskId = task.id;
    if (taskId == null || _completingTask) return;

    final flow = QuestwellAccountDialogFlow(
        isCurrent: isCurrentAccount, accountChanges: _accountChanges);
    _completionFlow = flow;
    setState(() => _completingTask = true);

    try {
      final reward = await widget.completeTask(taskId);

      if (!isCurrentAccount()) return;

      // Appearance is optional presentation data, never a completion barrier.
      // Only use the current successful load for legacy level offsets.
      final profile = _completionProfile;
      setState(_refreshTasksAndHome);
      if (profile == null) {
        _showHomeFeedback(
          SnackBar(
            content: Text(
              'Quest complete. +${reward.xpAwarded} XP · +${reward.coinsAwarded} coins.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final previousXp = reward.totalXp - reward.xpAwarded;
      final previousLevel = QuestwellProgression.levelForXp(previousXp,
          legacyOffset: profile.levelXpOffset);
      final newLevel = QuestwellProgression.levelForXp(reward.totalXp,
          legacyOffset: profile.levelXpOffset);
      final leveledUp = newLevel > previousLevel;
      final firstWin = previousXp == 0 && reward.xpAwarded > 0;

      if (await showQuestwellMilestones(context,
          flow: flow,
          showFeedback: _showHomeFeedback,
          previousLevel: previousLevel,
          level: newLevel,
          xpAwarded: reward.xpAwarded,
          coinsAwarded: reward.coinsAwarded)) {
        if (isCurrentAccount()) setState(_loadHomeData);
        return;
      }

      if (!isCurrentAccount()) return;
      final nextAction = await QuestwellAccountDialogFlow.show<String>(
        context: context,
        flow: flow,
        builder: (dialogContext) => QuestwellQuestCompletionDialog(
          questTitle: task.title ?? 'Your quest',
          xpAwarded: reward.xpAwarded,
          coinsAwarded: reward.coinsAwarded,
          totalXp: reward.totalXp,
          coinBalance: reward.coinBalance,
          level: newLevel,
          firstWin: firstWin,
          leveledUp: leveledUp,
        ),
      );

      if (!isCurrentAccount()) return;
      if (nextAction == 'add') {
        await context.pushNamed(QuestBoardPageWidget.routeName);
        if (isCurrentAccount()) setState(_refreshTasksAndHome);
      } else if (nextAction == 'chronicle') {
        await context.pushNamed(ChroniclePageWidget.routeName);
        if (isCurrentAccount()) setState(_refreshTasksAndHome);
      }
    } catch (_) {
      if (!isCurrentAccount()) return;
      // A rejected/lost reply can follow a committed completion. Reconcile
      // server state and totals without sending the completion again.
      setState(_refreshTasksAndHome);
      _showHomeFeedback(
        const SnackBar(
          content: Text(
            'Completion was not confirmed. Check the refreshed board before trying again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      flow.cancel();
      if (identical(_completionFlow, flow)) _completionFlow = null;
      if (isCurrentAccount()) {
        setState(() => _completingTask = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auth navigation can suppress its notifier; never render another owner's
    // cached data while waiting for the route/widget update to reset this state.
    if (_owner != widget.currentOwner()) {
      _scheduleAccountReconciliation();
      return const SizedBox.shrink();
    }
    final theme = FlutterFlowTheme.of(context);

    final overview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder<QuestwellCosmeticsSnapshot>(
          future: _homeSnapshotFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return QuestwellHearthFrame(
                padding: const EdgeInsets.all(14),
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
              return const QuestwellHearthFrame(
                padding: EdgeInsets.all(20),
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
    final nextReward = FutureBuilder<QuestwellCosmeticsSnapshot>(
        future: _homeSnapshotFuture,
        builder: (context, snapshot) => snapshot.hasData
            ? QuestwellNextReward(cosmetics: snapshot.data!.cosmetics)
            : const SizedBox.shrink());
    final secondary = Column(children: [
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
              if (mounted) setState(_refreshTasksAndHome);
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
          reward: nextReward,
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
            if (mounted) {
              setState(destination == 'quests'
                  ? _refreshTasksAndHome
                  : _loadHomeData);
            }
          },
        );

    final content = GestureDetector(
      key: ValueKey(_accountGeneration),
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: QuestwellScaffold(
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
                      height: roomWidth * .68 + 8,
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
                if (decorateHearthEnabled)
                  OutlinedButton.icon(
                      onPressed: _openingDecorator ? null : _decorateHearth,
                      icon: const Icon(Icons.chair_outlined),
                      label: Text(_openingDecorator
                          ? 'Opening room…'
                          : 'Decorate Hearth')),
                if (!_onboardingCompleted) ...[
                  const SizedBox(height: 18),
                  QuestwellOnboardingPanel(
                    key: ValueKey('onboarding-$currentUserUid'),
                    finish: _finishOnboarding,
                    onCompleted: _onboardingFinished,
                  ),
                ],
                FutureBuilder<List<TasksRow>>(
                  key: ValueKey(_tasksFuture),
                  future: _tasksFuture,
                  builder: (context, snapshot) {
                    final owner = _owner;
                    final generation = _accountGeneration;
                    final request = _tasksFuture;
                    if (owner != widget.currentOwner()) {
                      _scheduleAccountReconciliation();
                      return const SizedBox.shrink();
                    }
                    if (snapshot.hasError) {
                      return focusLayout(
                        QuestwellHearthFrame(
                          padding: const EdgeInsets.all(14),
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
                              TextButton(
                                onPressed: () => setState(_loadTasks),
                                child: const Text('Retry quests'),
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
                          onComplete: () {
                            if (identical(request, _tasksFuture)) {
                              _completeTask(
                                  visibleTasks[index], owner, generation);
                            }
                          },
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
                              if (mounted) setState(_refreshTasksAndHome);
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
    return ScaffoldMessenger(key: _homeMessenger, child: content);
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
