import 'package:flutter/material.dart';

import '../widgets/questwell_scout_wardrobe.dart';
import '../widgets/questwell_male_paper_doll.dart';
import '../widgets/questwell_neutral_paper_doll.dart';

/// Single-overlay outfit inspection using the runtime's locked foundations and
/// identity renderers. Layered robes/cloaks require their own runtime review.
class QuestwellSeasonalWearablePreview extends StatelessWidget {
  const QuestwellSeasonalWearablePreview({
    super.key,
    required this.body,
    this.overlay,
    this.showBody = true,
  });
  final String body;
  final String? overlay;
  final bool showBody;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (showBody)
        QuestwellScoutWardrobeFoundation(body: body, layers: const {}),
      if (overlay != null) QuestwellScoutWardrobeFoundation.image(overlay!),
      if (showBody && overlay != null)
        if (body == 'male')
          const QuestwellMaleIdentity()
        else
          QuestwellScoutWardrobeFoundation.image(
            body == 'female'
                ? QuestwellScoutWardrobeFoundation.femaleIdentityAsset
                : QuestwellNeutralPaperDoll.identityAsset,
          ),
    ],
  );
}
