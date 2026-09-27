import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/questwell_task_service.dart';
import '/services/questwell_cosmetic_service.dart';
import '/services/questwell_chronicle_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

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
  bool _creatingStarterQuest = false;
  late Future<QuestwellCosmeticsSnapshot> _homeSnapshotFuture;
  late Future<ChronicleSnapshot> _momentumFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _loadHomeData();
  }

  void _loadHomeData() {
    _homeSnapshotFuture = QuestwellCosmeticService.load();
    _momentumFuture = QuestwellChronicleService.load();
    _homeSnapshotFuture.then((data) {
      if (!mounted) return;
      if (_campfireMode != data.profile.campfireMode ||
          _onboardingCompleted != data.profile.onboardingCompleted) {
        setState(() {
          _campfireMode = data.profile.campfireMode;
          _onboardingCompleted = data.profile.onboardingCompleted;
        });
      }
    });
  }

  Future<void> _finishOnboarding() async {
    try {
      await QuestwellCosmeticService.completeOnboarding();
      if (!mounted) return;
      setState(() {
        _onboardingCompleted = true;
        _loadHomeData();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not finish setup. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _startWithQuest({
    required String title,
    required int friction,
    required int xp,
    required int coins,
  }) async {
    if (_creatingStarterQuest) return;
    setState(() => _creatingStarterQuest = true);

    try {
      await TasksTable().insert({
        'user_id': currentUserUid,
        'title': title,
        'friction_level': friction,
        'xp_value': xp,
        'coin_value': coins,
        'status': 'open',
      });
      await QuestwellCosmeticService.completeOnboarding();

      if (!mounted) return;
      setState(() {
        _onboardingCompleted = true;
        _loadHomeData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First quest added. Your adventure has started.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not add that starter quest. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _creatingStarterQuest = false);
    }
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
      final reward = await QuestwellTaskService.completeTask(taskId);

      if (!mounted) return;

      final previousXp = reward.totalXp - reward.xpAwarded;
      final previousLevel = (previousXp ~/ 100) + 1;
      final newLevel = (reward.totalXp ~/ 100) + 1;
      final leveledUp = newLevel > previousLevel;
      final firstWin = previousXp == 0 && reward.xpAwarded > 0;

      setState(_loadHomeData);

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
                      font: GoogleFonts.interTight(
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
                Text(
                  firstWin
                      ? 'That is the loop: do one real thing, earn progress, and keep the momentum.'
                      : leveledUp
                          ? 'Your adventurer reached Level $newLevel.'
                          : 'A small win became real momentum.',
                  style: dialogTheme.bodyMedium.override(
                    font: GoogleFonts.inter(),
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
                    font: GoogleFonts.inter(
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
                onPressed: () =>
                    Navigator.of(dialogContext).pop('chronicle'),
                child: const Text('See Chronicle'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop('add'),
                child: const Text('Add Next Quest'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop('continue'),
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
        await context.pushNamed(AddTaskPageWidget.routeName);
        if (mounted) setState(_loadHomeData);
      } else if (nextAction == 'chronicle') {
        await context.pushNamed(ChroniclePageWidget.routeName);
        if (mounted) setState(_loadHomeData);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not complete this quest. Please try again.'),
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Questwell',
                  style: theme.headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Small wins. Real momentum.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 22),
                FutureBuilder<QuestwellCosmeticsSnapshot>(
                  future: _homeSnapshotFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_off_outlined, color: theme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'The Hearth could not refresh right now.',
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.inter(),
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
                      return Container(
                        height: 104,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    final data = snapshot.data!;
                    final profile = data.profile;
                    final equipped =
                        data.cosmetics.where((item) => item.equipped).toList();
                    final xpIntoLevel = profile.totalXp % 100;
                    final progress = xpIntoLevel / 100.0;

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: theme.alternate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.primaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: theme.primary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'The Hearth',
                                      style: theme.titleMedium.override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Level ${profile.level} ${_archetypeLabel(profile.adventurerArchetype)}',
                                      style: theme.bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: theme.secondaryText,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _RewardChip(
                                icon: Icons.monetization_on_outlined,
                                label: '${profile.coinBalance} coins',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: theme.primaryBackground,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$xpIntoLevel / 100 XP to next level',
                                style: theme.labelSmall.override(
                                  font: GoogleFonts.inter(),
                                  color: theme.secondaryText,
                                  letterSpacing: 0,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  equipped.isEmpty
                                      ? 'No gear equipped'
                                      : equipped
                                          .take(2)
                                          .map((item) => item.name)
                                          .join(' • '),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.labelSmall.override(
                                    font: GoogleFonts.inter(),
                                    color: theme.secondaryText,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                FutureBuilder<ChronicleSnapshot>(
                  future: _momentumFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final momentum = snapshot.data!;
                    final hasWins = momentum.weekWins > 0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: theme.alternate),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.primaryBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hasWins
                                  ? Icons.auto_graph_outlined
                                  : Icons.wb_sunny_outlined,
                              color: theme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasWins
                                      ? 'Momentum is building'
                                      : 'Fresh start',
                                  style: theme.titleMedium.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  hasWins
                                      ? '${momentum.weekWins} win${momentum.weekWins == 1 ? '' : 's'} this week • ${momentum.bossesDefeated} boss${momentum.bossesDefeated == 1 ? '' : 'es'} defeated'
                                      : 'Welcome back. No catching up required. Pick one thing.',
                                  style: theme.bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: theme.secondaryText,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await context.pushNamed(
                                ChroniclePageWidget.routeName,
                              );
                              if (mounted) setState(_loadHomeData);
                            },
                            child: const Text('Chronicle'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (!_onboardingCompleted) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.primary, width: 1.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: theme.primary),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Welcome to Questwell',
                                style: theme.titleLarge.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Pick one tiny real-life win. Completing it earns your first XP and coins.',
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: theme.secondaryText,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: _creatingStarterQuest
                                  ? null
                                  : () => _startWithQuest(
                                        title: 'Reply to one email',
                                        friction: 1,
                                        xp: 10,
                                        coins: 5,
                                      ),
                              child: const Text('Reply to one email'),
                            ),
                            OutlinedButton(
                              onPressed: _creatingStarterQuest
                                  ? null
                                  : () => _startWithQuest(
                                        title: 'Clear five desktop files',
                                        friction: 1,
                                        xp: 10,
                                        coins: 5,
                                      ),
                              child: const Text('Clear five files'),
                            ),
                            OutlinedButton(
                              onPressed: _creatingStarterQuest
                                  ? null
                                  : () => _startWithQuest(
                                        title: 'Do the thing I keep avoiding',
                                        friction: 3,
                                        xp: 35,
                                        coins: 18,
                                      ),
                              child: const Text('Do the avoided thing'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              _creatingStarterQuest ? null : _finishOnboarding,
                          child: const Text('I already know what I want to do'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _campfireMode
                        ? theme.secondaryBackground
                        : theme.primaryBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _campfireMode ? theme.primary : theme.alternate,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _campfireMode
                              ? Icons.local_fire_department_outlined
                              : Icons.bolt_outlined,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Campfire Mode',
                              style: theme.titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _campfireMode
                                  ? 'Today counts even if we go small. One quest at a time.'
                                  : 'Low-energy day? Narrow the board to one gentle next step.',
                              style: theme.bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: theme.secondaryText,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: _campfireMode,
                        onChanged: _changingEnergyMode
                            ? null
                            : (value) => _setCampfireMode(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _campfireMode ? 'One Small Win' : 'Your Next Win',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    letterSpacing: 0,
                  ),
                ),
                if (_campfireMode) ...[
                  const SizedBox(height: 5),
                  Text(
                    'No catching up. No penalty. Just the next thing.',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: theme.secondaryText,
                      letterSpacing: 0,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FutureBuilder<List<TasksRow>>(
                  future: TasksTable().queryRows(
                    queryFn: (q) => q
                        .eqOrNull('user_id', currentUserUid)
                        .eqOrNull('status', 'open')
                        .order('created_at', ascending: true),
                    limit: 50,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_off_outlined, color: theme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'The Quest Board could not refresh right now.',
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final tasks = snapshot.data!;
                    final campfireTasks = List<TasksRow>.from(tasks)
                      ..sort(
                        (a, b) => (a.frictionLevel ?? 99)
                            .compareTo(b.frictionLevel ?? 99),
                      );
                    final visibleTasks = _campfireMode
                        ? campfireTasks.take(1).toList()
                        : tasks.take(3).toList();

                    if (visibleTasks.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The quest board is clear.',
                              style: theme.titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No catching up required. Add one thing when you are ready.',
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: theme.secondaryText,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (var index = 0; index < visibleTasks.length; index++) ...[
                          _QuestCard(
                            task: visibleTasks[index],
                            frictionLabel: _frictionLabel(visibleTasks[index].frictionLevel),
                            completing: _completingTask,
                            featured: index == 0,
                            onComplete: () => _completeTask(visibleTasks[index]),
                          ),
                          if (index != visibleTasks.length - 1)
                            const SizedBox(height: 10),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                FFButtonWidget(
                  onPressed: () async {
                    await context.pushNamed(AddTaskPageWidget.routeName);
                    if (mounted) setState(_loadHomeData);
                  },
                  text: '+ Add Quest',
                  options: FFButtonOptions(
                    height: 46,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    color: theme.secondaryBackground,
                    textStyle: theme.titleSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w700,
                      ),
                      color: theme.primaryText,
                      letterSpacing: 0,
                    ),
                    elevation: 0,
                    borderSide: BorderSide(
                      color: theme.alternate,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.pushNamed(BossBattlesPageWidget.routeName);
                          if (mounted) setState(_loadHomeData);
                        },
                        icon: const Icon(Icons.sports_mma_outlined),
                        label: const Text('Boss Battles'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: theme.primaryText,
                          side: BorderSide(color: theme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.pushNamed(ChroniclePageWidget.routeName);
                          if (mounted) setState(_loadHomeData);
                        },
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Chronicle'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: theme.primaryText,
                          side: BorderSide(color: theme.alternate),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.pushNamed(AdventurerPageWidget.routeName);
                          if (mounted) setState(_loadHomeData);
                        },
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Adventurer'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          foregroundColor: theme.primaryText,
                          side: BorderSide(color: theme.alternate),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.pushNamed(MarketPageWidget.routeName);
                          if (mounted) setState(_loadHomeData);
                        },
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text('Market'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          foregroundColor: theme.primaryText,
                          side: BorderSide(color: theme.alternate),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _QuestCard extends StatelessWidget {
  const _QuestCard({
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
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: EdgeInsets.all(featured ? 20 : 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: featured ? theme.primary : theme.alternate,
          width: featured ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featured)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'NEXT UP',
                style: theme.labelSmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  color: theme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          Text(
            frictionLabel,
            style: theme.labelMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: theme.secondaryText,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (task.title?.trim().isNotEmpty ?? false)
                ? task.title!
                : 'Untitled quest',
            style: (featured ? theme.titleLarge : theme.titleMedium).override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RewardChip(
                icon: Icons.auto_awesome,
                label: '+${task.xpValue ?? 0} XP',
              ),
              _RewardChip(
                icon: Icons.monetization_on_outlined,
                label: '+${task.coinValue ?? 0} coins',
              ),
            ],
          ),
          const SizedBox(height: 14),
          FFButtonWidget(
            onPressed: completing ? null : onComplete,
            text: completing ? 'Completing...' : 'Complete Quest',
            options: FFButtonOptions(
              width: double.infinity,
              height: featured ? 48 : 44,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              color: featured ? theme.primary : theme.primaryBackground,
              textStyle: theme.titleSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                color: featured ? Colors.white : theme.primaryText,
                letterSpacing: 0,
              ),
              elevation: 0,
              borderSide: featured ? null : BorderSide(color: theme.alternate),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.labelMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
