import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/preview/market_catalog.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/widgets/questwell_adventurer_view.dart';
import '../lib/widgets/questwell_market_view.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  const retiredSlug = 'pathfinder-boots';

  test('Pathfinder is retired from rendering and the advertised catalog', () {
    expect(QuestwellEquipmentPolicy.isRetired(retiredSlug), isTrue);
    expect(QuestwellEquipmentPolicy.isReady(retiredSlug, 'feet'), isFalse);
    expect(QuestwellEquipmentPolicy.renderReadySlugs, isNot(contains(retiredSlug)));
    expect(marketReviewCatalog.any((item) => item['slug'] == retiredSlug), isFalse);
  });

  testWidgets('Historical Pathfinder equipment never changes any body or outfit', (tester) async {
    for (final body in ['female', 'male', 'neutral']) {
      for (final archetype in ['scout', 'scholar', 'alchemist', 'guardian', 'wanderer']) {
        for (final chest in [null, 'starter-business-suit', 'moss-green-cloak']) {
          Future<List<String>> render(Map<String, String> equipment) async {
            await tester.pumpWidget(MaterialApp(home: SizedBox(width: 240, height: 320,
              child: QuestwellLayeredAdventurerArt(archetype: archetype,
                avatarBodyType: body, equippedSlugs: equipment))));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            return tester.widgetList<Image>(find.byType(Image))
              .map((image) => image.image).whereType<AssetImage>()
              .map((image) => image.assetName).toList();
          }
          final without = <String, String>{if (chest != null) 'chest': chest};
          final baseline = await render(without);
          final saved = {...without, 'feet': retiredSlug};
          final original = Map<String, String>.of(saved);
          expect(await render(saved), baseline);
          expect(saved, original, reason: 'Rendering must not alter persisted equipment');
          expect(baseline.any((path) => path.contains('pathfinder')), isFalse);
          if (body == 'neutral' && chest == null) {
            expect(baseline, contains('assets/images/questwell/avatar/everyday_boots_neutral_v3.webp'));
            expect(find.byType(ClipPath), findsNothing);
          }
          expect(await render(without), baseline);
        }
      }
    }
  });

  testWidgets('Server-returned historical boots are hidden from Market and inventory', (tester) async {
    final retired = QuestwellCosmetic.fromJson({
      'id': 'historical-boots', 'slug': retiredSlug, 'name': 'Pathfinder Boots',
      'category': 'feet', 'rarity': 'rare', 'description': 'Historical item',
      'price': 160, 'premium': false, 'unlock_method': 'shop',
    }, owned: true, equipped: true);
    var writes = 0;
    // The Market sign animates continuously; reduce motion while checking data
    // visibility so pumpAndSettle can finish without changing these assertions.
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(body: QuestwellMarketView(
      data: QuestwellCosmeticsSnapshot(profile: const QuestwellProfile(
        level: 5, totalXp: 500, coinBalance: 200, currentEnergyMode: 'normal',
        onboardingCompleted: true, adventurerArchetype: 'scout', avatarBodyType: 'neutral'),
        cosmetics: [retired]),
      onPurchase: (_) async { writes++; }, onEquip: (_) async { writes++; },
      onUnequip: (_) async { writes++; }, onRefresh: () async {},
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Pathfinder Boots'), findsNothing);
    expect(find.text('0 treasures'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellAdventurerView(
      archetype: 'scout', bodyType: 'neutral', level: 5, xp: 500, coins: 200,
      description: '', mastered: false, collectionOwned: 0, collectionTotal: 0,
      relicName: '', canClaim: false,
      items: const [AdventurerInventoryItem(id: 'historical-boots', name: 'Pathfinder Boots',
        slug: retiredSlug, category: 'feet', description: '', owned: true,
        equipped: true, classLocked: false, shop: true)],
      onClaim: () {}, onBody: (_) {}, onClass: (_) {}, onMarket: () {}, onBack: () {},
      onEquip: (_) { writes++; }, onUnequip: (_) { writes++; },
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Pathfinder Boots'), findsNothing);
    expect(find.text('Inventory · 0'), findsOneWidget);
    expect(find.text('Nothing equipped yet.'), findsOneWidget);
    expect(writes, 0);
    expect(retired.owned && retired.equipped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
