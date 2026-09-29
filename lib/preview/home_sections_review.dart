import 'package:flutter/material.dart';
import '../widgets/questwell_home_sections.dart';

class HomeSectionsReviewApp extends StatelessWidget {
  const HomeSectionsReviewApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(backgroundColor: const Color(0xFF101A28),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('YOUR NEXT WIN', style: TextStyle(color: Color(0xFFF2D9A0),
            fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 14),
          const QuestwellHomeEmptyBoard(),
          const SizedBox(height: 14),
          QuestwellHomeActions(onOpen: (_) {}),
        ]),
      ))),
    ),
  );
}
