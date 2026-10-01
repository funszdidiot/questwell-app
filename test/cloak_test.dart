import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_cloak.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching=false;
  test('Cloak depth mask keeps faces and hands in front without cutting across the torso', () {
    for (final body in ['female','male','neutral']) {
      final path=QuestwellCloakForegroundClipper(body).getClip(const Size(240,320));
      expect(path.contains(const Offset(120,50)),isTrue);
      expect(path.contains(Offset(body=='female'?77:70,184)),isTrue);
      expect(path.contains(const Offset(168,184)),isTrue);
      expect(path.contains(const Offset(120,100)),isFalse,reason:'Keep clasp visible');
      expect(path.contains(const Offset(101,155)),isFalse,reason:'Keep front drapes continuous');
      expect(path.contains(const Offset(90,250)),isFalse,reason:'Keep lower cloak over outfit');
    }
  });
  test('Cloaks occlude class collar and epaulettes while keeping torso and cuffs', () {
    for (final body in ['female','male','neutral']) {
      final path = QuestwellCloakUnderlayerClipper(body).getClip(const Size(240,320));
      expect(path.contains(const Offset(120,82)),isFalse,reason:'No competing class collar');
      expect(path.contains(const Offset(80,103)),isFalse,reason:'Left shoulder trim stays tucked');
      expect(path.contains(const Offset(160,103)),isFalse,reason:'Right shoulder trim stays tucked');
      expect(path.contains(const Offset(120,150)),isTrue);
      expect(path.contains(const Offset(70,180)),isTrue);
      expect(path.contains(const Offset(170,180)),isTrue);
      final front = QuestwellCloakForegroundClipper(body).getClip(const Size(240,320));
      expect(front.contains(const Offset(120,81)),isFalse,reason:'No restored shirt strip over cloak');
    }
  });
  testWidgets('Both cloaks load on every supported class and body without hiding base layers', (tester) async {
    for (final slug in ['moss-green-cloak','hearthguard-mantle']) {
      final classes=slug=='hearthguard-mantle'?['guardian']:['scholar','scout','alchemist','guardian','wanderer'];
      for(final archetype in classes) { for(final body in ['female','male','neutral']) {
        await tester.pumpWidget(MaterialApp(home:Center(child:SizedBox(width:240,height:320,
          child:QuestwellLayeredAdventurerArt(archetype:archetype,avatarBodyType:body,equippedSlugs:{'chest':slug})))));
        await tester.pumpAndSettle();
        expect(tester.takeException(),isNull,reason:'$slug/$archetype/$body');
        expect(find.byType(QuestwellCloak),findsNWidgets(2));
        final assets=tester.widgetList<Image>(find.byType(Image)).map((i)=>i.image).whereType<AssetImage>().map((i)=>i.assetName).toList();
        expect(assets,contains('assets/images/questwell/avatar/base/base_$body.webp'));
        expect(assets.where((a)=>a==QuestwellCloak.asset(slug)).length,2);
        expect(assets.any((a)=>a.contains('/classes/$archetype/')),isTrue);
        final fit=QuestwellCloak.bounds(body,slug);
        expect(fit.left,greaterThanOrEqualTo(0));expect(fit.right,lessThanOrEqualTo(240));
        expect(fit.bottom,lessThan(300),reason:'Hem clears the boots');
      }}
    }
    await tester.pumpWidget(const MaterialApp(home:SizedBox(width:240,height:320,
      child:QuestwellLayeredAdventurerArt(archetype:'scholar',equippedSlugs:{}))));
    await tester.pumpAndSettle();expect(find.byType(QuestwellCloak),findsNothing);
  });
}
