import 'package:flutter/material.dart';
import 'questwell_account_dialog_flow.dart';
import 'questwell_app_style.dart';
import 'questwell_hearth_icon.dart';
import 'questwell_hearth_material.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';

/// Celebrates an already confirmed result. This widget never awards rewards.
class QuestwellQuestCompletionDialog extends StatelessWidget {
  const QuestwellQuestCompletionDialog(
      {super.key,
      required this.questTitle,
      required this.xpAwarded,
      required this.coinsAwarded,
      required this.totalXp,
      required this.coinBalance,
      required this.level,
      this.firstWin = false,
      this.leveledUp = false});
  final String questTitle;
  final int xpAwarded, coinsAwarded, totalXp, coinBalance, level;
  final bool firstWin, leveledUp;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Dialog(
      backgroundColor: QuestwellAppStyle.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: QuestwellHearthMaterial.brass, width: 2)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('A WIN FOR YOUR CHRONICLE',
                    textAlign: TextAlign.center,
                    style: QuestwellTypography.body(
                        fontSize: 12,
                        color: QuestwellHearthMaterial.brass,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Semantics(
                    namesRoute: true,
                    header: true,
                    child: Text(
                        firstWin
                            ? 'Your First Win!'
                            : leveledUp
                                ? 'Level Up!'
                                : 'Quest Complete!',
                        textAlign: TextAlign.center,
                        style: QuestwellHearthMaterial.serif(30))),
                const SizedBox(height: 16),
                ExcludeSemantics(
                    child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: reduced ? 1 : .86, end: 1),
                        duration: Duration(milliseconds: reduced ? 0 : 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, scale, child) => Transform.scale(
                            key: const ValueKey('quest-victory-reveal'),
                            scale: reduced ? 1 : scale,
                            child: child),
                        child: const QuestwellVictoryPixelArt(height: 120))),
                const SizedBox(height: 18),
                QuestwellHearthFrame(
                    parchment: true,
                    child: Column(children: [
                      Text('COMPLETED',
                          style: QuestwellTypography.body(
                              fontSize: 12,
                              color: const Color(0xFF586247),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                          questTitle.trim().isEmpty ? 'Your quest' : questTitle,
                          textAlign: TextAlign.center,
                          style: QuestwellHearthMaterial.serif(21,
                              color: const Color(0xFF30271E))),
                    ])),
                const SizedBox(height: 16),
                Text(
                    firstWin
                        ? 'One real step. Your adventure is underway.'
                        : leveledUp
                            ? 'Your adventurer reached Level $level.'
                            : 'You showed up. Your adventure moved forward.',
                    textAlign: TextAlign.center,
                    style: QuestwellTypography.body(
                        color: QuestwellHearthMaterial.ink, height: 1.45)),
                const SizedBox(height: 18),
                Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _EarnedReward(kind: 'xp', label: '+$xpAwarded XP'),
                      _EarnedReward(
                          kind: 'coin', label: '+$coinsAwarded coins'),
                    ]),
                const SizedBox(height: 10),
                Text('Balance: $coinBalance coins • $totalXp total XP',
                    textAlign: TextAlign.center,
                    style: QuestwellTypography.body(
                        fontSize: 12, color: const Color(0xFFB7C4B5))),
                const SizedBox(height: 22),
                FilledButton(
                    style: QuestwellHearthMaterial.primaryButton(),
                    onPressed: () =>
                        QuestwellAccountDialogFlow.pop(context, 'continue'),
                    child: Text(leveledUp ? 'Continue Adventure' : 'Keep Going',
                        textAlign: TextAlign.center)),
                const SizedBox(height: 8),
                Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          foregroundColor: QuestwellHearthMaterial.ink,
                          textStyle: QuestwellTypography.control()),
                      onPressed: () =>
                          QuestwellAccountDialogFlow.pop(context, 'chronicle'),
                      child: const Text('See Chronicle')),
                  TextButton(
                      style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          foregroundColor: QuestwellHearthMaterial.ink,
                          textStyle: QuestwellTypography.control()),
                      onPressed: () =>
                          QuestwellAccountDialogFlow.pop(context, 'add'),
                      child: const Text('Add Next Quest')),
                ]),
              ]),
        ),
      ),
    );
  }
}

class _EarnedReward extends StatelessWidget {
  const _EarnedReward({required this.kind, required this.label});
  final String kind, label;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF263E34),
          border: Border.all(color: QuestwellHearthMaterial.brass),
          borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ExcludeSemantics(child: QuestwellHearthIcon(kind: kind, size: 24)),
        const SizedBox(width: 8),
        Flexible(
            child: Text(label,
                style: QuestwellTypography.body(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF4DB9C)))),
      ]));
}
