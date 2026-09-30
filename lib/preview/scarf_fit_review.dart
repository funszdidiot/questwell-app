import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';

class ScarfFitReviewApp extends StatelessWidget {
  const ScarfFitReviewApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(backgroundColor: const Color(0xFF111827),
      body: SingleChildScrollView(child: Center(child: SizedBox(width: 900,
        child: Column(children: [
          for (final kind in ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer']) ...[
            Padding(padding: const EdgeInsets.all(16),
              child: Text(kind.toUpperCase(), style: QuestwellTypography.sectionHeading())),
            Row(children: [for (final body in ['male', 'female', 'neutral']) Expanded(
              child: Padding(padding: const EdgeInsets.all(6), child: Column(children: [
                Text(body, style: GoogleFonts.roboto(fontSize: 14)),
                const SizedBox(height: 6),
                QuestwellEquippedAvatar(archetype: kind, avatarBodyType: body,
                  height: 280, equippedSlugs: const {'neck': 'emerald-scholar-scarf',
                    'head': 'tiny-wizard-hat', 'face': 'round-scholar-glasses'}),
              ])),
            )]),
          ],
        ]),
      ))),
    ),
  );
}
