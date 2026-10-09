import 'package:flutter/material.dart';

/// One registered 384x512 tile from a 4x2 sheet. A single decoded image prevents
/// frame-loading flashes. Clip before scaling so neighboring tiles never leak.
class QuestwellPetFrame extends StatelessWidget {
  const QuestwellPetFrame({super.key, required this.frame, required this.sheet})
    : assert(frame >= 0 && frame < 8);
  final int frame;
  final Widget sheet;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.contain,
    alignment: Alignment.bottomCenter,
    child: SizedBox(
      width: 384,
      height: 512,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 1536,
          maxWidth: 1536,
          minHeight: 1024,
          maxHeight: 1024,
          child: Transform.translate(
            offset: Offset(-(frame % 4) * 384.0, -(frame ~/ 4) * 512.0),
            child: sheet,
          ),
        ),
      ),
    ),
  );
}
