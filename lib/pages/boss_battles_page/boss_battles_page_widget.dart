import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_boss_service.dart';
import '/services/questwell_progression.dart';
import '/services/questwell_milestone_service.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_boss_encounter.dart';
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
  QuestwellCosmeticsSnapshot? _appearance;

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
      setState(() {
        _campfireMode = data.profile.campfireMode;
        _appearance = data;
      });
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
  String _bossWeakness(String type) {
    switch (type) {
      case 'meeting_mimic':
        return 'A clear agenda and one decision at a time.';
      case 'spreadsheet_slime':
        return 'Small cleanups, one tab or formula at a time.';
      case 'calendar_kraken':
        return 'Protect one block of time and cut the tentacles.';
      case 'printer_poltergeist':
        return 'A single physical next step and zero superstition.';
      case 'notification_swarm':
        return 'Silence the noise, then clear one channel.';
      case 'ticket_troll':
        return 'Define done and close the oldest useful ticket.';
      case 'update_dragon':
        return 'Break the upgrade into safe, boring checkpoints.';
      default:
        return 'One reply, one thread, one head at a time.';
    }
  }

  String _bossStrategy(String type) {
    switch (type) {
      case 'meeting_mimic':
        return 'Attack the outcome, not the whole meeting.';
      case 'spreadsheet_slime':
        return 'Reduce the mess before adding more logic.';
      case 'calendar_kraken':
        return 'Defend your next useful hour.';
      case 'printer_poltergeist':
        return 'Make the machine prove the next failure.';
      case 'notification_swarm':
        return 'Batch the alerts instead of chasing them.';
      case 'ticket_troll':
        return 'Move the queue by finishing one concrete item.';
      case 'update_dragon':
        return 'Ship the smallest safe change first.';
      default:
        return 'Shrink the inbox until the next action is obvious.';
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
      final profile = (await QuestwellCosmeticService.load()).profile;
      final result = await QuestwellBossService.completeStep(step.id);
      if (!mounted) return;
      setState(_refresh);

      if (result.bossCompleted) {
        final previousLevel = QuestwellProgression.levelForXp(result.totalXp - result.xpAwarded,
          legacyOffset: profile.levelXpOffset);
        final newLevel = QuestwellProgression.levelForXp(result.totalXp, legacyOffset: profile.levelXpOffset);
        if (await showQuestwellMilestones(context, previousLevel: previousLevel, level: newLevel,
            xpAwarded: result.xpAwarded, coinsAwarded: result.coinsAwarded)) {
          if (mounted) setState(_refresh);
          return;
        }
        if (!mounted) return;
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
                    bossVictory: true,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${_bossName(battle.bossType)} is down. +${result.xpAwarded} XP • +${result.coinsAwarded} coins',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.roboto(),
                      letterSpacing: 0,
                    ),
                  ),
                ],
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
                      font: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                      ),
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
                      font: GoogleFonts.roboto(
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

                      try {
                        await QuestwellBossService.createBattle(
                          title: title,
                          steps: steps,
                          bossType: bossType,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not start this Boss Battle. Please try again.',
                            ),
                          ),
                        );
                      }
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
      backgroundColor: const Color(0xFF111827),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBattle,
        backgroundColor: const Color(0xFF6E3B2C),
        foregroundColor: const Color(0xFFF6E7BE),
        icon: const QuestwellNavPixelIcon(
          kind: 'boss',
          size: 20,
        ),
        label: Text(
          'NEW BOSS',
          style: GoogleFonts.pressStart2p(fontSize: 9),
        ),
      ),
      body: SafeArea(
        top: true,
        child: FutureBuilder<List<QuestwellBossBattle>>(
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
                        font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
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
                        font: GoogleFonts.roboto(
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
                        font: GoogleFonts.roboto(),
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
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
              itemCount: visibleBattles.length + (_campfireMode ? 1 : 0) + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          QuestwellTopActionButton(
                            kind: 'back',
                            tooltip: 'Back to the Hearth',
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BOSS BATTLES',
                                  style: theme.headlineMedium.override(
                                    font: GoogleFonts.pressStart2p(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    fontSize: 21,
                                    color: const Color(0xFFF2D9A0),
                                    letterSpacing: .5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Turn intimidating office work into a fight you can win.',
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: const Color(0xFFB7C4D4),
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const QuestwellNavPixelIcon(
                            kind: 'boss',
                            size: 36,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const QuestwellPixelDivider(
                        accent: Color(0xFFE87947),
                      ),
                    ],
                  );
                }

                final contentIndex = index - 1;

                if (_campfireMode && contentIndex == 0) {
                  return QuestwellRetroPanel(
                    padding: const EdgeInsets.all(14),
                    accent: const Color(0xFFE87947),
                    background: const Color(0xFF1A1512),
                    child: Row(
                      children: [
                        const QuestwellStatusPixelBadge(
                          kind: 'campfire',
                          size: 32,
                          active: true,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Campfire Mode: one boss, one attack. The rest can wait.',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.roboto(
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
                    visibleBattles[contentIndex - (_campfireMode ? 1 : 0)];
                final remainingSteps =
                    battle.steps.where((step) => !step.completed).toList();
                final isFeatured =
                    openBattles.isNotEmpty && battle.id == openBattles.first.id;

                return QuestwellRetroPanel(
                  padding: const EdgeInsets.all(16),
                  accent: battle.completed
                      ? const Color(0xFF5A5B62)
                      : const Color(0xFFE87947),
                  background: const Color(0xFF15141B),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (const ['inbox_hydra', 'meeting_mimic'].contains(battle.bossType))
                        QuestwellBossEncounter(
                          key: ValueKey('encounter-${battle.id}'),
                          encounterId: battle.id,
                          bossType: battle.bossType,
                          progress: battle.progress,
                          defeated: battle.completed,
                          archetype: _appearance?.profile.adventurerArchetype ?? 'wanderer',
                          body: _appearance?.profile.avatarBodyType ?? 'neutral',
                          equipment: {for (final item in _appearance?.cosmetics ?? <QuestwellCosmetic>[])
                            if (item.equipped) item.renderKey: item.slug},
                        )
                      else
                        QuestwellBossPixelArt(bossType: battle.bossType, height: isFeatured ? 245 : 160),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          QuestwellBossSigilPixelArt(
                            bossType: battle.bossType,
                            size: 48,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _bossName(battle.bossType),
                                  style: theme.labelMedium.override(
                                    font: GoogleFonts.roboto(
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
                                    font: GoogleFonts.roboto(
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              battle.completed
                                  ? 'BOSS DEFEATED'
                                  : '${battle.completedSteps} / ${battle.totalSteps} ATTACKS',
                              style: theme.labelSmall.override(
                                font: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w800,
                                ),
                                color: battle.completed
                                    ? theme.secondaryText
                                    : theme.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Text(
                            battle.completed
                                ? '0% HP'
                                : '${((1 - battle.progress) * 100).round()}% HP',
                            style: theme.labelSmall.override(
                              font: GoogleFonts.roboto(
                                fontWeight: FontWeight.w800,
                              ),
                              color: theme.secondaryText,
                              letterSpacing: .6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      if (!const ['inbox_hydra', 'meeting_mimic'].contains(battle.bossType)) QuestwellPixelMeter(
                        value: battle.completed ? 0 : 1 - battle.progress,
                        kind: 'hp',
                        height: 18,
                        segments: 14,
                      ),
                      if (isFeatured && !battle.completed) ...[
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 680;
                            final boxWidth = wide
                                ? (constraints.maxWidth - 16) / 3
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                SizedBox(
                                  width: boxWidth,
                                  child: _BossIntelCard(
                                    label: 'WEAKNESS',
                                    value: _bossWeakness(battle.bossType),
                                    kind: 'quest',
                                  ),
                                ),
                                SizedBox(
                                  width: boxWidth,
                                  child: _BossIntelCard(
                                    label: 'VICTORY LOOT',
                                    value:
                                        '+${battle.rewardXp} XP • +${battle.rewardCoins} coins',
                                    kind: 'coin',
                                  ),
                                ),
                                SizedBox(
                                  width: boxWidth,
                                  child: _BossIntelCard(
                                    label: 'STRATEGY',
                                    value: _bossStrategy(battle.bossType),
                                    kind: 'boss',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                      if (!battle.completed && remainingSteps.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        for (final step in remainingSteps
                            .take(_campfireMode ? 1 : 3)) ...[
                          QuestwellParchmentPanel(
                            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                            child: Row(
                              children: [
                                const QuestwellNavPixelIcon(
                                  kind: 'quest',
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    step.title,
                                    style: theme.bodyMedium.override(
                                      font: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: const Color(0xFF30261D),
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: _busyStepId == step.id
                                      ? null
                                      : () => _completeStep(battle, step),
                                  child: Text(
                                    _busyStepId == step.id
                                        ? 'Attacking...'
                                        : 'ATTACK',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Victory loot: +${battle.rewardXp} XP • +${battle.rewardCoins} coins',
                        style: theme.labelMedium.override(
                          font: GoogleFonts.roboto(
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
      ),
    );
  }
}

class _BossIntelCard extends StatelessWidget {
  const _BossIntelCard({
    required this.label,
    required this.value,
    required this.kind,
  });

  final String label;
  final String value;
  final String kind;

  @override
  Widget build(BuildContext context) {
    final icon = kind == 'coin'
        ? const QuestwellCurrencyPixelIcon(kind: 'coin', size: 22)
        : QuestwellNavPixelIcon(kind: kind, size: 22);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1824),
        border: Border.all(
          color: const Color(0xFF6A4C2C),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF2D9A0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB7C4D4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
