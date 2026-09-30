import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';
import '../widgets/questwell_leather_satchel.dart';
import '../widgets/questwell_brass_lantern.dart';
import '../widgets/questwell_moonstone_brooch.dart';

class ScarfFitReviewApp extends StatelessWidget {
  const ScarfFitReviewApp({super.key, this.satchel = false, this.lantern = false, this.brooch = false});
  final bool brooch;
  final bool lantern;
  final bool satchel;
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
                  height: 280, equippedSlugs: {if (brooch) 'accessory': QuestwellMoonstoneBrooch.slug, if (lantern) 'hands': QuestwellBrassLantern.slug, if (satchel) 'back': QuestwellLeatherSatchel.slug, 'neck': 'emerald-scholar-scarf',
                    'head': 'tiny-wizard-hat', 'face': 'round-scholar-glasses'}),
              ])),
            )]),
          ],
        ]),
      ))),
    ),
  );
}
