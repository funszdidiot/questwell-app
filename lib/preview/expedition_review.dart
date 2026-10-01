import 'package:flutter/material.dart';
import '../pages/expedition_page/expedition_page_widget.dart';

/// The real local-only timer, with no account reads or progress writes.
class ExpeditionReviewApp extends StatelessWidget {
  const ExpeditionReviewApp({super.key, this.quickFinish = false});
  final bool quickFinish;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Questwell · Expedition preview',
    theme: ThemeData(brightness: Brightness.dark, useMaterial3: false),
    home: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (quickFinish) const Material(
        color: Color(0xFF244C3E),
        child: SafeArea(bottom: false, child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('Campfire preview · Tap Begin Expedition for a 5-second journey.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFFFF0C9), fontSize: 14, height: 1.4)),
        )),
      ),
      Expanded(child: ExpeditionPageWidget(
        initialDuration: quickFinish ? const Duration(seconds: 5) : const Duration(minutes: 25),
      )),
    ]),
  );
}
