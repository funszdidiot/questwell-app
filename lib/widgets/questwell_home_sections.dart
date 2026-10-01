import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';
import 'questwell_quest_card.dart';

/// Compact home overview; shared with the account-free visual review.
class QuestwellHomeEmptyBoard extends StatelessWidget {
  const QuestwellHomeEmptyBoard({super.key});
  @override
  Widget build(BuildContext context) => QuestwellNoticeboard(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      color: const Color(0xFFF0E0BA),
      child: Column(children: [
        Container(width: 10, height: 10, decoration: const BoxDecoration(
          color: Color(0xFFAA6343), shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x4434291F), offset: Offset(1, 2))])),
        const SizedBox(height: 10),
        Text('A little room to breathe.', textAlign: TextAlign.center,
          style: QuestwellTypography.sectionHeading(size: 12,
            color: const Color(0xFF34291F))),
        const SizedBox(height: 8),
        Text('Add one thing when you’re ready.',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(fontSize: 15, height: 1.35,
            color: const Color(0xFF66513A))),
      ]),
    ),
  );
}

class QuestwellHomeActions extends StatelessWidget {
  const QuestwellHomeActions({super.key, required this.onOpen});
  final ValueChanged<String> onOpen;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton.icon(onPressed: () => onOpen('quests'),
        icon: const Icon(Icons.add, size: 22), label: const Text('Add quest'),
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF326F69),
          foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.all(15),
          textStyle: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)))),
      const SizedBox(height: 12),
      _destination('expedition', 'Start an expedition', 'Make space for a focused session.'),
    ],
  );

  Widget _destination(String kind, String title, String? subtitle) => Material(
    color: const Color(0xFF19232D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3),
      side: const BorderSide(color: Color(0xFF65563D))),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: () => onOpen(kind), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Row(children: [
        QuestwellNavPixelIcon(kind: kind, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.roboto(fontSize: 15,
            fontWeight: FontWeight.w700, color: const Color(0xFFF0E5CC))),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(subtitle, style: GoogleFonts.roboto(fontSize: 13, height: 1.4,
              color: const Color(0xFFAFBBC7))),
          ],
        ])),
      ]),
    )),
  );
}
