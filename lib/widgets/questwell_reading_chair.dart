import 'package:flutter/material.dart';

class QuestwellReadingChair extends StatelessWidget {
  const QuestwellReadingChair({super.key});
  static const slug = 'burgundy-reading-chair';
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Burgundy reading chair placed in the Hearth', image: true,
    child: IgnorePointer(child: Image.asset(
      'assets/images/questwell/hearth/burgundy_reading_chair.webp',
      fit: BoxFit.contain, filterQuality: FilterQuality.high,
      excludeFromSemantics: true)));
}
