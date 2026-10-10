import 'package:flutter_test/flutter_test.dart';
import '../lib/services/questwell_cosmetic_models.dart';

void main() {
  const old = {
    'render_kind': 'static_sprite',
    'asset_source': 'bundle',
    'asset_path': 'assets/images/questwell/hearth/witchlight_bookcase_v1.webp',
    'canvas_width': 1024,
    'canvas_height': 1536,
    'visible_base': 1.0,
    'shadow_profile': 'wide_plinth',
    'filter_mode': 'pixel',
    'asset_revision': 1,
  };
  test('old catalog bookcase resolves artwork and floor contact together', () {
    final spec = QuestwellHearthRenderSpec.fromJson(old);
    expect(spec.assetPath, endsWith('witchlight_bookcase_front_v2.webp'));
    expect(spec.assetRevision, 2);
    expect(spec.aspectRatio, 1024 / 1536);
    expect(spec.visibleBase, 1507 / 1536);
    expect(spec.shadowProfile, 'wide_plinth');
    expect(spec.renderKind, 'static_sprite');
    expect(spec.pixelated, isTrue);
    expect(old['asset_revision'], 1);
  });
  test('network, unrelated assets and newer registry revisions are untouched',
      () {
    for (final json in [
      {...old, 'asset_source': 'network'},
      {...old, 'asset_revision': 3},
      {...old, 'asset_path': 'another-bundled-asset.webp'},
    ]) {
      final spec = QuestwellHearthRenderSpec.fromJson(json);
      expect(spec.assetPath, json['asset_path']);
      expect(spec.assetSource, json['asset_source']);
      expect(spec.assetRevision, json['asset_revision']);
      expect(spec.visibleBase, json['visible_base']);
    }
  });
}
