import 'package:flutter/material.dart';
import 'questwell_typography.dart';

class QuestwellMarketHomeButton extends StatelessWidget {
  const QuestwellMarketHomeButton({super.key, required this.onHome});
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Go to Hearth',
    child: TextButton.icon(
      onPressed: onHome,
      icon: const Icon(Icons.home_outlined, size: 22),
      label: const Text('Hearth'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFE0BF79),
        textStyle: QuestwellTypography.control(),
        minimumSize: const Size(100, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    ),
  );
}
