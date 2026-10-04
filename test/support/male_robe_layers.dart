import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_male_paper_doll.dart';

void expectMaleRobeGarmentOnlyClip(WidgetTester tester, Finder layer) {
  final clips = tester.widgetList<ClipPath>(find.descendant(
      of: layer, matching: find.byType(ClipPath)));
  expect(clips, hasLength(1));
  for (final clip in clips) {
    expect(clip.clipper, isA<MaleRobeUnderlayClipper>());
    expect((clip.child! as Image).image,
        const AssetImage(QuestwellMalePaperDoll.everydayAsset));
  }
  final body = find.descendant(of: layer,
      matching: find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset)));
  expect(body, findsOneWidget);
  expect(find.ancestor(of: body, matching: find.byType(ClipPath)), findsNothing,
      reason: 'Only hidden garment pixels may be clipped, never the body');
}

List<String> maleRobeLayers(String archetype) => [
  QuestwellMalePaperDoll.robeAsset(archetype, 'rear'),
  QuestwellMalePaperDoll.baseAsset,
  QuestwellMalePaperDoll.everydayAsset,
  QuestwellMalePaperDoll.robeAsset(archetype, 'front'),
  QuestwellMalePaperDoll.identityAsset,
  QuestwellMalePaperDoll.robeAsset(archetype, 'collar'),
  QuestwellMalePaperDoll.robeAsset(archetype, 'cuffs'),
];
