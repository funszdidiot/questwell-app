import 'preview/autumn_hearth_review.dart';
import 'preview/audio_review.dart';
import 'preview/hollow_harvest_review.dart';
import 'preview/halloween_costumes_review.dart';
import 'preview/quest_completion_review.dart';
import 'preview/hallowed_hearth_review.dart';
import 'preview/neutral_scout_review.dart';
import 'preview/legacy_wardrobe_review.dart';
import 'preview/male_everyday_review.dart';
import 'preview/male_class_robes_review.dart';
import 'preview/neutral_robes_review.dart';
import 'preview/neutral_paper_doll_review.dart';
import 'preview/scout_wardrobe_review.dart';
import 'preview/clean_base_review.dart';
import 'preview/autumn_lantern_review.dart';
import 'preview/harvest_display_review.dart';
import 'preview/harvest_coat_review.dart';
import 'preview/hearth_settings_review.dart';
import 'preview/wanderer_cuff_review.dart';
import 'preview/rug_review.dart';
import 'preview/issue6_decor_review.dart';
import 'preview/seasonal_gallery_review.dart';
import 'package:flutter/material.dart';
import 'preview/mobile_review.dart';
import 'preview/expedition_review.dart';
import 'preview/boss_review.dart';
import 'preview/effects_review.dart';
import 'main.dart' as application;
import 'preview/hearth_review.dart';
import 'preview/chronicle_review.dart';
import 'preview/market_review.dart';
import 'preview/familiar_review.dart';
import 'preview/cloak_review.dart';
import 'preview/wayfarer_review.dart';
import 'preview/grimoire_review.dart';
import 'preview/milestone_roadmap_review.dart';
import 'preview/hearth_polish_review.dart';
import 'preview/hearth_decor_review.dart';
import 'preview/home_sections_review.dart';
import 'preview/adventurer_review.dart';
import 'preview/equipment_review.dart';
import 'preview/scarf_fit_review.dart';

// Only the development preview workflow targets this entry point.
// The visual fixture uses no account, profile writes, or authentication bypass.
void main() {
  if (Uri.base.queryParameters['review'] == 'audio') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const QuestwellAudioReview());
  } else if (Uri.base.queryParameters['review'] == 'autumn-hearth') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const AutumnHearthReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'hollow-harvest') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const HollowHarvestReview());
  } else if (Uri.base.queryParameters['review'] == 'halloween-costumes') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const HalloweenCostumesReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'quest-completion') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const QuestCompletionReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'hallowed-hearth') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const HallowedHearthReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'legacy-wardrobe') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const LegacyWardrobeReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'male-woodland') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MaleEverydayReviewApp(initialWoodland: true));
  } else if (Uri.base.queryParameters['review'] == 'male-robes') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MaleClassRobesReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'male-robe') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MaleEverydayReviewApp(
      initialRobe: true,
      initialArchetype: Uri.base.queryParameters['class'] ?? 'scout',
    ));
  } else if (Uri.base.queryParameters['review'] == 'male-everyday') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MaleEverydayReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'neutral-robes') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const NeutralRobesReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'neutral-scout') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const NeutralScoutReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'neutral-paper-doll') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const NeutralPaperDollReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'woodland-scout') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScoutWardrobeReviewApp(woodland: true)));
  } else if (Uri.base.queryParameters['review'] == 'alchemist-wardrobe') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScoutWardrobeReviewApp(archetype: 'alchemist')));
  } else if (Uri.base.queryParameters['review'] == 'scholar-wardrobe') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScoutWardrobeReviewApp(archetype: 'scholar')));
  } else if (Uri.base.queryParameters['review'] == 'guardian-wardrobe') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScoutWardrobeReviewApp(archetype: 'guardian')));
  } else if (Uri.base.queryParameters['review'] == 'wanderer-wardrobe') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScoutWardrobeReviewApp(archetype: 'wanderer')));
  } else if (Uri.base.queryParameters['review'] == 'scout-wardrobe') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const ScoutWardrobeReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'clean-bases') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const CleanBaseReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'autumn-lantern') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const AutumnLanternReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'harvest-display') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const HarvestDisplayReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'harvest-coat') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HarvestCoatReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'hearth-settings') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const HearthSettingsReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'wanderer-cuffs') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const WandererCuffReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'rug') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const RugReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'issue6-decor') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const Issue6DecorReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'seasonal-gallery') {
    WidgetsFlutterBinding.ensureInitialized();
    final requested =
        Uri.base.queryParameters['collection'] ?? 'seasonal-review-fixture';
    final safeCollection = RegExp(r'^[a-z0-9-]+$').hasMatch(requested)
        ? requested
        : 'seasonal-review-fixture';
    final manifestAsset =
        'assets/jsons/' + safeCollection.replaceAll('-', '_') + '.json';
    runApp(QuestwellSeasonalGalleryReviewApp(
      manifestAsset: manifestAsset,
      initialSlug: Uri.base.queryParameters['item'],
    ));
  } else if (Uri.base.queryParameters['review'] == 'mastery') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const MobileReviewApp(
            initialScreen: 'Adventurer', masteryPreview: true)));
  } else if (Uri.base.queryParameters['review'] == 'new-quest') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const MobileReviewApp(initialScreen: 'New quest')));
  } else if (Uri.base.queryParameters['review'] == 'navigation') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const MobileReviewApp(initialScreen: 'Hearth')));
  } else if (Uri.base.queryParameters['review'] == 'mobile') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MobileReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'campfire') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ExpeditionReviewApp(quickFinish: true)));
  } else if (Uri.base.queryParameters['review'] == 'expedition') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ExpeditionReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'boss') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const BossReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'effects') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EffectsReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'boots') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const NeutralRobesReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'grimoire') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const GrimoireReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'wayfarer') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const WayfarerReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'cloaks') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const CloakReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'companions') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const FamiliarReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'market') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MarketReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'chronicle') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ChronicleReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'milestones') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const MilestoneRoadmapReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'starlit-orrery') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const HearthPolishReviewApp(firstJourney: true, orrery: true)));
  } else if (Uri.base.queryParameters['review'] == 'first-journey') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const HearthPolishReviewApp(firstJourney: true)));
  } else if (Uri.base.queryParameters['review'] == 'hearth-polish') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const HearthPolishReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'hearth-decor') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthDecorReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'bookshelf') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const HearthReviewApp(bookshelf: true)));
  } else if (Uri.base.queryParameters['review'] == 'hearth') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'quests') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const MobileReviewApp(initialScreen: 'Quests')));
  } else if (Uri.base.queryParameters['review'] == 'home') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
        QuestwellPreviewNavigationHost(child: const HomeSectionsReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'adventurer') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const MobileReviewApp(initialScreen: 'Adventurer')));
  } else if (Uri.base.queryParameters['review'] == 'scarf-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ScarfFitReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'satchel-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScarfFitReviewApp(satchel: true)));
  } else if (Uri.base.queryParameters['review'] == 'brooch-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScarfFitReviewApp(
            satchel: true, lantern: true, brooch: true)));
  } else if (Uri.base.queryParameters['review'] == 'brooch') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const EquipmentReviewApp(
            headwear: true,
            neckwear: true,
            satchel: true,
            lantern: true,
            brooch: true)));
  } else if (Uri.base.queryParameters['review'] == 'lantern-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const ScarfFitReviewApp(satchel: true, lantern: true)));
  } else if (Uri.base.queryParameters['review'] == 'lantern') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const EquipmentReviewApp(
            headwear: true, neckwear: true, satchel: true, lantern: true)));
  } else if (Uri.base.queryParameters['review'] == 'satchel') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const EquipmentReviewApp(
            headwear: true, neckwear: true, satchel: true)));
  } else if (Uri.base.queryParameters['review'] == 'scarf') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const EquipmentReviewApp(headwear: true, neckwear: true)));
  } else if (Uri.base.queryParameters['review'] == 'headwear') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(
        child: const EquipmentReviewApp(headwear: true)));
  } else if (Uri.base.queryParameters['review'] == 'equipment') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EquipmentReviewApp()));
  } else {
    application.main();
  }
}
