import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/questwell_boss_service.dart';
import '/services/questwell_cosmetic_service.dart';
import '/services/questwell_task_service.dart';
import '/widgets/questwell_pixel_art.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestBoardPageWidget extends StatefulWidget {
  const QuestBoardPageWidget({super.key});

  static String routeName = 'QuestBoardPage';
  static String routePath = '/quest-board';

  @override
  State<QuestBoardPageWidget> createState() => _QuestBoardPageWidgetState();
}

class _QuestBoardPageWidgetState extends State<QuestBoardPageWidget> {
  String _filter = 'today';
  String? _busyTaskId;
  Set<String> _favoriteTaskIds = <String>{};
  late Future<List<TasksRow>> _tasksFuture;
  late Future<List<QuestwellBossBattle>> _bossFuture;
  late Future<QuestwellCosmeticsSnapshot> _cosmeticsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
    _loadFavorites();
  }

  String get _favoritesStorageKey =>
      'questwell_favorite_quests_${currentUserUid.isEmpty ? 'guest' : currentUserUid}';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesStorageKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _favoriteTaskIds = saved.toSet());
  }

  Future<void> _toggleFavorite(TasksRow task) async {
    final taskId = task.id;
    if (taskId == null) return;

    final updated = Set<String>.from(_favoriteTaskIds);
    if (!updated.add(taskId)) {
      updated.remove(taskId);
    }

    setState(() => _favoriteTaskIds = updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesStorageKey, updated.toList()..sort());
  }

  void _refresh() {
    _tasksFuture = TasksTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('status', 'open')
          .order('created_at', ascending: true),
      limit: 50,
    );
    _bossFuture = QuestwellBossService.loadBattles();
    _cosmeticsFuture = QuestwellCosmeticService.load();
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

  String _frictionLabel(int? level) {
    switch (level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Low Energy';
      case 3:
        return 'Hard to Start';
      case 4:
        return 'High Impact';
      default:
        return 'Quest';
    }
  }

  List<TasksRow> _filtered(List<TasksRow> tasks) {
    switch (_filter) {
      case 'low':
        return tasks.where((task) => (task.frictionLevel ?? 0) <= 2).toList();
      case 'high':
        return tasks.where((task) => (task.frictionLevel ?? 0) >= 3).toList();
      case 'boss':
        return const <TasksRow>[];
      case 'favorites':
        return tasks
            .where((task) => task.id != null && _favoriteTaskIds.contains(task.id))
            .toList();
      default:
        return tasks;
    }
  }

  Future<void> _complete(TasksRow task) async {
    if (task.id == null || _busyTaskId != null) return;
    setState(() => _busyTaskId = task.id);
    try {
      await QuestwellTaskService.completeTask(task.id!);
      if (!mounted) return;
      setState(_refresh);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not complete that quest. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyTaskId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1724),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.pushNamed(AddTaskPageWidget.routeName);
          if (mounted) setState(_refresh);
        },
        backgroundColor: const Color(0xFFD6A84B),
        foregroundColor: const Color(0xFF1B1712),
        icon: const Icon(Icons.add),
        label: Text(
          'NEW QUEST',
          style: GoogleFonts.pressStart2p(fontSize: 9),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(_refresh);
            await Future.wait([_tasksFuture, _bossFuture, _cosmeticsFuture]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
            children: [
              Row(
                children: [
                  QuestwellTopActionButton(
                    kind: 'back',
                    tooltip: 'Back to the Hearth',
                    onTap: () => context.safePop(),
                  ),
                  const SizedBox(width: 10),
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
                  QuestwellTopActionButton(
                    kind: 'chronicle',
                    tooltip: 'Chronicle',
                    onTap: () => context.pushNamed(
                      ChroniclePageWidget.routeName,
                    ),
                  ),
                  const SizedBox(width: 8),
                  QuestwellTopActionButton(
                    kind: 'adventurer',
                    tooltip: 'Adventurer',
                    onTap: () => context.pushNamed(
                      AdventurerPageWidget.routeName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const QuestwellPixelDivider(accent: Color(0xFFD6A84B)),
              const SizedBox(height: 12),
              QuestwellRetroPanel(
                padding: const EdgeInsets.all(10),
                accent: const Color(0xFFD6A84B),
                background: const Color(0xFF17151A),
                child: Column(
                  children: [
                    FutureBuilder<QuestwellCosmeticsSnapshot>(
                      future: _cosmeticsFuture,
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        final archetype =
                            data?.profile.adventurerArchetype ?? 'wanderer';
                        final equipped = data?.cosmetics
                                .where((item) => item.equipped)
                                .toList() ??
                            const <QuestwellCosmetic>[];
                        return QuestwellQuestBoardPixelArt(
                          height: 235,
                          clear: false,
                          archetype: archetype,
                          equippedSlugs: {
                            for (final item in equipped)
                              item.category: item.slug,
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'QUEST BOARD',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF2D9A0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose your next small win.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFB7C4D4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _BoardFilter(
                      label: 'Today',
                      icon: Icons.calendar_today_outlined,
                      selected: _filter == 'today',
                      onTap: () => setState(() => _filter = 'today'),
                    ),
                    _BoardFilter(
                      label: 'Low Energy',
                      icon: Icons.bolt_outlined,
                      selected: _filter == 'low',
                      onTap: () => setState(() => _filter = 'low'),
                    ),
                    _BoardFilter(
                      label: 'High Impact',
                      icon: Icons.landscape_outlined,
                      selected: _filter == 'high',
                      onTap: () => setState(() => _filter = 'high'),
                    ),
                    _BoardFilter(
                      label: 'Bosses',
                      icon: Icons.sports_mma_outlined,
                      selected: _filter == 'boss',
                      onTap: () => setState(() => _filter = 'boss'),
                    ),
                    _BoardFilter(
                      label: 'Favorites',
                      icon: Icons.star_border,
                      selected: _filter == 'favorites',
                      onTap: () => setState(() => _filter = 'favorites'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<QuestwellBossBattle>>(
                future: _bossFuture,
                builder: (context, snapshot) {
                  final boss = snapshot.data
                      ?.where((battle) => !battle.completed)
                      .cast<QuestwellBossBattle?>()
                      .firstWhere((battle) => battle != null, orElse: () => null);
                  if (boss == null) return const SizedBox.shrink();
                  return QuestwellRetroPanel(
                    padding: const EdgeInsets.all(12),
                    accent: const Color(0xFFE87947),
                    background: const Color(0xFF24151A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BOSS QUEST',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10,
                            color: const Color(0xFFFFD08A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        QuestwellBossPixelArt(
                          bossType: boss.bossType,
                          height: 205,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _bossName(boss.bossType),
                          style: GoogleFonts.interTight(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF7E7C1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          boss.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFFCFD7E3),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: QuestwellPixelMeter(
                                value: boss.completed ? 0 : 1 - boss.progress,
                                kind: 'hp',
                                height: 16,
                                segments: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '+${boss.rewardXp} XP • +${boss.rewardCoins} coins',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF1C75B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => context.pushNamed(
                              BossBattlesPageWidget.routeName,
                            ),
                            icon: const QuestwellNavPixelIcon(
                              kind: 'boss',
                              size: 20,
                            ),
                            label: const Text('START BOSS QUEST'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF205AD4),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                _filter == 'boss' ? 'BOSS QUESTS' : 'DAILY QUESTS',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: const Color(0xFFF2D9A0),
                ),
              ),
              const SizedBox(height: 10),
              if (_filter != 'boss')
                FutureBuilder<List<TasksRow>>(
                  future: _tasksFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final visible = _filtered(snapshot.data!);

                    if (visible.isEmpty) {
                      return QuestwellParchmentPanel(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          _filter == 'favorites'
                              ? 'No favorite quests yet. Tap the star on any quest to pin it here.'
                              : 'No quests in this lane right now.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4B3A28),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final task in visible) ...[
                          _DailyQuestCard(
                            task: task,
                            frictionLabel: _frictionLabel(task.frictionLevel),
                            busy: _busyTaskId == task.id,
                            favorite: task.id != null &&
                                _favoriteTaskIds.contains(task.id),
                            onToggleFavorite: () => _toggleFavorite(task),
                            onComplete: () => _complete(task),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    );
                  },
                ),
              if (_filter == 'boss')
                QuestwellParchmentPanel(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Open Boss Battles to manage every office monster and attack step.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF4B3A28),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              QuestwellRetroPanel(
                padding: const EdgeInsets.all(10),
                accent: const Color(0xFFD6A84B),
                background: const Color(0xFF17151A),
                child: Row(
                  children: [
                    const QuestwellStatusPixelBadge(
                      kind: 'campfire',
                      size: 42,
                      active: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A smaller, brighter tomorrow starts with one finished quest.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFCFD7E3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardFilter extends StatelessWidget {
  const _BoardFilter({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF2E0B4) : const Color(0xFF152234),
            border: Border.all(
              color: selected
                  ? const Color(0xFFE4B85E)
                  : const Color(0xFF43536A),
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
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? const Color(0xFF2D2418)
                    : const Color(0xFFE1D7C1),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? const Color(0xFF2D2418)
                      : const Color(0xFFE1D7C1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyQuestCard extends StatelessWidget {
  const _DailyQuestCard({
    required this.task,
    required this.frictionLabel,
    required this.busy,
    required this.favorite,
    required this.onToggleFavorite,
    required this.onComplete,
  });

  final TasksRow task;
  final String frictionLabel;
  final bool busy;
  final bool favorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return QuestwellRetroPanel(
      padding: const EdgeInsets.all(12),
      accent: const Color(0xFF8E6B35),
      background: const Color(0xFF111B29),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestwellFrictionPixelBadge(
            level: task.frictionLevel ?? 0,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        (task.title?.trim().isNotEmpty ?? false)
                            ? task.title!
                            : 'Untitled quest',
                        style: GoogleFonts.interTight(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF3E7CD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onToggleFavorite,
                      tooltip: favorite ? 'Remove favorite' : 'Favorite quest',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      icon: Icon(
                        favorite ? Icons.star : Icons.star_border,
                        size: 21,
                        color: favorite
                            ? const Color(0xFFF1C75B)
                            : const Color(0xFF7D8A9B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    QuestwellFrictionPixelBadge(
                      level: task.frictionLevel ?? 0,
                      size: 24,
                    ),
                    Text(
                      frictionLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFB7C4D4),
                      ),
                    ),
                    Text(
                      '+${task.xpValue ?? 0} XP',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB99BFF),
                      ),
                    ),
                    Text(
                      '+${task.coinValue ?? 0} coins',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF1C75B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: busy ? null : onComplete,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(busy ? 'FINISHING...' : 'COMPLETE'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF205AD4),
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
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
