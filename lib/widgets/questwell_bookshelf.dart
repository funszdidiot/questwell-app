import 'package:flutter/material.dart';

/// A room decoration: never rendered on the avatar or in a clothing slot.
class QuestwellBookshelf extends StatelessWidget {
  const QuestwellBookshelf({super.key});
  static const slug = 'walnut-bookshelf';
  static const asset = 'assets/images/questwell/hearth/walnut_bookshelf_front_v1.webp';

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Walnut bookshelf placed in the Hearth',
    image: true,
    child: IgnorePointer(child: Image.asset(asset,
      fit: BoxFit.contain, filterQuality: FilterQuality.high,
      gaplessPlayback: true, excludeFromSemantics: true)),
  );
}
