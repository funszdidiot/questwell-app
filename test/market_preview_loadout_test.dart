import 'package:flutter_test/flutter_test.dart';

import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/widgets/questwell_market_preview.dart';
import 'market_preview_placement_test.dart' show decor;

void main() {
  Map<String, String>? preview(
    QuestwellCosmetic item, [
    List<QuestwellCosmetic> others = const [],
  ]) => QuestwellMarketPreview.equipment(
    QuestwellCosmeticsSnapshot(
      profile: QuestwellProfile.fromJson({}),
      cosmetics: [...others, item],
    ),
    item,
  );

  test('preview prefers a free legal spot and leaves saved loadout intact', () {
    final chair = decor(
      'burgundy-reading-chair',
      equipped: true,
      slot: 'right',
    );
    final plant = decor(
      'new-plant',
      profile: 'plant',
      slots: ['left', 'right', 'front'],
    );
    expect(preview(plant, [chair]), {
      'room:right': chair.slug,
      'room:left': plant.slug,
    });
    expect(chair.roomSlot, 'right');
    expect(chair.equipped, isTrue);
    expect(plant.equipped, isFalse);
  });
  test(
    'shelf-only item requires a bookcase; mantel remains a safe alternative',
    () {
      final trophy = decor('new-trophy', slots: ['bookshelf_top']);
      expect(preview(trophy), isNull);
      final shelf = decor('walnut-bookshelf', equipped: true, slot: 'left');
      expect(preview(trophy, [shelf]), {
        'room:left': shelf.slug,
        'room:bookshelf_top': trophy.slug,
      });
      expect(preview(decor('new-trophy', slots: ['bookshelf_top', 'mantel'])), {
        'room:mantel': 'new-trophy',
      });
    },
  );
  test(
    'backend profile without placements does not silently use legacy slots',
    () {
      expect(
        preview(decor('walnut-bookshelf', profile: 'large_furniture')),
        isNull,
      );
    },
  );
  test('legacy known room families keep their canonical anchors', () {
    for (final entry in {
      'rainy-window': 'window',
      'emerald-wayfarer-rug': 'floor',
      'enchanted-library': 'setting',
      'walnut-reading-table': 'side',
    }.entries) {
      expect(preview(decor(entry.key)), {'room:${entry.value}': entry.key});
    }
    expect(preview(decor('moonlit-woodland', category: 'wall_art')), {
      'wall_art': 'moonlit-woodland',
    });
  });
}
