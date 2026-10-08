import 'questwell_hearth_icon.dart';
import 'questwell_hearth_material.dart';
import 'questwell_app_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'questwell_typography.dart';

/// Shared by the signed-in board and the account-free visual review.
class QuestwellQuestCard extends StatelessWidget {
  const QuestwellQuestCard(
      {super.key,
      required this.title,
      required this.effort,
      required this.xp,
      required this.coins,
      required this.favorite,
      required this.onFavorite,
      required this.onComplete,
      this.busy = false,
      this.onEdit,
      this.onSetAside,
      this.busyLabel = 'Completing…'});
  final String title, effort, busyLabel;
  final int xp, coins;
  final bool favorite, busy;
  final VoidCallback onFavorite;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit, onSetAside;

  @override
  Widget build(BuildContext context) => QuestwellHearthFrame(
        parchment: true,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(favorite ? 'PINNED QUEST' : 'QUEST',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          height: 1.6,
                          color: const Color(0xFF785729))),
                  const SizedBox(height: 10),
                  Text(title.trim().isEmpty ? 'Untitled quest' : title,
                      style: QuestwellHearthMaterial.serif(20,
                          color: const Color(0xFF34291F))),
                ])),
            IconButton(
                onPressed: onFavorite,
                tooltip: favorite ? 'Unpin quest' : 'Pin quest',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: CustomPaint(
                    size: const Size(24, 24),
                    painter: _QuestPinPainter(favorite))),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _QuestTag(effort, const Color(0xFF4B493F)),
            _QuestTag('+$xp XP', const Color(0xFF624286), icon: 'xp'),
            _QuestTag('+$coins coins', const Color(0xFF79531C), icon: 'coin'),
          ]),
          if (onEdit != null)
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: busy ? null : onEdit,
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF315E4E),
                        minimumSize: const Size(48, 48),
                        textStyle: QuestwellTypography.control()),
                    child: const Text('Edit quest'))),
          if (onSetAside != null)
            TextButton(
                onPressed: busy ? null : onSetAside,
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF695442),
                    minimumSize: const Size(48, 48),
                    textStyle: QuestwellTypography.control()),
                child: const Text('Set aside')),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy ? null : onComplete,
                style: QuestwellAppStyle.primaryButton(),
                child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_rounded, size: 20),
                      Text(busy ? busyLabel : 'Complete quest',
                          textAlign: TextAlign.center),
                    ]),
              )),
        ]),
      );
}

class _QuestTag extends StatelessWidget {
  const _QuestTag(this.text, this.color, {this.icon});
  final String? icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFE5D2A9),
            border: Border.all(color: color.withValues(alpha: .25))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            QuestwellHearthIcon(kind: icon!, size: 18),
            const SizedBox(width: 5)
          ],
          Flexible(
              child: Text(text,
                  style: GoogleFonts.roboto(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700))),
        ]),
      );
}

class QuestwellBoardHeading extends StatelessWidget {
  const QuestwellBoardHeading({super.key, this.completed = 0, this.onAdd});
  final int completed;
  final VoidCallback? onAdd;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('QUEST BOARD',
              style: QuestwellTypography.sectionHeading(size: 14)),
          const SizedBox(height: 8),
          Text('One small win at a time.',
              style: QuestwellTypography.body(
                  fontSize: 17, color: const Color(0xFFF0E5CC))),
          const SizedBox(height: 6),
          Text(
              completed == 0
                  ? 'Pick a quest that fits your energy.'
                  : '$completed ${completed == 1 ? 'quest' : 'quests'} finished this visit. Keep your momentum.',
              style: QuestwellTypography.body(
                  fontSize: 13, color: const Color(0xFFB9C7D7))),
          if (onAdd != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('New quest'),
                style: QuestwellAppStyle.primaryButton()),
          ],
        ],
      );
}

class QuestwellBoardFilter extends StatelessWidget {
  const QuestwellBoardFilter(
      {super.key,
      required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
      selected: selected,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            foregroundColor:
                selected ? const Color(0xFFE4C586) : const Color(0xFFB9C7D7),
            backgroundColor:
                selected ? const Color(0xFF293C32) : const Color(0xFF152332),
            side: BorderSide(
                color: selected
                    ? const Color(0xFF9E8754)
                    : const Color(0xFF967947)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            textStyle: QuestwellTypography.control()),
      ));
}

class _QuestPinPainter extends CustomPainter {
  const _QuestPinPainter(this.pinned);
  final bool pinned;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    // A brass priority tack, or a muted steel tack for ordinary quests.
    p.color = const Color(0x55342116);
    canvas.drawOval(
        Rect.fromLTWH(size.width * .28, size.height * .57, size.width * .62,
            size.height * .24),
        p);
    p.color = const Color(0xFF65594B);
    p.strokeWidth = 2;
    canvas.drawLine(Offset(size.width * .47, size.height * .4),
        Offset(size.width * .61, size.height * .88), p);
    p.color = pinned ? const Color(0xFF94601E) : const Color(0xFF59676A);
    canvas.drawCircle(
        Offset(size.width * .46, size.height * .39), size.width * .32, p);
    p.color = pinned ? const Color(0xFFE2B858) : const Color(0xFF9CAAAA);
    canvas.drawCircle(
        Offset(size.width * .44, size.height * .34), size.width * .25, p);
    p.color = pinned ? const Color(0xFFFFE5A0) : const Color(0xFFD7DFD6);
    canvas.drawCircle(
        Offset(size.width * .36, size.height * .26), size.width * .07, p);
  }

  @override
  bool shouldRepaint(covariant _QuestPinPainter oldDelegate) =>
      oldDelegate.pinned != pinned;
}

class QuestwellNoticeboard extends StatelessWidget {
  const QuestwellNoticeboard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => QuestwellHearthTimber(
      child: Padding(padding: const EdgeInsets.all(8), child: child));
}
