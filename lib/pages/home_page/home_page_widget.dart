import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/questwell_task_service.dart';
import '/services/questwell_cosmetic_service.dart';
import '/services/questwell_chronicle_service.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_home_sections.dart';
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
    }, onError: (Object error, StackTrace stackTrace) {
      // FutureBuilder displays the load error. Handle this side-effect future
      // too so a failed profile sync is not reported as an uncaught exception.
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
        await context.pushNamed(QuestBoardPageWidget.routeName);
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
        backgroundColor: const Color(0xFF111827),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF111B2B),
                Color(0xFF111827),
                Color(0xFF17120F),
              ],
              stops: [0, .56, 1],
            ),
          ),
          child: SafeArea(
            top: true,
            child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuestwellBrandWordmark(
                            compact:
                                MediaQuery.sizeOf(context).width < 390,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    QuestwellTopActionButton(
                      kind: 'quest',
                      tooltip: 'Quest Board',
                      onTap: () async {
                        await context.pushNamed(QuestBoardPageWidget.routeName);
                        if (mounted) setState(_loadHomeData);
                      },
                    ),
                    const SizedBox(width: 8),
                    QuestwellTopActionButton(
                      kind: 'chronicle',
                      tooltip: 'Chronicle',
                      onTap: () async {
                        await context.pushNamed(
                          ChroniclePageWidget.routeName,
                        );
                        if (mounted) setState(_loadHomeData);
                      },
                    ),
                    const SizedBox(width: 8),
                    QuestwellTopActionButton(
                      kind: 'adventurer',
                      tooltip: 'Adventurer',
                      onTap: () async {
                        await context.pushNamed(
                          AdventurerPageWidget.routeName,
                        );
                        if (mounted) setState(_loadHomeData);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const QuestwellPixelDivider(
                  accent: Color(0xFFD6A84B),
                ),
                const SizedBox(height: 12),
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
                    final compact =
                        MediaQuery.sizeOf(context).width < 430;
                    return QuestwellHearthPixelScene(
                      height: compact ? 342 : 392,
                      archetype: archetype,
                      avatarBodyType: data?.profile.avatarBodyType ?? 'neutral',
                      showRelic: mastered,
                      equippedSlugs: {
                        for (final item in equipped)
                          item.category: item.slug,
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
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
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    final profile = data.profile;
                    final equipped =
                        data.cosmetics.where((item) => item.equipped).toList();
                    final classMastered = data.cosmetics.any(
                      (item) =>
                          item.requiredArchetype ==
                              profile.adventurerArchetype &&
                          item.unlockMethod == 'class_mastery' &&
                          item.owned,
                    );
                    final xpIntoLevel = profile.totalXp % 100;
                    final progress = xpIntoLevel / 100.0;

                    return QuestwellRetroPanel(
                      padding: const EdgeInsets.all(16),
                      accent: const Color(0xFFD6A84B),
                      background: const Color(0xFF141820),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              QuestwellRelicPixelArt(
                                archetype: profile.adventurerArchetype,
                                size: 58,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _archetypeLabel(profile.adventurerArchetype)
                                          .toUpperCase(),
                                      style: theme.titleMedium.override(
                                        font: GoogleFonts.pressStart2p(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        fontSize: 13,
                                        color: const Color(0xFFF4D58A),
                                        letterSpacing: .7,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'LEVEL ${profile.level} • HEARTH ADVENTURER',
                                      style: theme.bodyMedium.override(
                                        font: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        fontSize: 11,
                                        color: const Color(0xFFB9C7D7),
                                        letterSpacing: .3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (classMastered)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B1510),
                                    border: Border.all(
                                      color: const Color(0xFFF1C75B),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    'MASTERED',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 7,
                                      color: const Color(0xFFF1C75B),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              _RewardChip(
                                icon: Icons.monetization_on_outlined,
                                label: '${profile.coinBalance} coins',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          QuestwellPixelMeter(
                            value: progress,
                            kind: 'xp',
                            height: 16,
                            segments: 12,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '$xpIntoLevel / 100 XP to next level',
                            style: theme.labelSmall.override(
                              font: GoogleFonts.roboto(),
                              color: theme.secondaryText,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            equipped.isEmpty
                                ? 'LOADOUT • No gear equipped'
                                : 'LOADOUT • ${equipped.take(3).map((item) => item.name).join(' • ')}',
                            softWrap: true,
                            style: theme.labelSmall.override(
                              font: GoogleFonts.roboto(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFFB9C7D7),
                              fontSize: 11,
                              letterSpacing: .15,
                            ),
                          ),
                          if (equipped.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final item in equipped.take(4))
                                  QuestwellItemPixelArt(
                                    slug: item.slug,
                                    category: item.category,
                                    archetype: item.requiredArchetype,
                                    size: 42,
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          const QuestwellPixelDivider(
                            accent: Color(0xFF6A4C2C),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CLASS COLLECTION',
                            style: theme.labelSmall.override(
                              font: GoogleFonts.pressStart2p(
                                fontWeight: FontWeight.w700,
                              ),
                              fontSize: 8,
                              color: const Color(0xFFD6A84B),
                              letterSpacing: .8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final item in data.cosmetics.where(
                                (item) =>
                                    item.requiredArchetype ==
                                        profile.adventurerArchetype &&
                                    item.unlockMethod == 'shop',
                              ).take(3))
                                Opacity(
                                  opacity: item.owned ? 1 : .38,
                                  child: QuestwellItemPixelArt(
                                    slug: item.slug,
                                    category: item.category,
                                    archetype: item.requiredArchetype,
                                    size: 46,
                                    locked: !item.owned,
                                  ),
                                ),
                              if (classMastered)
                                QuestwellRelicPixelArt(
                                  archetype: profile.adventurerArchetype,
                                  size: 46,
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

                    return QuestwellRetroPanel(
                      padding: const EdgeInsets.all(14),
                      accent: const Color(0xFFD6A84B),
                      background: const Color(0xFF171A20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuestwellStatusPixelBadge(
                            kind: 'momentum',
                            size: 44,
                            active: hasWins,
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
                                    font: GoogleFonts.pressStart2p(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    fontSize: 12,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  hasWins
                                      ? '${momentum.weekWins} win${momentum.weekWins == 1 ? '' : 's'} this week • ${momentum.bossesDefeated} boss${momentum.bossesDefeated == 1 ? '' : 'es'} defeated'
                                      : 'Welcome back. No catching up required. Pick one thing.',
                                  style: theme.bodySmall.override(
                                    font: GoogleFonts.roboto(),
                                    color: theme.secondaryText,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Open Chronicle',
                            onPressed: () async {
                              await context.pushNamed(
                                ChroniclePageWidget.routeName,
                              );
                              if (mounted) setState(_loadHomeData);
                            },
                            icon: const QuestwellNavPixelIcon(
                              kind: 'chronicle',
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (!_onboardingCompleted) ...[
                  const SizedBox(height: 18),
                  QuestwellRetroPanel(
                    padding: const EdgeInsets.all(16),
                    accent: const Color(0xFFF1C75B),
                    background: const Color(0xFF1A1714),
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
                                  font: GoogleFonts.pressStart2p(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  fontSize: 11,
                                  lineHeight: 1.5,
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
                            font: GoogleFonts.roboto(),
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
                if (_campfireMode) ...[
                  const SizedBox(height: 18),
                  const QuestwellExpeditionPixelScene(
                    height: 130,
                    campfire: true,
                  ),
                ],
                const SizedBox(height: 18),
                QuestwellRetroPanel(
                  padding: const EdgeInsets.all(14),
                  accent: _campfireMode
                      ? const Color(0xFFE87947)
                      : const Color(0xFF8E6B35),
                  background: _campfireMode
                      ? const Color(0xFF241712)
                      : const Color(0xFF171A20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      QuestwellStatusPixelBadge(
                        kind: 'campfire',
                        size: 44,
                        active: _campfireMode,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CAMPFIRE MODE',
                              style: theme.titleMedium.override(
                                font: GoogleFonts.pressStart2p(
                                  fontWeight: FontWeight.w700,
                                ),
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _campfireMode
                                  ? 'Today counts even if we go small. One quest at a time.'
                                  : 'Low-energy day? Narrow the board to one gentle next step.',
                              style: theme.bodySmall.override(
                                font: GoogleFonts.roboto(),
                                color: theme.secondaryText,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      QuestwellPixelToggle(
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
                  _campfireMode ? 'ONE SMALL WIN' : 'YOUR NEXT WIN',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.pressStart2p(
                      fontWeight: FontWeight.w700,
                    ),
                    fontSize: 15,
                    color: const Color(0xFFF2D9A0),
                    letterSpacing: 0.4,
                  ),
                ),
                if (_campfireMode) ...[
                  const SizedBox(height: 5),
                  Text(
                    'No catching up. No penalty. Just the next thing.',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.roboto(),
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
                                'The Quest Board could not refresh right now.',
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.roboto(),
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
                      return const QuestwellHomeEmptyBoard();
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
                QuestwellHomeActions(onOpen: (destination) async {
                  final route = switch (destination) {
                    'quests' => QuestBoardPageWidget.routeName,
                    'expedition' => ExpeditionPageWidget.routeName,
                    'boss' => BossBattlesPageWidget.routeName,
                    'chronicle' => ChroniclePageWidget.routeName,
                    'adventurer' => AdventurerPageWidget.routeName,
                    _ => MarketPageWidget.routeName,
                  };
                  await context.pushNamed(route);
                  if (mounted) setState(_loadHomeData);
                }),
              ],
            ),
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

    return QuestwellRetroPanel(
      padding: EdgeInsets.all(featured ? 18 : 14),
      accent: featured
          ? const Color(0xFFF1C75B)
          : const Color(0xFF8E6B35),
      background: const Color(0xFF15141B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featured)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'NEXT UP',
                style: theme.labelSmall.override(
                  font: GoogleFonts.pressStart2p(
                    fontWeight: FontWeight.w700,
                  ),
                  fontSize: 8,
                  color: const Color(0xFFF1C75B),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          Row(
            children: [
              QuestwellFrictionPixelBadge(
                level: task.frictionLevel ?? 0,
                size: 34,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  frictionLabel,
                  style: theme.labelMedium.override(
                    font: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (task.title?.trim().isNotEmpty ?? false)
                ? task.title!
                : 'Untitled quest',
            style: (featured ? theme.titleLarge : theme.titleMedium).override(
              font: GoogleFonts.roboto(fontWeight: FontWeight.w800),
              color: featured ? const Color(0xFFF2E7CE) : theme.primaryText,
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
            text: completing ? 'COMPLETING...' : 'COMPLETE QUEST',
            options: FFButtonOptions(
              width: double.infinity,
              height: featured ? 48 : 44,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              color: featured ? theme.primary : theme.primaryBackground,
              textStyle: theme.titleSmall.override(
                font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                color: featured ? Colors.white : theme.primaryText,
                letterSpacing: 0,
              ),
              elevation: 0,
              borderSide: featured ? null : BorderSide(color: theme.alternate),
              borderRadius: BorderRadius.circular(2),
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
        color: const Color(0xFF0D0C11),
        border: Border.all(
          color: const Color(0xFF4C3A24),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon == Icons.monetization_on_outlined
              ? const QuestwellCurrencyPixelIcon(kind: 'coin', size: 17)
              : icon == Icons.auto_awesome
                  ? const QuestwellCurrencyPixelIcon(kind: 'xp', size: 17)
                  : Icon(icon, size: 16, color: theme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.labelMedium.override(
              font: GoogleFonts.roboto(
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
