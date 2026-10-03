import 'package:flutter/material.dart';

import '../widgets/questwell_neutral_paper_doll.dart';

/// Foundation approval comes before body-specific Scout and robe fitting.
/// This development route has no account or wardrobe mutations.
class NeutralPaperDollReviewApp extends StatelessWidget {
  const NeutralPaperDollReviewApp({super.key});

  Widget detail(String title, Rect region, double width) {
    final scale = width / region.width;
    return Column(children: [
      Text(title, style: const TextStyle(color: Color(0xFFE0C481), fontSize: 18)),
      const SizedBox(height: 12),
      ClipRect(
        child: SizedBox(
          width: width,
          height: region.height * scale,
          child: Stack(children: [
            Positioned(
              left: -region.left * scale,
              top: -region.top * scale,
              width: 240 * scale,
              height: 320 * scale,
              child: const QuestwellNeutralPaperDoll(),
            ),
          ]),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF1F3937),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(children: [
                    const Text('The gender-neutral paper doll',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, color: Color(0xFFE0C481))),
                    const SizedBox(height: 10),
                    const Text('One fixed body for the Scout outfit and robes.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('Approved neutral frame',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth < 320
                          ? constraints.maxWidth : 320.0;
                      return Wrap(
                        spacing: 64,
                        runSpacing: 30,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(width: width, child: const AspectRatio(
                            aspectRatio: 240 / 320,
                            child: QuestwellNeutralPaperDoll(),
                          )),
                          SizedBox(width: width, child: Column(children: [
                            detail('Wrists and hands',
                                const Rect.fromLTRB(54, 152, 190, 204), width),
                            const SizedBox(height: 28),
                            detail('Hips, stance and feet',
                                const Rect.fromLTRB(68, 145, 191, 314), width),
                          ])),
                        ],
                      );
                    }),
                    const SizedBox(height: 28),
                    const Text(
                      'Original face and hair. The approved frame stays fixed beneath the clothing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
