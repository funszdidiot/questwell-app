import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/widgets/questwell_amberfall_window.dart';
import '../lib/widgets/questwell_catalog_equipment.dart';
import '../lib/widgets/questwell_hearth_catalog_sprite.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  final manifest = jsonDecode(
      File('docs/releases/autumn-hearth-2026/manifest.json')
          .readAsStringSync()) as Map<String, dynamic>;
  final rows = (manifest['items'] as List).cast<Map<String, dynamic>>();
  test('approved release pricing, renderer readiness and all-body eligibility',
      () {
    expect(rows.fold<int>(0, (sum, row) => sum + (row['price'] as int)), 660);
    for (final row in rows) {
      final slug = row['slug'] as String;
      expect(QuestwellEquipmentPolicy.isReady(slug, 'room'), isTrue);
      for (final body in ['female', 'male', 'neutral']) {
        expect(QuestwellEquipmentPolicy.supportsBody(slug, body), isTrue);
      }
      expect(row['required_archetype'], isNull);
      expect(row['premium'], isFalse);
    }
  });
  testWidgets(
      'real Hearth equips and replaces Amberfall without changing rooms',
      (tester) async {
    Future<void> show(String? window, QuestwellHearthSetting setting) async {
      await tester.pumpWidget(MaterialApp(
          home: TickerMode(
              enabled: false,
              child: SizedBox(
                  width: 390,
                  child: QuestwellHearthPixelScene(
                    height: 390,
                    immersive: true,
                    showAvatar: false,
                    setting: setting,
                    equippedSlugs: {if (window != null) 'room:window': window},
                  )))));
      await tester.pump();
    }

    await show('amberfall-window', QuestwellHearthSetting.original);
    expect(find.byType(QuestwellAmberfallWindow), findsOneWidget);
    expect(
        tester
            .widget<QuestwellAmberfallWindow>(
                find.byType(QuestwellAmberfallWindow))
            .hallowed,
        isFalse);
    await show('rainy-window', QuestwellHearthSetting.original);
    expect(find.byType(QuestwellAmberfallWindow), findsNothing);
    expect(find.byType(QuestwellRainyWindow), findsOneWidget);
    await show(null, QuestwellHearthSetting.original);
    expect(find.byType(QuestwellRainyWindow), findsNothing);
    await show('amberfall-window', QuestwellHearthSetting.hallowedHearth);
    expect(
        tester
            .widget<QuestwellAmberfallWindow>(
                find.byType(QuestwellAmberfallWindow))
            .hallowed,
        isTrue);
    await show('amberfall-window', QuestwellHearthSetting.enchantedLibrary);
    expect(find.byType(QuestwellAmberfallWindow), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('release registry renders the four approved floor pieces',
      (tester) async {
    final profiles = <String, String>{};
    final renders = <String, QuestwellHearthRenderSpec>{};
    for (final row in rows) {
      final hearth = row['hearth'] as Map<String, dynamic>;
      profiles[row['slug']] = hearth['profile_key'];
      if (hearth['render'] != null) {
        renders[row['slug']] =
            QuestwellHearthRenderSpec.fromJson(hearth['render']);
      }
    }
    await tester.pumpWidget(MaterialApp(
        home: TickerMode(
            enabled: false,
            child: QuestwellHearthPixelScene(
              height: 390,
              immersive: true,
              showAvatar: false,
              equippedSlugs: const {
                'room:window': 'amberfall-window',
                'room:floor': 'maple-hearth-rug',
                'room:right': 'mooncap-grove',
                'room:left': 'harvest-lanterns',
                'room:front': 'sages-rest'
              },
              hearthProfileBySlug: profiles,
              hearthRenderBySlug: renders,
            ))));
    await tester.pump();
    expect(find.byType(QuestwellAmberfallWindow), findsOneWidget);
    expect(find.byType(QuestwellHearthFloorSprite), findsOneWidget);
    expect(find.byType(QuestwellHearthCatalogSprite), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
