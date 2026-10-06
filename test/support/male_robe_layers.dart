import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_male_paper_doll.dart';

void expectMaleRobeGarmentOnlyClip(WidgetTester tester, Finder layer) {
  final clips = tester.widgetList<ClipPath>(find.descendant(
      of: layer, matching: find.byType(ClipPath)));
  expect(clips, hasLength(2));
  for (final clip in clips) {
    expect(clip.clipper, anyOf(isA<MaleRobeUnderlayClipper>(), isA<MaleIdentityClipper>()));
    expect((clip.child! as Image).image,
        AssetImage(clip.clipper is MaleIdentityClipper
            ? QuestwellMalePaperDoll.baseAsset : QuestwellMalePaperDoll.everydayAsset));
  }
  final body = find.descendant(of: layer,
      matching: find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset)));
  expect(body, findsNWidgets(2));
  expect(find.ancestor(of: body.first, matching: find.byType(ClipPath)), findsNothing,
      reason: 'The primary body must remain complete and unclipped');
}

List<String> maleRobeLayers(String archetype) => [
  QuestwellMalePaperDoll.robeAsset(archetype, 'rear'),
  QuestwellMalePaperDoll.baseAsset,
  QuestwellMalePaperDoll.everydayAsset,
  QuestwellMalePaperDoll.robeAsset(archetype, 'front'),
  QuestwellMalePaperDoll.baseAsset,
  QuestwellMalePaperDoll.robeAsset(archetype, 'collar'),
  QuestwellMalePaperDoll.robeAsset(archetype, 'cuffs'),
];
