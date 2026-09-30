import 'package:flutter/material.dart';
class QuestwellFern extends StatelessWidget {
  const QuestwellFern({super.key});
  static const slug = 'hearth-fern';
  @override
  Widget build(BuildContext context) => Semantics(label: 'Fern placed in the Hearth', image: true,
    child: IgnorePointer(child: Image.asset('assets/images/questwell/hearth/hearth_fern.webp',
      fit: BoxFit.contain, filterQuality: FilterQuality.high, excludeFromSemantics: true)));
}
