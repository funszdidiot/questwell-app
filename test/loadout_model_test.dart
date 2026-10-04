import 'package:flutter_test/flutter_test.dart';
import '../lib/services/questwell_loadout_model.dart';

void main() {
  test('shared loadout model preserves renderer slot semantics', () {
    expect(
      QuestwellLoadoutModel.renderKey(category: 'chest'),
      'chest',
    );
    expect(
      QuestwellLoadoutModel.renderKey(category: 'room'),
      'room:right',
    );
    expect(
      QuestwellLoadoutModel.renderKey(category: 'room', roomSlot: 'floor'),
      'room:floor',
    );
    expect(
      QuestwellLoadoutModel.renderKey(
        category: 'wall_art',
        roomSlot: 'wall_left',
      ),
      'wall_art:wall_left',
    );
    expect(
      QuestwellLoadoutModel.renderKey(
        category: 'wall_art',
        roomSlot: 'wall_center',
      ),
      'wall_art',
    );
  });

  test('inventory grouping is shared across Market and Adventurer', () {
    expect(QuestwellLoadoutModel.inventoryGroup('room'), 'Hearth');
    expect(QuestwellLoadoutModel.inventoryGroup('wall_art'), 'Hearth');
    expect(QuestwellLoadoutModel.inventoryGroup('familiar'), 'Familiars');
    expect(QuestwellLoadoutModel.inventoryGroup('effect'), 'Effects');
    expect(QuestwellLoadoutModel.inventoryGroup('chest'), 'Outfits');
    expect(QuestwellLoadoutModel.inventoryGroup('hands'), 'Gear');
  });

  test('explicit room and wall-art keys remain stable', () {
    expect(QuestwellLoadoutModel.roomRenderKey('front'), 'room:front');
    expect(QuestwellLoadoutModel.wallArtRenderKey('wall_center'), 'wall_art');
    expect(
      QuestwellLoadoutModel.wallArtRenderKey('wall_right'),
      'wall_art:wall_right',
    );
  });
}
