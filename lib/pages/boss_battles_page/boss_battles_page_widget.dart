import '/widgets/questwell_app_navigation.dart';
import '/backend/supabase/questwell_network.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_boss_service.dart';
import '/services/questwell_progression.dart';
import '/services/questwell_milestone_service.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_boss_board.dart';
import '/widgets/questwell_boss_picker.dart';
import '/models/questwell_boss_unlocks.dart';
import '/pages/home_page/home_page_widget.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BossBattlesPageWidget extends StatefulWidget {
  const BossBattlesPageWidget({
    super.key,
    this.loadBattles = QuestwellBossService.loadBattles,
    this.loadAppearance = QuestwellCosmeticService.load,
    this.createBattle = QuestwellBossService.createBattle,
  });

  final Future<List<QuestwellBossBattle>> Function() loadBattles;
  final Future<QuestwellCosmeticsSnapshot> Function() loadAppearance;
  final Future<String> Function({
    required String title,
    required List<String> steps,
    String bossType,
  })
  createBattle;

  static String routeName = 'BossBattlesPage';
  static String routePath = '/boss-battles';

  @override
  State<BossBattlesPageWidget> createState() => _BossBattlesPageWidgetState();
}

class _BossBattlesPageWidgetState extends State<BossBattlesPageWidget> {
  late Future<List<QuestwellBossBattle>> _future;
  String? _busyStepId;
  String? _createdBattleId;
  bool _campfireMode = false;
  QuestwellCosmeticsSnapshot? _appearance;

  @override
  void initState() {
    super.initState();
    _refresh();
    _loadCampfireMode();
  }

  void _refresh() {
    _future = widget.loadBattles();
  }

  Future<void> _loadCampfireMode() async {
    try {
      final data = await widget.loadAppearance();
      if (!mounted) return;
      setState(() {
        _campfireMode = data.profile.campfireMode;
        _appearance = data;
      });
    } catch (_) {
      // Boss Battles still works if profile mode cannot be loaded.
    }
  }

  String _bossName(String type) => questwellBossNames[type] ?? 'Inbox Hydra';

  Future<void> _completeStep(
    QuestwellBossBattle battle,
    QuestwellBossStep step,
  ) async {
    if (_busyStepId != null) return;
    setState(() => _busyStepId = step.id);

    try {
      final profile = (await QuestwellCosmeticService.load()).profile;
      final result = await QuestwellBossService.completeStep(step.id);
      if (!mounted) return;
      setState(_refresh);

      if (result.bossCompleted) {
        await _loadCampfireMode();
        if (!mounted) return;
        final previousLevel = QuestwellProgression.levelForXp(
          result.totalXp - result.xpAwarded,
          legacyOffset: profile.levelXpOffset,
        );
        final newLevel = QuestwellProgression.levelForXp(
          result.totalXp,
          legacyOffset: profile.levelXpOffset,
        );
        if (await showQuestwellMilestones(
          context,
          previousLevel: previousLevel,
          level: newLevel,
          xpAwarded: result.xpAwarded,
          coinsAwarded: result.coinsAwarded,
        )) {
          if (mounted) setState(_refresh);
          return;
        }
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => Dialog(
            backgroundColor: const Color(0xFF101923),
            shape: const RoundedRectangleBorder(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QuestwellBossVictoryPanel(
                      bossName: _bossName(battle.bossType),
                      xp: result.xpAwarded,
                      coins: result.coinsAwarded,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Return to battles'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not complete this boss step. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyStepId = null);
    }
  }

  Future<void> _showCreateBattle() async {
    await _loadCampfireMode();
    if (!mounted) return;
    final profile = _appearance?.profile;
    final level = profile?.level ?? 1;
    final titleController = TextEditingController();
    final stepControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    var bossType = 'inbox_hydra';
    var submitting = false;
    String? errorMessage;
    ModalRoute<dynamic>? creationRoute;

    final created = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        creationRoute = ModalRoute.of(sheetContext);
        final theme = FlutterFlowTheme.of(sheetContext);
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Summon a Boss Battle',
                    style: theme.titleLarge.override(
                      font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Turn one intimidating office project into smaller attacks.',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.roboto(),
                      color: theme.secondaryText,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'What are you taking down?',
                      hintText: 'Clear the quarterly email backlog',
                    ),
                  ),
                  const SizedBox(height: 14),
                  QuestwellBossUnlockProgress(
                    level: level,
                    totalXp: profile?.totalXp ?? 0,
                    offset: profile?.levelXpOffset ?? 0,
                    known: profile != null,
                  ),
                  const SizedBox(height: 12),
                  QuestwellBossPicker(
                    value: bossType,
                    level: level,
                    onChanged: (value) => setSheetState(() => bossType = value),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Attack plan',
                    style: theme.titleMedium.override(
                      font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < stepControllers.length; i++) ...[
                    TextField(
                      controller: stepControllers[i],
                      decoration: InputDecoration(labelText: 'Step ${i + 1}'),
                    ),
                    if (i != stepControllers.length - 1)
                      const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => setSheetState(() {
                      stepControllers.add(TextEditingController());
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Add step'),
                  ),
                  const SizedBox(height: 18),
                  if (errorMessage != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: theme.error),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton.icon(
                    onPressed: submitting
                        ? null
                        : () async {
                            if (submitting) return;
                            final title = titleController.text.trim();
                            final steps = stepControllers
                                .map((controller) => controller.text.trim())
                                .where((value) => value.isNotEmpty)
                                .toList();

                            if (title.isEmpty || steps.length < 2) {
                              setSheetState(
                                () => errorMessage = 'Add a boss title and at least two attack steps.',
                              );
                              return;
                            }

                            if (!QuestwellBossUnlocks.available(
                              bossType,
                              level,
                            )) {
                              setSheetState(
                                () => errorMessage = 'Choose an unlocked boss.',
                              );
                              return;
                            }
                            setSheetState(() {
                              submitting = true;
                              errorMessage = null;
                            });
                            try {
                              final battleId = await widget.createBattle(
                                title: title,
                                steps: steps,
                                bossType: bossType,
                              );
                              if (battleId.trim().isEmpty) {
                                throw const QuestwellNetworkException(
                                  'The server did not confirm your battle. Close this form and refresh before trying again.',
                                );
                              }
                              if (context.mounted) {
                                Navigator.of(context).pop(battleId);
                              }
                            } catch (error) {
                              if (!context.mounted) return;
                              setSheetState(() {
                                submitting = false;
                                errorMessage =
                                    error is QuestwellNetworkException
                                    ? error.message
                                    : 'Could not start this Boss Battle. Your draft is saved here. Please try again.';
                              });
                            }
                          },
                    icon: const Icon(Icons.sports_mma_outlined),
                    label: Text(submitting ? 'Starting…' : 'Start Boss Battle'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // The pop result arrives before the sheet finishes its exit animation.
    // Keep controllers alive until its overlay entries have been removed.
    await creationRoute?.completed;
    titleController.dispose();
    for (final controller in stepControllers) {
      controller.dispose();
    }

    if (created != null && created.isNotEmpty && mounted) {
      setState(() {
        _createdBattleId = created;
        _refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const QuestwellAppNavigation(
      current: QuestwellDestination.bosses,
    ),
    backgroundColor: const Color(0xFF111827),
    body: SafeArea(
      child: FutureBuilder<List<QuestwellBossBattle>>(
        future: _future,
        builder: (context, snapshot) => QuestwellBossBoard(
          battles: snapshot.data ?? const [],
          initialBattleId: _createdBattleId,
          unlockProgress: QuestwellBossUnlockProgress(
            level: _appearance?.profile.level ?? 1,
            totalXp: _appearance?.profile.totalXp ?? 0,
            offset: _appearance?.profile.levelXpOffset ?? 0,
            known: _appearance != null,
          ),
          loading: !snapshot.hasData && !snapshot.hasError,
          failed: snapshot.hasError,
          busyStepId: _busyStepId,
          campfire: _campfireMode,
          archetype: _appearance?.profile.adventurerArchetype ?? 'wanderer',
          body: _appearance?.profile.avatarBodyType ?? 'neutral',
          equipment: {
            for (final item in _appearance?.cosmetics ?? <QuestwellCosmetic>[])
              if (item.equipped) item.renderKey: item.slug,
          },
          onHome: () => context.goNamed(HomePageWidget.routeName),
          onCreate: _showCreateBattle,
          onAttack: _completeStep,
          onRetry: () => setState(_refresh),
          onRefresh: () async {
            setState(_refresh);
            try {
              await Future.wait([_future, _loadCampfireMode()]);
            } catch (_) {
              /* FutureBuilder displays the retry state. */
            }
          },
        ),
      ),
    ),
  );
}
