import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';

/// Local visual fixture only: never owns items or writes equipment to an account.
class EquipmentReviewApp extends StatefulWidget {
  const EquipmentReviewApp({super.key});
  @override
  State<EquipmentReviewApp> createState() => _EquipmentReviewAppState();
}

class _EquipmentReviewAppState extends State<EquipmentReviewApp> {
  String _body = 'female';
  bool _glasses = true;

  @override
  Widget build(BuildContext context) {
    final equipment = _glasses
        ? const {'face': 'round-scholar-glasses'} : const <String, String>{};
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)),
      home: Scaffold(backgroundColor: const Color(0xFF111827),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Text('Scholar glasses', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 12),
            const Text('A warm brass frame, with room for a little curiosity. Preview only.'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: ['female', 'male', 'neutral'].map((body) =>
              ChoiceChip(label: Text(body[0].toUpperCase() + body.substring(1)),
                labelStyle: GoogleFonts.roboto(fontSize: 14),
                selected: _body == body,
                onSelected: (_) => setState(() => _body = body))).toList()),
            SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Try on glasses'), value: _glasses,
              onChanged: (value) => setState(() => _glasses = value)),
            QuestwellEquippedAvatar(archetype: 'scholar', avatarBodyType: _body,
              equippedSlugs: equipment, height: 340, artHeightFactor: .98),
            const SizedBox(height: 24),
            Text('At the Hearth', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 12),
            QuestwellHearthPixelScene(archetype: 'scholar', avatarBodyType: _body,
              equippedSlugs: equipment, height: 342),
          ]),
        ))),
      ),
    );
  }
}
