import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_app_navigation.dart';
import 'questwell_hearth_material.dart';
import 'questwell_typography.dart';
import 'questwell_scene_load.dart';

/// A shared arrival rhythm: return link, illustrated place, live title, welcome.
/// Scenery is decorative; text remains selectable by accessibility services.
class QuestwellDestinationEntrance extends StatelessWidget {
  const QuestwellDestinationEntrance(
      {super.key,
      required this.destination,
      required this.title,
      required this.subtitle,
      this.onHome,
      this.action,
      this.footer,
      this.ambience});
  final String destination, title, subtitle;
  final VoidCallback? onHome;
  final Widget? action, footer, ambience;

  @override
  Widget build(BuildContext context) => Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Tooltip(
                      message: 'Back to the Hearth',
                      child: TextButton.icon(
                          onPressed: onHome ??
                              () => QuestwellNavigationScope.open(
                                  context, QuestwellDestination.hearth),
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text('Hearth'),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: const Color(0xFFE4C586)))),
                  if (action != null) action!,
                ]),
            Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF192F2C),
                    border:
                        Border.all(color: const Color(0xFF816343), width: 2)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        final style = QuestwellTypography.sectionHeading(
                                size: 12, color: const Color(0xFFF5D898))
                            .copyWith(height: 1.4);
                        final plaqueWidth =
                            MediaQuery.textScalerOf(context).scale(12) > 16
                                ? 1.0
                                : .7;
                        final measure = TextPainter(
                            text: TextSpan(text: title, style: style),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context))
                          ..layout(
                              maxWidth: math.max(
                                  1, constraints.maxWidth * plaqueWidth - 24));
                        final height = math.max(
                            constraints.maxWidth / 2, measure.height + 90);
                        final asset = destination == 'market'
                            ? 'assets/images/questwell_market_shopfront_v3.webp'
                            : 'assets/images/questwell_${destination}_entrance_v1.webp';
                        measure.dispose();
                        return SizedBox(
                            height: height,
                            child: QuestwellSceneLoad(
                                image: AssetImage(asset),
                                label: title,
                                child: Stack(children: [
                                  Positioned.fill(
                                      child: ExcludeSemantics(
                                          child: Image.asset(asset,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox.expand(),
                                              fit: BoxFit.cover,
                                              filterQuality:
                                                  FilterQuality.medium))),
                                  if (ambience != null)
                                    Positioned.fill(child: ambience!),
                                  Positioned.fill(
                                      child: Align(
                                          alignment: const Alignment(0, -.25),
                                          child: FractionallySizedBox(
                                              widthFactor: plaqueWidth,
                                              child: QuestwellHearthFrame(
                                                  warm: true,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 12),
                                                  child: Semantics(
                                                      header: true,
                                                      child: Text(title,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: style)))))),
                                ])));
                      }),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                          child: Column(children: [
                            Text(subtitle,
                                textAlign: TextAlign.center,
                                style: QuestwellTypography.body(
                                    fontSize: 14,
                                    color: const Color(0xFFD8D2B9))),
                            if (footer != null) ...[
                              const SizedBox(height: 14),
                              footer!
                            ],
                          ])),
                    ])),
            const SizedBox(height: 16),
          ])));
}
