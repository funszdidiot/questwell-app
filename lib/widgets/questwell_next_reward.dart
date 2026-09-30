import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/questwell_cosmetic_service.dart';
import 'questwell_pixel_art.dart';

/// A reward teaser within the character card; level progress is shown once above it.
class QuestwellNextReward extends StatelessWidget {
  const QuestwellNextReward({super.key, required this.cosmetics});
  final List<QuestwellCosmetic> cosmetics;

  @override
  Widget build(BuildContext context) {
    final upcoming = cosmetics.where((item) => !item.owned &&
      item.unlockMethod == 'level_milestone' && item.milestoneLevel != null).toList()
      ..sort((a,b) => a.milestoneLevel!.compareTo(b.milestoneLevel!));
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final reward = upcoming.first;
    return Padding(padding: const EdgeInsets.only(top: 14), child: Row(children: [
      QuestwellItemPixelArt(slug: reward.slug, category: reward.category, size: 44),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Next reward · Level ${reward.milestoneLevel}', style: GoogleFonts.roboto(
          fontSize: 12, height: 1.4, color: const Color(0xFFE4C586))),
        Text(reward.name, style: GoogleFonts.roboto(fontSize: 14, height: 1.4,
          color: const Color(0xFFF0E5CC), fontWeight: FontWeight.w700)),
      ])),
    ]));
  }
}
