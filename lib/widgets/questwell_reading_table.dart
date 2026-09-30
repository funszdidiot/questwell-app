import 'package:flutter/material.dart';

class QuestwellReadingTable extends StatelessWidget {
  const QuestwellReadingTable({super.key});
  static const slug = 'walnut-reading-table';
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Walnut reading table with books and candle placed in the Hearth', image: true,
    child: IgnorePointer(child: Image.asset(
      'assets/images/questwell/hearth/walnut_reading_table.webp',
      fit: BoxFit.contain, filterQuality: FilterQuality.high,
      excludeFromSemantics: true)));
}
