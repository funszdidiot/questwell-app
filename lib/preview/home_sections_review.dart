import 'package:flutter/material.dart';
import '../widgets/questwell_home_sections.dart';
import '../widgets/questwell_campfire_background.dart';

class HomeSectionsReviewApp extends StatefulWidget {
  const HomeSectionsReviewApp({super.key});
  @override
  State<HomeSectionsReviewApp> createState() => _HomeSectionsReviewAppState();
}

class _HomeSectionsReviewAppState extends State<HomeSectionsReviewApp> {
  bool _campfire = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(backgroundColor: const Color(0xFF101A28),
      body: QuestwellCampfireBackground(active: _campfire, child: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          SwitchListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Campfire Mode'),
            subtitle: const Text('One small win at a time.'),
            value: _campfire, activeThumbColor: const Color(0xFFFFBC6B),
            onChanged: (value) => setState(() => _campfire = value)),
          const SizedBox(height: 24),
          const Text('YOUR NEXT WIN', style: TextStyle(color: Color(0xFFF2D9A0),
            fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 14),
          const QuestwellHomeEmptyBoard(),
          const SizedBox(height: 14),
          QuestwellHomeActions(onOpen: (_) {}),
        ]),
      )))),
    ),
  );
}
