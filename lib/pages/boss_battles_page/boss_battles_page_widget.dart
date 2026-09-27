import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_boss_service.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_pixel_art.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BossBattlesPageWidget extends StatefulWidget {
  const BossBattlesPageWidget({super.key});

  static String routeName = 'BossBattlesPage';
  static String routePath = '/boss-battles';

  @override
  State<BossBattlesPageWidget> createState() => _BossBattlesPageWidgetState();
}

class _BossBattlesPageWidgetState extends State<BossBattlesPageWidget> {
  late Future<List<QuestwellBossBattle>> _future;
  String? _busyStepId;
  bool _campfireMode = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _loadCampfireMode();
  }

  void _refresh() {
    _future = QuestwellBossService.loadBattles();
  }

  Future<void> _loadCampfireMode() async {
    try {
      final data = await QuestwellCosmeticService.load();
      if (!mounted) return;
      setState(() => _campfireMode = data.profile.campfireMode);
    } catch (_) {
      // Boss Battles still works if profile mode cannot be loaded.
    }
  }

  String _bossName(String type) {
    switch (type) {
      case 'meeting_mimic':
        return 'Meeting Mimic';
      case 'spreadsheet_slime':
        return 'Spreadsheet Slime';
      case 'calendar_kraken':
        return 'Calendar Kraken';
      case 'printer_poltergeist':
        return 'Printer Poltergeist';
      case 'notification_swarm':
        return 'Notification Swarm';
      case 'ticket_troll':
        return 'Ticket Troll';
      case 'update_dragon':
        return 'Update Dragon';
      default:
        return 'Inbox Hydra';
    }
  }

  IconData _bossIcon(String type) {
    switch (type) {
      case 'meeting_mimic':
        return Icons.groups_outlined;
      case 'spreadsheet_slime':
        return Icons.grid_on_outlined;
      case 'calendar_kraken':
        return Icons.calendar_month_outlined;
      case 'printer_poltergeist':
        return Icons.print_outlined;
      case 'notification_swarm':
        return Icons.notifications_active_outlined;
      case 'ticket_troll':
        return Icons.confirmation_number_outlined;
      case 'update_dragon':
        return Icons.system_update_alt_outlined;
      default:
        return Icons.mark_email_unread_outlined;
    }
  }

  Future<void> _completeStep(
    QuestwellBossBattle battle,
    QuestwellBossStep step,
  ) async {
    if (_busyStepId != null) return;
    setState(() => _busyStepId = step.id);

    try {
      final result = await QuestwellBossService.completeStep(step.id);
      if (!mounted) return;
      setState(_refresh);

      if (result.bossCompleted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            final theme = FlutterFlowTheme.of(dialogContext);
            return AlertDialog(
              backgroundColor: theme.secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.workspace_premium_outlined, color: theme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Boss Defeated!',
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
              content: Text(
                '${_bossName(battle.bossType)} is down. +${result.xpAwarded} XP • +${result.coinsAwarded} coins',
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Claim Victory'),
                ),
              ],
            );
          },
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
    final titleController = TextEditingController();
    final stepControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    var bossType = 'inbox_hydra';

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
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
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w700,
                      ),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Turn one intimidating office project into smaller attacks.',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(),
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
                  DropdownButtonFormField<String>(
                    initialValue: bossType,
                    decoration: const InputDecoration(labelText: 'Boss'),
                    items: const [
                      DropdownMenuItem(
                        value: 'inbox_hydra',
                        child: Text('Inbox Hydra'),
                      ),
                      DropdownMenuItem(
                        value: 'meeting_mimic',
                        child: Text('Meeting Mimic'),
                      ),
                      DropdownMenuItem(
                        value: 'spreadsheet_slime',
                        child: Text('Spreadsheet Slime'),
                      ),
                      DropdownMenuItem(
                        value: 'calendar_kraken',
                        child: Text('Calendar Kraken'),
                      ),
                      DropdownMenuItem(
                        value: 'printer_poltergeist',
                        child: Text('Printer Poltergeist'),
                      ),
                      DropdownMenuItem(
                        value: 'notification_swarm',
                        child: Text('Notification Swarm'),
                      ),
                      DropdownMenuItem(
                        value: 'ticket_troll',
                        child: Text('Ticket Troll'),
                      ),
                      DropdownMenuItem(
                        value: 'update_dragon',
                        child: Text('Update Dragon'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setSheetState(() => bossType = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Attack plan',
                    style: theme.titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w700,
                      ),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < stepControllers.length; i++) ...[
                    TextField(
                      controller: stepControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Step ${i + 1}',
                      ),
                    ),
                    if (i != stepControllers.length - 1)
                      const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final steps = stepControllers
                          .map((controller) => controller.text.trim())
                          .where((value) => value.isNotEmpty)
                          .toList();

                      if (title.isEmpty || steps.length < 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Add a boss title and at least two attack steps.',
                            ),
                          ),
                        );
                        return;
                      }

                      await QuestwellBossService.createBattle(
                        title: title,
                        steps: steps,
                        bossType: bossType,
                      );
                      if (context.mounted) Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.sports_mma_outlined),
                    label: const Text('Start Boss Battle'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    titleController.dispose();
    for (final controller in stepControllers) {
      controller.dispose();
    }

    if (created == true && mounted) {
      setState(_refresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        foregroundColor: theme.primaryText,
        title: Text(
          'Boss Battles',
          style: theme.titleLarge.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
            letterSpacing: 0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBattle,
        icon: const Icon(Icons.add),
        label: const Text('New Boss'),
      ),
      body: FutureBuilder<List<QuestwellBossBattle>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 48, color: theme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'The office monsters slipped away.',
                      style: theme.titleMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(_refresh),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final battles = snapshot.data!;
          final openBattles =
              battles.where((battle) => !battle.completed).toList();
          final visibleBattles = _campfireMode && openBattles.isNotEmpty
              ? openBattles.take(1).toList()
              : battles;

          if (battles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mail_lock_outlined,
                      size: 58,
                      color: theme.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No office monsters yet.',
                      style: theme.titleLarge.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Turn the next intimidating project into a Boss Battle.',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: theme.secondaryText,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(_refresh);
              await Future.wait([
                _future,
                _loadCampfireMode(),
              ]);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: visibleBattles.length + (_campfireMode ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (_campfireMode && index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Campfire Mode: one boss, one attack. The rest can wait.',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final battle =
                    visibleBattles[index - (_campfireMode ? 1 : 0)];
                final remainingSteps =
                    battle.steps.where((step) => !step.completed).toList();

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: battle.completed
                          ? theme.alternate
                          : theme.primary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuestwellBossPixelArt(
                        bossType: battle.bossType,
                        height: 132,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.primaryBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _bossIcon(battle.bossType),
                              color: theme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _bossName(battle.bossType),
                                  style: theme.labelMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: theme.primary,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  battle.title,
                                  style: theme.titleMedium.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        battle.completed
                            ? 'DEFEATED'
                            : '${battle.completedSteps} of ${battle.totalSteps} attacks landed',
                        style: theme.labelSmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                          ),
                          color: theme.secondaryText,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: battle.progress,
                          minHeight: 10,
                          backgroundColor: theme.primaryBackground,
                        ),
                      ),
                      if (!battle.completed && remainingSteps.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        for (final step in remainingSteps
                            .take(_campfireMode ? 1 : 3)) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: _busyStepId == step.id
                                    ? null
                                    : () => _completeStep(battle, step),
                                child: Text(
                                  _busyStepId == step.id
                                      ? 'Attacking...'
                                      : 'Attack',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Victory loot: +${battle.rewardXp} XP • +${battle.rewardCoins} coins',
                        style: theme.labelMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                          color: theme.secondaryText,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
