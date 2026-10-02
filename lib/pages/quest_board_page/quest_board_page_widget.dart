import '/widgets/questwell_app_navigation.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/questwell_boss_service.dart';
import '/services/questwell_task_service.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_quest_card.dart';
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
  int _completedThisVisit = 0;
  String? _busyTaskId;
  bool _settingAside = false;
  Set<String> _favoriteTaskIds = <String>{};
  late Future<List<TasksRow>> _tasksFuture;
  late Future<List<QuestwellBossBattle>> _bossFuture;

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
          .order('created_at', ascending: false),
      limit: 50,
    );
    _bossFuture = QuestwellBossService.loadBattles();
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
        return 'Annoying';
      case 3:
        return 'Hard to Start';
      case 4:
        return 'Brain Says Absolutely Not';
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

  Future<void> _setAside(TasksRow task) async {
    if (_busyTaskId != null || task.id == null) return;
    setState(() { _busyTaskId = task.id; _settingAside = true; });
    try {
      await QuestwellTaskService.setAside(task.id!);
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Quest set aside. No penalty. Restore it from Chronicle whenever you’re ready.'),
        action: SnackBarAction(label: 'Chronicle',
          onPressed: () async {
            await context.pushNamed(ChroniclePageWidget.routeName);
            if (mounted) setState(_refresh);
          }),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not set this quest aside. Refresh and try again.')));
    } finally {
      if (mounted) setState(() { _busyTaskId = null; _settingAside = false; });
    }
  }

  Future<void> _edit(TasksRow task) async {
    if (_busyTaskId != null || task.id == null) return;
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (editContext) => AddTaskPageWidget(
        editing: true, initialTitle: task.title ?? '',
        initialFriction: task.frictionLevel ?? 0,
        initialXp: task.xpValue ?? 0, initialCoins: task.coinValue ?? 0,
        onFinished: (saved) => Navigator.of(editContext).pop(saved),
        onCreate: (title, friction, xp, coins) async {
          final rows = await TasksTable().update(data: {
            'title': title, 'friction_level': friction, 'xp_value': xp, 'coin_value': coins,
          }, matchingRows: (q) => q.eqOrNull('id', task.id)
            .eqOrNull('user_id', currentUserUid).eqOrNull('status', 'open'),
            returnRows: true);
          if (rows.length != 1) throw StateError('This quest is no longer open.');
        },
      ),
    ));
    if (!mounted) return;
    setState(() { if (saved == true) _filter = 'today'; _refresh(); });
    if (saved == true) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Quest updated.'), behavior: SnackBarBehavior.floating));
  }

  Future<void> _complete(TasksRow task) async {
    if (task.id == null || _busyTaskId != null) return;
    setState(() => _busyTaskId = task.id);
    try {
      final result = await QuestwellTaskService.completeTask(task.id!);
      if (!mounted) return;
      setState(() { _completedThisVisit++; _refresh(); });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Quest complete! +${result.xpAwarded} XP · +${result.coinsAwarded} coins'),
      ));
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

    return Scaffold(
        bottomNavigationBar: const QuestwellAppNavigation(current: QuestwellDestination.quests),
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(_refresh);
            await Future.wait([_tasksFuture, _bossFuture]);
          },
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            children: [
              QuestwellBoardHeading(completed: _completedThisVisit, onAdd: () async {
                final posted = await context.pushNamed<bool>(AddTaskPageWidget.routeName);
                if (!mounted) return;
                setState(() {
                  if (posted == true) _filter = 'today';
                  _refresh();
                });
                if (posted == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Quest posted to your board.'),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                  children: [
                    QuestwellBoardFilter(
                      label: 'All quests',
                      icon: Icons.calendar_today_outlined,
                      selected: _filter == 'today',
                      onTap: () => setState(() => _filter = 'today'),
                    ),
                    QuestwellBoardFilter(
                      label: 'Low Energy',
                      icon: Icons.bolt_outlined,
                      selected: _filter == 'low',
                      onTap: () => setState(() => _filter = 'low'),
                    ),
                    QuestwellBoardFilter(
                      label: 'Bigger quests',
                      icon: Icons.landscape_outlined,
                      selected: _filter == 'high',
                      onTap: () => setState(() => _filter = 'high'),
                    ),
                    QuestwellBoardFilter(
                      label: 'Bosses',
                      icon: Icons.sports_mma_outlined,
                      selected: _filter == 'boss',
                      onTap: () => setState(() => _filter = 'boss'),
                    ),
                    QuestwellBoardFilter(
                      label: 'Pinned',
                      icon: Icons.star_border,
                      selected: _filter == 'favorites',
                      onTap: () => setState(() => _filter = 'favorites'),
                    ),
                  ],
              ),
              const SizedBox(height: 14),
              if (_filter == 'boss') FutureBuilder<List<QuestwellBossBattle>>(
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
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF7E7C1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          boss.title,
                          style: GoogleFonts.roboto(
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
                              style: GoogleFonts.roboto(
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
                _filter == 'boss' ? 'BOSS QUESTS' : 'YOUR NEXT WIN',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: const Color(0xFFF2D9A0),
                ),
              ),
              const SizedBox(height: 10),
              if (_filter != 'boss')
                FutureBuilder<List<TasksRow>>(
                  future: _tasksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(children: [
                        const Text('Your quests could not load.', style: TextStyle(color: Colors.white)),
                        TextButton(onPressed: () => setState(_refresh), child: const Text('Try again')),
                      ]);
                    }
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
                              ? 'No pinned quests yet. Tap a pin to keep an important quest here.'
                              : 'No quests in this lane right now.',
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF4B3A28),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    return QuestwellNoticeboard(child: Column(
                      children: [
                        for (final task in visible) ...[
                          QuestwellQuestCard(
                            title: task.title ?? '',
                            effort: _frictionLabel(task.frictionLevel),
                            xp: task.xpValue ?? 0,
                            coins: task.coinValue ?? 0,
                            busy: _busyTaskId == task.id,
                            busyLabel: _settingAside ? 'Setting aside…' : 'Completing…',
                            favorite: task.id != null &&
                                _favoriteTaskIds.contains(task.id),
                            onFavorite: () => _toggleFavorite(task),
                            onEdit: _busyTaskId == null ? () => _edit(task) : null,
                            onSetAside: _busyTaskId == null ? () => _setAside(task) : null,
                            onComplete: _busyTaskId == null ? () => _complete(task) : null,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ));
                  },
                ),
              if (_filter == 'boss')
                QuestwellParchmentPanel(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Open Boss Battles to manage every office monster and attack step.',
                    style: GoogleFonts.roboto(
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
                        style: GoogleFonts.roboto(
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
          ))),
        ),
      ),
    );
  }
}
