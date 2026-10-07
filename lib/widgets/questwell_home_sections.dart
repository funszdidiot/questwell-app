import 'package:flutter/material.dart';

import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';
import 'questwell_hearth_material.dart';
import 'questwell_home_overview.dart';

/// Shared account/review canvas. Room coordinates remain owned by the renderer.
class QuestwellHomeCanvas extends StatelessWidget {
  const QuestwellHomeCanvas({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      );
}

class QuestwellHomeRoomFrame extends StatelessWidget {
  const QuestwellHomeRoomFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: child,
        ),
      );
}

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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          // Preserve comfortable reading widths instead of shrinking enlarged text.
          final wide = constraints.maxWidth >= 840 &&
              MediaQuery.textScalerOf(context).scale(16) <= 20;
          final focus = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              nextWin,
              const SizedBox(height: 16),
              QuestwellHomeActions(
                onOpen: onOpen,
                emphasizeAddQuest: emphasizeAddQuest,
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: focus),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: overview),
                  ],
                )
              else ...[
                focus,
                const SizedBox(height: 24),
                overview,
              ],
              if (remainingQuests.isNotEmpty) ...[
                const SizedBox(height: 28),
                ...remainingQuests,
              ],
            ],
          );
        },
      );
}

/// Compact home overview; shared with the account-free visual review.
class QuestwellHomeEmptyBoard extends StatelessWidget {
  const QuestwellHomeEmptyBoard({super.key});
  @override
  Widget build(BuildContext context) => QuestwellHearthFrame(
        parchment: true,
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(children: [
            Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: Color(0xFFAA6343),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x4434291F), offset: Offset(1, 2))
                    ])),
            const SizedBox(height: 10),
            Text('Room to breathe.',
                textAlign: TextAlign.center,
                style: QuestwellTypography.sectionHeading(
                    size: 12, color: const Color(0xFF34291F))),
            const SizedBox(height: 8),
            Text('Add one thing when you’re ready.',
                textAlign: TextAlign.center,
                style: QuestwellTypography.body(
                    fontSize: 15, color: const Color(0xFF66513A))),
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
              style: QuestwellHearthMaterial.primaryButton(),
            )
          else
            OutlinedButton.icon(
              onPressed: () => onOpen('quests'),
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Add quest'),
              style: QuestwellHearthMaterial.secondaryButton(),
            ),
          const SizedBox(height: 12),
          _destination(
            'expedition',
            'Start an expedition',
            'Make space for a focused session.',
          ),
        ],
      );

  Widget _destination(String kind, String title, String? subtitle) =>
      QuestwellHomePanel(
        padding: EdgeInsets.zero,
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
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    size: 20, color: Color(0xFFE4C586)),
              ],
            ),
          ),
        ),
      );
}
