import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_quest_card.dart';
import '/widgets/questwell_typography.dart';
import '/widgets/questwell_app_navigation.dart';
import 'package:flutter/material.dart';
import 'add_task_page_model.dart';
export 'add_task_page_model.dart';

class AddTaskPageWidget extends StatefulWidget {
  const AddTaskPageWidget({super.key, this.onCreate, this.onClose,
    this.editing = false, this.initialTitle = '', this.initialFriction = 0,
    this.initialXp = 0, this.initialCoins = 0, this.onFinished});
  /// Optional in-memory persistence for the development preview and tests.
  final Future<void> Function(String title, int friction, int xp, int coins)? onCreate;
  final VoidCallback? onClose;
  final ValueChanged<bool>? onFinished;
  final bool editing;
  final String initialTitle;
  final int initialFriction, initialXp, initialCoins;

  static String routeName = 'AddTaskPage';
  static String routePath = '/addTaskPage';

  @override
  State<AddTaskPageWidget> createState() => _AddTaskPageWidgetState();
}

class _AddTaskPageWidgetState extends State<AddTaskPageWidget> {
  late AddTaskPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _saving = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddTaskPageModel());
    _model.taskTitleFieldTextController ??= TextEditingController(text: widget.initialTitle);
    _model.taskTitleFieldFocusNode ??= FocusNode();
    _model.selectedFriction = widget.initialFriction;
    _model.selectedXp = widget.initialXp;
    _model.selectedCoins = widget.initialCoins;
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
      setState(() => _feedback = 'Give this quest a name first.');
      return;
    }

    if (_model.selectedFriction == 0) {
      setState(() => _feedback = 'Choose how hard this feels right now.');
      return;
    }

    if (_saving) return;
    setState(() { _saving = true; _feedback = null; });

    try {
      if (widget.onCreate != null) {
        await widget.onCreate!(title, _model.selectedFriction, _model.selectedXp, _model.selectedCoins);
      } else {
      if (widget.editing) throw StateError('An edit requires a save handler.');
      await TasksTable().insert({
        'user_id': currentUserUid,
        'title': title,
        'friction_level': _model.selectedFriction,
        'xp_value': _model.selectedXp,
        'coin_value': _model.selectedCoins,
        'status': 'open',
      });
      }

      if (mounted) _close(posted: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _feedback = widget.editing
        ? 'Could not save your changes. The quest may have been completed. Return to the board and try again.'
        : 'Could not add this quest. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _hasDraft => widget.editing
      ? _model.taskTitleFieldTextController.text.trim() != widget.initialTitle.trim() ||
          _model.selectedFriction != widget.initialFriction
      : _model.taskTitleFieldTextController.text.trim().isNotEmpty ||
          _model.selectedFriction != 0;

  void _close({bool posted = false}) {
    if (widget.onFinished != null) {
      widget.onFinished!(posted);
    } else if (widget.onClose != null) {
      widget.onClose!();
    } else if (context.canPop()) {
      context.pop(posted);
    } else {
      context.goNamed('QuestBoardPage');
    }
  }

  Future<bool> _canLeave() async {
    if (_saving) return false;
    if (!_hasDraft) return true;
    return await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      scrollable: true,
      title: Text(widget.editing ? 'Discard quest changes?' : 'Leave this quest draft?'),
      content: Text(widget.editing ? 'Your changes have not been saved.' : 'Your quest has not been posted yet.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep editing')),
        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(widget.editing ? 'Discard changes' : 'Discard draft')),
      ],
    )) == true;
  }

  Future<void> _back() async {
    if (await _canLeave() && mounted) _close();
  }

  Future<void> _navigate(QuestwellDestination destination) async {
    if (!await _canLeave() || !mounted) return;
    if (destination == QuestwellDestination.quests) {
      // A pushed form returns to its board, including local preview drafts.
      if (widget.onClose != null || widget.onFinished != null) { _close(); return; }
    }
    QuestwellNavigationScope.open(context, destination);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      key: scaffoldKey, backgroundColor: const Color(0xFF111827),
      bottomNavigationBar: QuestwellAppNavigation(
        current: QuestwellDestination.quests, allowCurrentSelection: true, onSelect: _navigate),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Align(alignment: Alignment.centerLeft, child: TextButton.icon(
              onPressed: _saving ? null : _back,
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text('Back to quests'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE4C586),
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: QuestwellTypography.control()),
            )),
            const SizedBox(height: 12),
            Text(widget.editing ? 'EDIT QUEST' : 'NEW QUEST', style: QuestwellTypography.sectionHeading(size: 14)),
            const SizedBox(height: 8),
            Text(widget.editing ? 'Adjust this quest to fit your energy today.' : 'Pin your next small win to the board.',
              style: QuestwellTypography.body(fontSize: 16, color: const Color(0xFFF0E5CC))),
            const SizedBox(height: 20),
            QuestwellNoticeboard(child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              decoration: BoxDecoration(color: const Color(0xFFF0DFB8),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFC6AB78))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Center(child: ExcludeSemantics(child: Icon(
                  Icons.push_pin, size: 23, color: Color(0xFF99672D)))),
                const SizedBox(height: 8),
                Text('What needs to get done?', style: QuestwellTypography.body(
                  fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF34291F))),
                const SizedBox(height: 6),
                Text('One clear action is enough.', style: QuestwellTypography.body(
                  fontSize: 13, color: const Color(0xFF67543E))),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _model.taskTitleFieldTextController,
                  focusNode: _model.taskTitleFieldFocusNode,
                  enabled: !_saving, minLines: 1, maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  style: QuestwellTypography.body(fontSize: 16,
                    fontWeight: FontWeight.w600, color: const Color(0xFF34291F)),
                  decoration: InputDecoration(
                    labelText: 'Quest name', hintText: 'Reply to Jordan',
                    labelStyle: QuestwellTypography.body(color: const Color(0xFF67543E)),
                    hintStyle: QuestwellTypography.body(color: const Color(0xFF8B765B)),
                    filled: true, fillColor: const Color(0xFFFFF6DF),
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFF9E8754))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFF244C3E), width: 2)),
                  ),
                ),
              ]),
            )),
            const SizedBox(height: 24),
            Text('CHOOSE THE EFFORT', style: QuestwellTypography.sectionHeading(size: 11)),
            const SizedBox(height: 8),
            Text('Pick what fits your energy today.',
              style: QuestwellTypography.body(color: const Color(0xFFB9C7D7))),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700 && MediaQuery.textScalerOf(context).scale(14) < 21;
              final width = wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                for (final choice in const [
                  (1, 'Easy', 'I can probably just do it.', 10, 5, Icons.spa_outlined),
                  (2, 'Annoying', 'Not hard. I just do not want to.', 20, 10, Icons.bolt_outlined),
                  (3, 'Hard to Start', 'I keep circling it instead of beginning.', 35, 18, Icons.flag_outlined),
                  (4, 'Brain Says Absolutely Not', 'This task has developed its own weather system.', 60, 30, Icons.shield_outlined),
                ]) SizedBox(width: width, child: _FrictionChoice(
                  selected: _model.selectedFriction == choice.$1,
                  title: choice.$2, subtitle: choice.$3, xp: choice.$4, coins: choice.$5, icon: choice.$6,
                  onTap: _saving ? null : () => _selectFriction(choice.$1, choice.$4, choice.$5))),
              ]);
            }),
            const SizedBox(height: 22),
            if (_feedback != null) ...[
              Semantics(liveRegion: true, child: Text(_feedback!,
                style: QuestwellTypography.body(color: const Color(0xFFFFD5A6)))),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _saving ? null : _saveQuest,
              icon: _saving ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_task, size: 20),
              label: Text(_saving ? (widget.editing ? 'Saving changes…' : 'Posting quest…')
                : (widget.editing ? 'Save changes' : 'Post to Quest Board')),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                backgroundColor: const Color(0xFFE4C586), foregroundColor: const Color(0xFF263528),
                textStyle: QuestwellTypography.control(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            ),
          ]),
        ),
      ))),
    ),
  );
}

class _FrictionChoice extends StatelessWidget {
  const _FrictionChoice({required this.selected, required this.title, required this.subtitle,
    required this.xp, required this.coins, required this.icon, required this.onTap});
  final bool selected;
  final String title, subtitle;
  final int xp, coins;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected, inMutuallyExclusiveGroup: true, button: true,
    child: Material(color: selected ? const Color(0xFF2B4035) : const Color(0xFF192838),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
            border: Border.all(color: selected ? const Color(0xFFE4C586) : const Color(0xFF43536A),
              width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 22, color: const Color(0xFFE4C586)),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: QuestwellTypography.body(fontSize: 16,
                fontWeight: FontWeight.w700, color: const Color(0xFFF0E5CC)))),
              if (selected) ...[const SizedBox(width: 8),
                const Icon(Icons.check_circle, size: 20, color: Color(0xFFE4C586))],
            ]),
            const SizedBox(height: 6),
            Text(subtitle, style: QuestwellTypography.body(fontSize: 13, color: const Color(0xFFB9C7D7))),
            const SizedBox(height: 10),
            Wrap(spacing: 14, runSpacing: 6, children: [
              _reward('xp', '+$xp XP'), _reward('coin', '+$coins coins'),
            ]),
          ]),
        ),
      ),
    ),
  );

  Widget _reward(String kind, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    QuestwellCurrencyPixelIcon(kind: kind, size: 15), const SizedBox(width: 6),
    Flexible(child: Text(label, style: QuestwellTypography.body(fontSize: 13,
      fontWeight: FontWeight.w700, color: const Color(0xFFE4C586)))),
  ]);
}
