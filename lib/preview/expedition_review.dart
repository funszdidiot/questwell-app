import 'package:flutter/material.dart';
import '../pages/expedition_page/expedition_page_widget.dart';

/// The real local-only timer, with no account reads or progress writes.
class ExpeditionReviewApp extends StatelessWidget {
  const ExpeditionReviewApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Questwell · Expedition preview',
    theme: ThemeData(brightness: Brightness.dark, useMaterial3: false),
    home: const ExpeditionPageWidget(),
  );
}
