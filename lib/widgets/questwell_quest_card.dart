import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'questwell_typography.dart';

/// Shared by the signed-in board and the account-free visual review.
class QuestwellQuestCard extends StatelessWidget {
  const QuestwellQuestCard({super.key, required this.title, required this.effort,
    required this.xp, required this.coins, required this.favorite,
    required this.onFavorite, required this.onComplete, this.busy = false, this.onEdit, this.onSetAside, this.busyLabel = 'Completing…'});
  final String title, effort, busyLabel;
  final int xp, coins;
  final bool favorite, busy;
  final VoidCallback onFavorite;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit, onSetAside;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(boxShadow: [
      BoxShadow(color: Color(0x65000000), offset: Offset(3, 5), blurRadius: 2),
    ]),
    child: CustomPaint(painter: _QuestPaperPainter(),
      child: Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(favorite ? 'PINNED QUEST' : 'QUEST', style: GoogleFonts.pressStart2p(
            fontSize: 8, height: 1.6, color: const Color(0xFF785729))),
          const SizedBox(height: 10),
          Text(title.trim().isEmpty ? 'Untitled quest' : title,
            style: GoogleFonts.roboto(fontSize: 19, height: 1.3,
              fontWeight: FontWeight.w800, color: const Color(0xFF34291F))),
        ])),
        IconButton(onPressed: onFavorite,
          tooltip: favorite ? 'Unpin quest' : 'Pin quest',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: CustomPaint(size: const Size(24, 24),
            painter: _QuestPinPainter(favorite))),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _QuestTag(effort, const Color(0xFF4B493F)),
        _QuestTag('+$xp XP', const Color(0xFF624286)),
        _QuestTag('+$coins coins', const Color(0xFF79531C)),
      ]),
      if (onEdit != null) Align(alignment: Alignment.centerRight,
        child: TextButton(onPressed: busy ? null : onEdit,
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF315E4E),
            minimumSize: const Size(48, 48), textStyle: QuestwellTypography.control()),
          child: const Text('Edit quest'))),
      if (onSetAside != null) TextButton(
        onPressed: busy ? null : onSetAside,
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF695442),
          minimumSize: const Size(48, 48), textStyle: QuestwellTypography.control()),
        child: const Text('Set aside')),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: busy ? null : onComplete,
        icon: busy ? const SizedBox(width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded, size: 20),
        label: Text(busy ? busyLabel : 'Complete quest'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          backgroundColor: const Color(0xFF244C3E), foregroundColor: Colors.white,
          textStyle: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      )),
    ]),
    )),
  );
}

class _QuestTag extends StatelessWidget {
  const _QuestTag(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFFE5D2A9),
      border: Border.all(color: color.withValues(alpha: .25))),
    child: Text(text, style: GoogleFonts.roboto(color: color, fontSize: 12,
      fontWeight: FontWeight.w700)),
  );
}

class QuestwellBoardHeading extends StatelessWidget {
  const QuestwellBoardHeading({super.key, this.completed = 0, this.onAdd});
  final int completed;
  final VoidCallback? onAdd;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('QUEST BOARD', style: QuestwellTypography.sectionHeading(size: 14)),
      const SizedBox(height: 8),
      Text('One small win at a time.', style: QuestwellTypography.body(
        fontSize: 17, color: const Color(0xFFF0E5CC))),
      const SizedBox(height: 6),
      Text(completed == 0 ? 'Pick a quest that fits your energy.'
        : '$completed ${completed == 1 ? 'quest' : 'quests'} finished this visit. Keep your momentum.',
        style: QuestwellTypography.body(fontSize: 13, color: const Color(0xFFB9C7D7))),
      if (onAdd != null) ...[
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20), label: const Text('New quest'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            backgroundColor: const Color(0xFFE4C586), foregroundColor: const Color(0xFF263528),
            textStyle: QuestwellTypography.control(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))),
      ],
    ],
  );
}

class QuestwellBoardFilter extends StatelessWidget {
  const QuestwellBoardFilter({super.key, required this.label, required this.icon,
    required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(selected: selected,
    child: OutlinedButton.icon(onPressed: onTap,
      icon: Icon(icon, size: 17), label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        foregroundColor: selected ? const Color(0xFFE4C586) : const Color(0xFFB9C7D7),
        backgroundColor: selected ? const Color(0xFF293C32) : const Color(0xFF152332),
        side: BorderSide(color: selected ? const Color(0xFF9E8754) : const Color(0xFF43536A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
    canvas.drawOval(Rect.fromLTWH(size.width * .28, size.height * .57,
      size.width * .62, size.height * .24), p);
    p.color = const Color(0xFF65594B);
    p.strokeWidth = 2;
    canvas.drawLine(Offset(size.width * .47, size.height * .4),
      Offset(size.width * .61, size.height * .88), p);
    p.color = pinned ? const Color(0xFF94601E) : const Color(0xFF59676A);
    canvas.drawCircle(Offset(size.width * .46, size.height * .39), size.width * .32, p);
    p.color = pinned ? const Color(0xFFE2B858) : const Color(0xFF9CAAAA);
    canvas.drawCircle(Offset(size.width * .44, size.height * .34), size.width * .25, p);
    p.color = pinned ? const Color(0xFFFFE5A0) : const Color(0xFFD7DFD6);
    canvas.drawCircle(Offset(size.width * .36, size.height * .26), size.width * .07, p);
  }
  @override
  bool shouldRepaint(covariant _QuestPinPainter oldDelegate) => oldDelegate.pinned != pinned;
}

class QuestwellNoticeboard extends StatelessWidget {
  const QuestwellNoticeboard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF9E7546), width: 2),
      boxShadow: const [BoxShadow(color: Color(0x66000000), offset: Offset(3, 4))]),
    child: CustomPaint(painter: _NoticeboardWoodPainter(),
      child: Padding(padding: const EdgeInsets.all(10), child: child)),
  );
}

class _NoticeboardWoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final p = Paint()..color = const Color(0xFF493326);
    canvas.drawRect(Offset.zero & size, p);
    for (double y = 0; y < size.height; y += 82) {
      p.color = const Color(0xFF2C201C);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 3), p);
      p.color = const Color(0xFF614532);
      canvas.drawRect(Rect.fromLTWH(0, y + 4, size.width, 1), p);
      for (var i = 0; i < 4; i++) {
        final x = (i * 73 + y * .31) % size.width;
        p.color = const Color(0xFF563C2C);
        canvas.drawRect(Rect.fromLTWH(x, y + 18 + i * 11, 34, 1), p);
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _NoticeboardWoodPainter oldDelegate) => false;
}

class _QuestPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFF0DFB8);
    final shape = Path()..moveTo(0, 0)..lineTo(size.width - 15, 0)
      ..lineTo(size.width, 15)..lineTo(size.width, size.height)
      ..lineTo(0, size.height)..close();
    canvas.drawPath(shape, p);
    p..color = const Color(0xFFC6AB78)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawPath(shape, p);
    p..style = PaintingStyle.fill..color = const Color(0xFFD1B681);
    canvas.drawPath(Path()..moveTo(size.width - 15, 0)
      ..lineTo(size.width - 15, 15)..lineTo(size.width, 15)..close(), p);
    // Sparse fibers remain at the edges, away from readable text.
    p.color = const Color(0xFFCDB789);
    for (double y = 29; y < size.height - 10; y += 23) {
      canvas.drawRect(Rect.fromLTWH(3, y, 3, 1), p);
      canvas.drawRect(Rect.fromLTWH(size.width - 7, y + 4, 3, 1), p);
    }
  }
  @override
  bool shouldRepaint(covariant _QuestPaperPainter oldDelegate) => false;
}
