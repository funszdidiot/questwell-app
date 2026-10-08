import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/widgets/questwell_market_view.dart';
import '../lib/widgets/questwell_app_style.dart';

QuestwellCosmetic item(String id, String category, int price,
        {String edition = 'standard', String? slot, String? profile}) =>
    QuestwellCosmetic.fromJson({
      'id': id,
      'slug': id,
      'name': id,
      'category': category,
      'price': price,
      'unlock_method': 'shop',
      'edition_type': edition,
      'hearth_profile_key': profile,
    },
        hearthPlacements: slot == null
            ? const []
            : [
                QuestwellHearthPlacementOption(
                    slot: slot, label: slot, sortOrder: 0)
              ]);

Widget market(List<QuestwellCosmetic> items, {double scale = 1}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: QuestwellAppStyle.theme(),
    home: QuestwellScaffold(
        body: MediaQuery(
            data: MediaQueryData(
                disableAnimations: true, textScaler: TextScaler.linear(scale)),
            child: QuestwellMarketView(
                data: QuestwellCosmeticsSnapshot(
                    profile: const QuestwellProfile(
                        level: 1,
                        totalXp: 0,
                        coinBalance: 100,
                        currentEnergyMode: 'normal',
                        onboardingCompleted: true,
                        adventurerArchetype: 'scout',
                        avatarBodyType: 'neutral'),
                    cosmetics: items),
                onPurchase: (_) async {},
                onEquip: (_) async {},
                onUnequip: (_) async {},
                onRefresh: () async {}))));

Future<void> choose(WidgetTester tester, String label) async {
  final browse = find.byKey(const ValueKey('market-browse-type'));
  await tester.dragUntilVisible(
      browse.hitTestable(), find.byType(ListView), const Offset(0, -140));
  await tester.tap(browse);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('type selection and search keep matching items grouped',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 6000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final data = [
      item('Pet', 'familiar', 1),
      item('Coat', 'chest', 90),
      item('Robe', 'chest', 40),
      item('Scarf', 'neck', 20)
    ];
    await tester.pumpWidget(market(data));
    await tester.pumpAndSettle();
    final section = find.byKey(const ValueKey('market-section-Outfits'));
    await tester.dragUntilVisible(
        section, find.byType(ListView), const Offset(0, -140));
    expect(find.descendant(of: section, matching: find.text('2 treasures')),
        findsOneWidget);
    expect(tester.getTopLeft(find.byKey(const ValueKey('Coat'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('Scarf'))).dy));
    expect(tester.getTopLeft(find.byKey(const ValueKey('Scarf'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('Pet'))).dy));
    expect(tester.getTopLeft(find.byKey(const ValueKey('Robe'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('Coat'))).dy));
    expect(
        find.byKey(const ValueKey('market-section-Familiars')), findsOneWidget);
    // Type navigation removes unrelated cards rather than making users scroll.
    await tester.drag(find.byType(ListView), const Offset(0, 700));
    await tester.pumpAndSettle();
    await choose(tester, 'Familiars');
    expect(find.byKey(const ValueKey('Coat')), findsNothing);
    expect(find.byKey(const ValueKey('market-section-Outfits')), findsNothing);
    expect(find.byKey(const ValueKey('Pet')), findsOneWidget);
    await choose(tester, 'All treasures');
    final search = find.byType(TextField);
    await tester.dragUntilVisible(
        search.hitTestable(), find.byType(ListView), const Offset(0, 140));
    await tester.enterText(search, 'Scarf');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('market-section-Gear')), findsOneWidget);
    expect(find.byKey(const ValueKey('market-section-Outfits')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Hearth metadata groups settings rugs and wall art before furniture',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 6000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(market([
      item('Chair', 'room', 1, slot: 'right'),
      item('Scene', 'room', 100, slot: 'setting'),
      item('Rug', 'room', 20, slot: 'floor'),
      item('Painting', 'wall_art', 10),
      // New profile with no placement data must not inherit legacy slug guesses.
      item('enchanted-library', 'room', 2, profile: 'new-unknown-profile'),
    ]));
    await tester.pumpAndSettle();
    await choose(tester, 'Hearth');
    for (final label in [
      'Hearth settings',
      'Rugs & floor decor',
      'Wall art',
      'Furniture & decor'
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    final positions = ['Scene', 'Rug', 'Painting', 'Chair']
        .map((id) => tester.getTopLeft(find.byKey(ValueKey(id))).dy)
        .toList();
    expect(positions[0], lessThan(positions[1]));
    expect(positions[1], lessThan(positions[2]));
    expect(positions[2], lessThan(positions[3]));
    expect(tester.takeException(), isNull);
  });

  testWidgets('seasonal selection survives refreshed catalog at 200% text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final standard = item('Pet', 'familiar', 1);
    await tester.pumpWidget(market(
        [standard, item('Season pet', 'familiar', 10, edition: 'seasonal')],
        scale: 2));
    await tester.pumpAndSettle();
    await choose(tester, 'Seasonal');
    await tester.pumpWidget(market([standard], scale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final reset = find.text('Reset filters');
    await tester.dragUntilVisible(
        reset.hitTestable(), find.byType(ListView), const Offset(0, -140));
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('Pet')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
