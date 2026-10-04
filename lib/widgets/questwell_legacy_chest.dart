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

  static String _legacySuitAsset(String body) =>
      'assets/images/questwell/avatar/base/base_$body.webp';

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

  Widget _everydayFoundation() => switch (body) {
        'male' => Stack(fit: StackFit.expand, children: [
            _image(QuestwellMalePaperDoll.baseAsset),
            _image(QuestwellMalePaperDoll.everydayAsset),
          ]),
        'neutral' => const QuestwellScoutWardrobeFoundation(
            body: 'neutral',
            layers: {'top', 'trousers', 'boots'},
          ),
        _ => const QuestwellScoutWardrobeFoundation(
            body: 'female',
            layers: {'top', 'trousers', 'boots'},
          ),
      };

  @override
  Widget build(BuildContext context) {
    final businessSuit = slug == 'starter-business-suit';
    return Stack(
      fit: StackFit.expand,
      children: [
        businessSuit ? _baseOnly() : _everydayFoundation(),
        if (businessSuit)
          ClipPath(
            clipper: _LegacySuitGarmentClipper(body),
            child: _image(_legacySuitAsset(body)),
          ),
        _image(_identity(body)),
      ],
    );
  }
}

/// Retains only legacy suit garment pixels and excludes old face/hair/hands.
///
/// The clip is intentionally coarse and body-specific. It changes no locked
/// body pixels and keeps the legacy suit as a removable overlay.
class _LegacySuitGarmentClipper extends CustomClipper<Path> {
  const _LegacySuitGarmentClipper(this.body);
  final String body;

  @override
  Path getClip(Size size) {
    final headBottom = body == 'female' ? 74.0 : 74.0;
    var path = Path()..addRect(Rect.fromLTRB(0, headBottom, 240, 320));

    final hands = Path();
    if (body == 'female') {
      hands
        ..addRect(const Rect.fromLTRB(58, 164, 91, 202))
        ..addRect(const Rect.fromLTRB(149, 164, 183, 202));
    } else {
      hands
        ..addRect(const Rect.fromLTRB(52, 168, 91, 205))
        ..addRect(const Rect.fromLTRB(149, 168, 189, 205));
    }
    path = Path.combine(PathOperation.difference, path, hands);

    final scale = math.min(size.width / 240, size.height / 320);
    final dx = (size.width - 240 * scale) / 2;
    final dy = size.height - 320 * scale;
    return path
        .transform((Matrix4.identity()..scale(scale, scale)).storage)
        .shift(Offset(dx, dy));
  }

  @override
  bool shouldReclip(covariant _LegacySuitGarmentClipper oldClipper) =>
      body != oldClipper.body;
}
