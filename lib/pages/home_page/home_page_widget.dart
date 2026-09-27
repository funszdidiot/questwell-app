import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/questwell_task_service.dart';
import '/services/questwell_cosmetic_service.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quest complete! +${reward.xpAwarded} XP  •  +${reward.coinsAwarded} coins',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
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
          child: Padding(
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
                  future: QuestwellCosmeticService.load(),
                  builder: (context, snapshot) {
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
                                      'Level ${profile.level} Adventurer',
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
                              Text(
                                equipped.isEmpty
                                    ? 'No gear equipped'
                                    : '${equipped.length} equipped',
                                style: theme.labelSmall.override(
                                  font: GoogleFonts.inter(),
                                  color: theme.secondaryText,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Next Win',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<TasksRow>>(
                  future: TasksTable().queryRows(
                    queryFn: (q) => q
                        .eqOrNull('user_id', currentUserUid)
                        .eqOrNull('status', 'open')
                        .order('created_at', ascending: true),
                    limit: 1,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final tasks = snapshot.data!;
                    final task = tasks.elementAtOrNull(0);

                    if (task == null) {
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

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.alternate,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _frictionLabel(task.frictionLevel),
                            style: theme.labelMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: theme.secondaryText,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (task.title?.trim().isNotEmpty ?? false)
                                ? task.title!
                                : 'Untitled quest',
                            style: theme.titleLarge.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                              ),
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 18),
                          FFButtonWidget(
                            onPressed: _completingTask
                                ? null
                                : () async => _completeTask(task),
                            text: _completingTask
                                ? 'Completing...'
                                : 'Complete Quest',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 48,
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                              color: theme.primary,
                              textStyle: theme.titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                              elevation: 0,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                FFButtonWidget(
                  onPressed: () async {
                    await context.pushNamed(AddTaskPageWidget.routeName);
                    if (mounted) setState(() {});
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
                        onPressed: () =>
                            context.pushNamed(AdventurerPageWidget.routeName),
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
                        onPressed: () =>
                            context.pushNamed(MarketPageWidget.routeName),
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
