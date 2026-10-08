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
          constraints: const BoxConstraints(maxWidth: 760),
          child: QuestwellHearthTimber(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children),
            ),
          ),
        ),
      );
}

/// An attached header strip keeps the logo clear of every canonical decor slot.
class QuestwellHomeHero extends StatelessWidget {
  const QuestwellHomeHero({super.key, required this.room});
  final Widget room;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF17222A), Color(0xFF201A18)])),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestwellHomeHeader(),
                    QuestwellPixelDivider(accent: Color(0xFFD6A84B))
                  ])),
          room,
        ],
      );
}

class QuestwellHomeRoomFrame extends StatelessWidget {
  const QuestwellHomeRoomFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: child,
        ),
      );
}

/// The approved single-column sequence remains the same at desktop widths.
class QuestwellHomeFocusLayout extends StatelessWidget {
  const QuestwellHomeFocusLayout(
      {super.key,
      required this.nextWin,
      required this.overview,
      required this.onOpen,
      this.remainingQuests = const [],
      this.emphasizeAddQuest = false,
      this.campfire,
      this.secondary,
      this.gentle = false});
  final Widget nextWin, overview;
  final Widget? campfire, secondary;
  final ValueChanged<String> onOpen;
  final List<Widget> remainingQuests;
  final bool emphasizeAddQuest, gentle;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          overview,
          const SizedBox(height: 14),
          QuestwellHearthQuestFrame(
              label: gentle ? 'ONE SMALL WIN' : 'YOUR NEXT WIN',
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    nextWin,
                    if (emphasizeAddQuest) ...[
                      const SizedBox(height: 14),
                      QuestwellHearthButton(
                          label: 'Add quest',
                          onPressed: () => onOpen('quests')),
                    ],
                  ])),
          if (campfire != null) ...[const SizedBox(height: 12), campfire!],
          const SizedBox(height: 16),
          Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const PageStorageKey('hearth-more'),
                iconColor: QuestwellHearthMaterial.brass,
                collapsedIconColor: QuestwellHearthMaterial.brass,
                title: Text('More at the Hearth',
                    style: QuestwellTypography.body(
                        fontSize: 14, color: QuestwellHearthMaterial.ink)),
                children: [
                  QuestwellHomeActions(
                      onOpen: onOpen, emphasizeAddQuest: false),
                  if (secondary != null) ...[
                    const SizedBox(height: 12),
                    secondary!
                  ],
                  if (remainingQuests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...remainingQuests
                  ],
                ],
              )),
        ]),
      );
}

/// Compact home overview; shared with the account-free visual review.
class QuestwellHomeEmptyBoard extends StatelessWidget {
  const QuestwellHomeEmptyBoard({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        const QuestwellNavPixelIcon(kind: 'quests', size: 42),
        const SizedBox(height: 10),
        Text('Room to breathe.',
            textAlign: TextAlign.center,
            style: QuestwellHearthMaterial.serif(24,
                color: const Color(0xFF302418))),
        const SizedBox(height: 8),
        Text('Add one thing when you’re ready.',
            textAlign: TextAlign.center,
            style: QuestwellTypography.body(
                fontSize: 15, color: const Color(0xFF66513A))),
      ]);
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
