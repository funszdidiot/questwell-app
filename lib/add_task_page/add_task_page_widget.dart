import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_typography.dart';
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
        backgroundColor: const Color(0xFF111827),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      QuestwellTopActionButton(
                        kind: 'back', tooltip: 'Back to the Hearth',
                        onTap: () => context.safePop(),
                      ),
                      const Spacer(),
                      const QuestwellNavPixelIcon(kind: 'quest', size: 36),
                    ]),
                    const SizedBox(height: 12),
                    Text('QUEST BOARD', style: QuestwellTypography.sectionHeading(
                      size: 16, color: const Color(0xFFF2D9A0))),
                    const SizedBox(height: 8),
                    Text('Turn one real-life task into your next adventure.',
                      style: QuestwellTypography.body(color: const Color(0xFFB7C4D4))),
                    const SizedBox(height: 12),
                    const QuestwellPixelDivider(
                      accent: Color(0xFFD6A84B),
                    ),
                    const SizedBox(height: 14),
                    const QuestwellQuestBoardPixelArt(
                      height: 160,
                      clear: false,
                    ),
                    const SizedBox(height: 18),
                    QuestwellParchmentPanel(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POST A NEW QUEST',
                            style: theme.titleLarge.override(
                              font: GoogleFonts.pressStart2p(
                                fontWeight: FontWeight.w700,
                              ),
                              fontSize: 13,
                              color: const Color(0xFF30261D),
                              letterSpacing: .3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'What needs to get done?',
                            style: theme.titleMedium.override(
                              font: GoogleFonts.roboto(
                                fontWeight: FontWeight.w800,
                              ),
                              color: const Color(0xFF30261D),
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Make it concrete enough that you will know when it is finished.',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.roboto(),
                              color: const Color(0xFF67543E),
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _model.taskTitleFieldTextController,
                            focusNode: _model.taskTitleFieldFocusNode,
                            autofocus: true,
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Reply to Jordan about the proposal',
                              hintStyle: const TextStyle(
                                color: Color(0xFF8B765B),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7EAC8),
                              contentPadding: const EdgeInsets.all(16),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF8E6B35),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.zero,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFD6A84B),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            style: theme.bodyLarge.override(
                              font: GoogleFonts.roboto(
                                fontWeight: FontWeight.w600,
                              ),
                              color: const Color(0xFF30261D),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CHOOSE THE MONSTER',
                      style: theme.titleLarge.override(
                        font: GoogleFonts.pressStart2p(
                          fontWeight: FontWeight.w700,
                        ),
                        fontSize: 12,
                        color: const Color(0xFFF2D9A0),
                        letterSpacing: .3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Questwell rewards friction, not perfection. Pick how this task feels right now.',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.roboto(),
                        color: const Color(0xFFB7C4D4),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 700;
                        final cardWidth = wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                        final cards = <Widget>[
                          _FrictionChoice(
                            selected: _model.selectedFriction == 1,
                            title: 'Easy',
                            subtitle: 'I can probably just do it.',
                            reward: '+10 XP • +5 coins',
                            level: 1,
                            onTap: () => _selectFriction(1, 10, 5),
                          ),
                          _FrictionChoice(
                            selected: _model.selectedFriction == 2,
                            title: 'Annoying',
                            subtitle: 'Not hard. I just do not want to.',
                            reward: '+20 XP • +10 coins',
                            level: 2,
                            onTap: () => _selectFriction(2, 20, 10),
                          ),
                          _FrictionChoice(
                            selected: _model.selectedFriction == 3,
                            title: 'Hard to Start',
                            subtitle: 'I keep circling it instead of beginning.',
                            reward: '+35 XP • +18 coins',
                            level: 3,
                            onTap: () => _selectFriction(3, 35, 18),
                          ),
                          _FrictionChoice(
                            selected: _model.selectedFriction == 4,
                            title: 'Brain Says Absolutely Not',
                            subtitle: 'This task has developed its own weather system.',
                            reward: '+60 XP • +30 coins',
                            level: 4,
                            onTap: () => _selectFriction(4, 60, 30),
                          ),
                        ];
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final card in cards)
                              SizedBox(width: cardWidth, child: card),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    QuestwellRetroPanel(
                      padding: const EdgeInsets.all(10),
                      accent: const Color(0xFFD6A84B),
                      background: const Color(0xFF17151A),
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _saveQuest,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const QuestwellNavPixelIcon(
                                kind: 'quest',
                                size: 21,
                              ),
                        label: Text(
                          _saving
                              ? 'Posting Quest...'
                              : 'Post to Quest Board',
                          style: QuestwellTypography.control(),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: const Color(0xFF6E3B2C),
                          foregroundColor: const Color(0xFFF6E7BE),
                          disabledBackgroundColor: const Color(0xFF3A3433),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    required this.level,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String reward;
  final int level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF7E8B9)
              : const Color(0xFFE7D4A8),
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: selected
                ? const Color(0xFFD6A84B)
                : const Color(0xFF80633E),
            width: selected ? 3 : 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x77322018),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            QuestwellFrictionPixelBadge(
              level: level,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.roboto(fontWeight: FontWeight.w800),
                      color: const Color(0xFF30261D),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.roboto(),
                      color: const Color(0xFF67543E),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const QuestwellCurrencyPixelIcon(
                            kind: 'xp',
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Flexible(child: Text(
                            reward.split(' • ').first,
                            style: theme.labelMedium.override(
                              font: GoogleFonts.roboto(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF6E3B2C),
                              letterSpacing: 0,
                            ),
                          )),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const QuestwellCurrencyPixelIcon(
                            kind: 'coin',
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Flexible(child: Text(
                            reward.split(' • ').last,
                            style: theme.labelMedium.override(
                              font: GoogleFonts.roboto(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF6E3B2C),
                              letterSpacing: 0,
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (selected)
              const QuestwellNavPixelIcon(
                kind: 'quest',
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

