import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_bookshelf.dart';
import 'questwell_fern.dart';
import 'questwell_reading_chair.dart';

/// Authored furniture proportions and floor anchors shared by every Hearth view.
class QuestwellHearthDecor {
  static Positioned positioned({
    required String slug, required String slot, required Size scene,
  }) {
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final front = slot == 'front';
    // Match the asset canvas ratio, avoiding hidden BoxFit padding that makes
    // feet and pots float above their intended floor anchor.
    final ratio = shelf ? 1225 / 1284 : fern ? 1244 / 1264 : 1312 / 1199;
    final widthFraction = shelf ? .25 : fern ? .20 : .26;
    final heightFraction = shelf ? .34 : fern ? .25 : .27;
    final height = math.min(
      scene.width * widthFraction * (front ? 1.08 : 1) / ratio,
      scene.height * (front ? .31 : heightFraction),
    );
    final width = height * ratio;
    final center = scene.width * (front ? .17 : slot == 'left' ? .30 : .85);
    final floor = scene.height * (front ? .97 : .64);
    final art = shelf ? const QuestwellBookshelf()
      : fern ? const QuestwellFern() : const QuestwellReadingChair();
    return Positioned(
      key: ValueKey(shelf ? 'hearth-bookshelf-bounds'
        : fern ? 'hearth-fern-bounds' : 'hearth-chair-bounds'),
      left: center - width / 2, top: floor - height,
      width: width, height: height,
      child: Stack(fit: StackFit.expand, children: [
        Positioned(left: width * .15, right: width * .15, bottom: 0,
          height: height * .055,
          child: DecoratedBox(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const RadialGradient(radius: .65, colors: [
              Color(0x700E0906), Color(0x000E0906),
            ]),
          ))),
        // The source chair opens toward the left. On the left side of the room
        // mirror only its artwork so the seat opens toward the room's center.
        Transform.flip(
          key: ValueKey('hearth-$slug-facing'),
          flipX: !shelf && !fern && slot != 'right',
          child: art,
        ),
      ]),
    );
  }
}
