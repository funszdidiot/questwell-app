import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_task_page_model.dart';
export 'add_task_page_model.dart';

class AddTaskPageWidget extends StatefulWidget {
  const AddTaskPageWidget({super.key});

  static String routeName = 'AddTaskPage';
  static String routePath = '/addTaskPage';

  @override
  State<AddTaskPageWidget> createState() => _AddTaskPageWidgetState();
}

class _AddTaskPageWidgetState extends State<AddTaskPageWidget> {
  late AddTaskPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddTaskPageModel());
    _model.taskTitleFieldTextController ??= TextEditingController();
    _model.taskTitleFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _selectFriction(int friction, int xp, int coins) {
    setState(() {
      _model.selectedFriction = friction;
      _model.selectedXp = xp;
      _model.selectedCoins = coins;
    });
  }

  Future<void> _saveQuest() async {
    final title = _model.taskTitleFieldTextController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Give this quest a name first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_model.selectedFriction == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose how hard this feels right now.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_saving) return;
    setState(() => _saving = true);

    try {
      await TasksTable().insert({
        'user_id': currentUserUid,
        'title': title,
        'friction_level': _model.selectedFriction,
        'xp_value': _model.selectedXp,
        'coin_value': _model.selectedCoins,
        'status': 'open',
      });

      if (mounted) context.safePop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not add this quest. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          elevation: 0,
          foregroundColor: theme.primaryText,
          title: Text(
            'Add Quest',
            style: theme.titleLarge.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
              letterSpacing: 0,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'What needs to get done?',
                  style: theme.headlineSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Make it concrete enough that you will know when it is finished.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _model.taskTitleFieldTextController,
                  focusNode: _model.taskTitleFieldFocusNode,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Reply to Jordan about the proposal',
                    filled: true,
                    fillColor: theme.secondaryBackground,
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.alternate),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  style: theme.bodyLarge.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'How hard does this feel right now?',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Questwell rewards friction, not perfection.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                _FrictionChoice(
                  selected: _model.selectedFriction == 1,
                  title: 'Easy',
                  subtitle: 'I can probably just do it.',
                  reward: '+10 XP • +5 coins',
                  icon: Icons.check_circle_outline,
                  onTap: () => _selectFriction(1, 10, 5),
                ),
                const SizedBox(height: 10),
                _FrictionChoice(
                  selected: _model.selectedFriction == 2,
                  title: 'Annoying',
                  subtitle: 'Not hard. I just do not want to.',
                  reward: '+20 XP • +10 coins',
                  icon: Icons.sentiment_neutral_outlined,
                  onTap: () => _selectFriction(2, 20, 10),
                ),
                const SizedBox(height: 10),
                _FrictionChoice(
                  selected: _model.selectedFriction == 3,
                  title: 'Hard to Start',
                  subtitle: 'I keep circling it instead of beginning.',
                  reward: '+35 XP • +18 coins',
                  icon: Icons.hourglass_top_outlined,
                  onTap: () => _selectFriction(3, 35, 18),
                ),
                const SizedBox(height: 10),
                _FrictionChoice(
                  selected: _model.selectedFriction == 4,
                  title: 'Brain Says Absolutely Not',
                  subtitle: 'This task has developed its own weather system.',
                  reward: '+60 XP • +30 coins',
                  icon: Icons.thunderstorm_outlined,
                  onTap: () => _selectFriction(4, 60, 30),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _saveQuest,
                  icon: Icon(_saving ? Icons.hourglass_top : Icons.add_task),
                  label: Text(_saving ? 'Adding Quest...' : 'Add to Quest Board'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrictionChoice extends StatelessWidget {
  const _FrictionChoice({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String reward;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.primary : theme.alternate,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: theme.secondaryText,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reward,
                    style: theme.labelMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: theme.primary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: theme.primary),
          ],
        ),
      ),
    );
  }
}
