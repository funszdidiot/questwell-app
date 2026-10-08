import 'package:flutter/material.dart';
import 'questwell_hearth_material.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';

/// Shared real-account and interactive review presentation. Rewards and writes
/// remain owned by the task service/caller.
class QuestwellHearthQuestContent extends StatelessWidget {
  const QuestwellHearthQuestContent(
      {super.key,
      required this.title,
      required this.xp,
      required this.coins,
      required this.onComplete,
      this.notes,
      this.frictionLabel,
      this.pinned = false,
      this.completing = false,
      this.featured = true});
  final String title;
  final String? notes, frictionLabel;
  final int xp, coins;
  final bool pinned, completing, featured;
  final VoidCallback onComplete;
  static const _ink = Color(0xFF302418);
  @override
  Widget build(BuildContext context) {
    final contents =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (featured && pinned)
        Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('PINNED · NEXT UP',
                style: QuestwellTypography.sectionHeading(
                    size: 8, color: const Color(0xFF71502E)))),
      LayoutBuilder(builder: (context, bounds) {
        final titleWidget = Text(title,
            style:
                QuestwellHearthMaterial.serif(featured ? 25 : 20, color: _ink));
        if (bounds.maxWidth < 270 ||
            MediaQuery.textScalerOf(context).scale(16) > 22) {
          return titleWidget;
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFDABD87),
                  borderRadius: BorderRadius.circular(6)),
              child: const QuestwellNavPixelIcon(kind: 'quests', size: 34)),
          const SizedBox(width: 14),
          Expanded(child: titleWidget),
        ]);
      }),
      if (frictionLabel != null) ...[
        const SizedBox(height: 8),
        Text(frictionLabel!,
            style: QuestwellTypography.body(
                fontSize: 12, color: const Color(0xFF695335)))
      ],
      if (notes?.trim().isNotEmpty ?? false) ...[
        const SizedBox(height: 10),
        Text(notes!.trim(),
            style: QuestwellTypography.body(fontSize: 14, color: _ink))
      ],
      const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: Color(0xFFBDA16F))),
      Wrap(spacing: 18, runSpacing: 8, children: [
        _reward('xp', '+$xp XP'),
        _reward('coin', '+$coins coins'),
      ]),
      const SizedBox(height: 16),
      if (featured)
        QuestwellHearthButton(
            label: completing ? 'Completing…' : 'Complete quest',
            onPressed: completing ? null : onComplete)
      else
        OutlinedButton(
            onPressed: completing ? null : onComplete,
            style: QuestwellHearthMaterial.secondaryButton()
                .copyWith(foregroundColor: const WidgetStatePropertyAll(_ink)),
            child: Text(completing ? 'Completing…' : 'Complete quest',
                textAlign: TextAlign.center)),
    ]);
    return featured
        ? contents
        : QuestwellHearthFrame(parchment: true, child: contents);
  }

  Widget _reward(String kind, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        QuestwellCurrencyPixelIcon(kind: kind, size: 20),
        const SizedBox(width: 6),
        Flexible(
            child: Text(label,
                style: QuestwellHearthMaterial.serif(16, color: _ink))),
      ]);
}
