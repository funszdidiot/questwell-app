import '../../lib/widgets/questwell_male_paper_doll.dart';

List<String> maleRobeLayers(String archetype) => [
  QuestwellMalePaperDoll.robeAsset(archetype, 'rear'),
  QuestwellMalePaperDoll.baseAsset,
  QuestwellMalePaperDoll.everydayAsset,
  QuestwellMalePaperDoll.robeAsset(archetype, 'front'),
  QuestwellMalePaperDoll.identityAsset,
  QuestwellMalePaperDoll.robeAsset(archetype, 'collar'),
  QuestwellMalePaperDoll.robeAsset(archetype, 'cuffs'),
];
