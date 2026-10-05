import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_scout_wardrobe.dart';
import 'questwell_neutral_paper_doll.dart';
import 'questwell_male_paper_doll.dart';

/// Legacy chest garments composed over the locked paper-doll foundations.
///
/// This prevents Business Suit / Harvest Coat / closed-cloak states from
/// restoring legacy anatomy. Garments remain reusable visual surfaces; the
/// approved body and identity remain authoritative.
class QuestwellLegacyChestFoundation extends StatelessWidget {
  const QuestwellLegacyChestFoundation({
    super.key,
    required this.body,
    required this.slug,
  });

  final String body;
  final String slug;

  static const supported = {
    'starter-business-suit',
    'midnight-harvest-coat',
    'moss-green-cloak',
    'hearthguard-mantle',
  };

  static String suitAsset(String body) =>
      'assets/images/questwell/avatar/business_suit_${body}_v1.webp';

  static String harvestAsset(String body) {
    final version = body == 'female' ? 'v4' : 'v3';
    return 'assets/images/questwell/avatar/harvest_coat_${body}_$version.webp';
  }

  static String _identity(String body) => switch (body) {
        'male' => QuestwellMalePaperDoll.identityAsset,
        'neutral' => QuestwellNeutralPaperDoll.identityAsset,
        _ => QuestwellScoutWardrobeFoundation.femaleIdentityAsset,
      };

  Widget _image(String asset) => Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );

  Widget _baseOnly() => switch (body) {
        'male' => _image(QuestwellMalePaperDoll.baseAsset),
        'neutral' => const QuestwellNeutralPaperDoll(),
        _ => _image(QuestwellScoutWardrobeFoundation.femaleBaseAsset),
      };

  Widget _everydayFoundation() {
    final garments = body == 'male'
        ? <Widget>[_image(QuestwellMalePaperDoll.everydayAsset)]
        : <Widget>[
            for (final part in ['boots', 'trousers', 'top'])
              _image(QuestwellScoutWardrobeFoundation.asset(body, part)),
          ];
    return Stack(fit: StackFit.expand, children: [
      _baseOnly(),
      if (slug == 'midnight-harvest-coat')
        ClipPath(
          clipper: const HarvestEverydayGarmentClipper(),
          child: Stack(fit: StackFit.expand, children: garments),
        )
      else
        ...garments,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final businessSuit = slug == 'starter-business-suit';
    return Stack(
      fit: StackFit.expand,
      children: [
        businessSuit ? _baseOnly() : _everydayFoundation(),
        if (businessSuit) _image(suitAsset(body)),
        _image(_identity(body)),
      ],
    );
  }
}

/// The coat supplies its own shirt and sleeves. Only hidden Everyday garment
/// pixels are excluded; the complete locked body is an unclipped sibling.
class HarvestEverydayGarmentClipper extends CustomClipper<Path> {
  const HarvestEverydayGarmentClipper();
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    return (Path()..addRect(const Rect.fromLTRB(0, 150, 240, 320)))
        .transform((Matrix4.identity()..scale(scale, scale)).storage)
        .shift(Offset((size.width - 240 * scale) / 2, size.height - 320 * scale));
  }
  @override
  bool shouldReclip(covariant HarvestEverydayGarmentClipper oldClipper) => false;
}
