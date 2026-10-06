import 'package:flutter/material.dart';

import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';
import 'questwell_quest_card.dart';

/// Keep the next action close to the room without burying customization below
/// a long quest list. Selection, loading and completion stay with the caller.
class QuestwellHomeFocusLayout extends StatelessWidget {
  const QuestwellHomeFocusLayout({
    super.key,
    required this.nextWin,
    required this.overview,
    required this.onOpen,
    this.remainingQuests = const [],
    this.emphasizeAddQuest = false,
  });

  final Widget nextWin, overview;
  final ValueChanged<String> onOpen;
  final List<Widget> remainingQuests;
  final bool emphasizeAddQuest;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      nextWin,
      const SizedBox(height: 14),
      QuestwellHomeActions(
        onOpen: onOpen,
        emphasizeAddQuest: emphasizeAddQuest,
      ),
      const SizedBox(height: 18),
      overview,
      if (remainingQuests.isNotEmpty) ...[
        const SizedBox(height: 24),
        ...remainingQuests,
      ],
    ],
  );
}

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
        Text('Room to breathe.', textAlign: TextAlign.center,
          style: QuestwellTypography.sectionHeading(size: 12,
            color: const Color(0xFF34291F))),
        const SizedBox(height: 8),
        Text('Add one thing when you’re ready.',
          textAlign: TextAlign.center,
          style: QuestwellTypography.body(fontSize: 15,
            color: const Color(0xFF66513A))),
      ]),
    ),
  );
}

class QuestwellHomeActions extends StatelessWidget {
  const QuestwellHomeActions({
    super.key,
    required this.onOpen,
    this.emphasizeAddQuest = true,
  });
  final ValueChanged<String> onOpen;
  final bool emphasizeAddQuest;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (emphasizeAddQuest)
        FilledButton.icon(
          onPressed: () => onOpen('quests'),
          icon: const Icon(Icons.add, size: 22),
          label: const Text('Add quest'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF326F69),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.all(15),
            textStyle: QuestwellTypography.body(
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        )
      else
        OutlinedButton.icon(
          onPressed: () => onOpen('quests'),
          icon: const Icon(Icons.add, size: 22),
          label: const Text('Add quest'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFF0E5CC),
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.all(15),
            textStyle: QuestwellTypography.body(
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
            side: const BorderSide(color: Color(0xFF65563D)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      const SizedBox(height: 12),
      _destination(
        'expedition',
        'Start an expedition',
        'Make space for a focused session.',
      ),
    ],
  );

  Widget _destination(String kind, String title, String? subtitle) => Material(
    color: const Color(0xFF19232D),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3),
      side: const BorderSide(color: Color(0xFF65563D)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => onOpen(kind),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          children: [
            QuestwellNavPixelIcon(kind: kind, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: QuestwellTypography.body(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF0E5CC),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: QuestwellTypography.body(
                        fontSize: 14,
                        color: const Color(0xFFAFBBC7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
