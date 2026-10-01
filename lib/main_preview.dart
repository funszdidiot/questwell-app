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
import 'preview/boots_review.dart';
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
  if (Uri.base.queryParameters['review'] == 'mastery') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MobileReviewApp(initialScreen: 'Adventurer', masteryPreview: true)));
  } else if (Uri.base.queryParameters['review'] == 'new-quest') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MobileReviewApp(initialScreen: 'New quest')));
  } else if (Uri.base.queryParameters['review'] == 'navigation') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MobileReviewApp(initialScreen: 'Hearth')));
  } else if (Uri.base.queryParameters['review'] == 'mobile') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MobileReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'campfire') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ExpeditionReviewApp(quickFinish: true)));
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
    runApp(QuestwellPreviewNavigationHost(child: const BootsReviewApp()));
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
    runApp(QuestwellPreviewNavigationHost(child: const MilestoneRoadmapReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'starlit-orrery') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthPolishReviewApp(firstJourney: true, orrery: true)));
  } else if (Uri.base.queryParameters['review'] == 'first-journey') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthPolishReviewApp(firstJourney: true)));
  } else if (Uri.base.queryParameters['review'] == 'hearth-polish') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthPolishReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'hearth-decor') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthDecorReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'bookshelf') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthReviewApp(bookshelf: true)));
  } else if (Uri.base.queryParameters['review'] == 'hearth') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HearthReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'quests') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MobileReviewApp(initialScreen: 'Quests')));
  } else if (Uri.base.queryParameters['review'] == 'home') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const HomeSectionsReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'adventurer') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const MobileReviewApp(initialScreen: 'Adventurer')));
  } else if (Uri.base.queryParameters['review'] == 'scarf-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ScarfFitReviewApp()));
  } else if (Uri.base.queryParameters['review'] == 'satchel-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ScarfFitReviewApp(satchel: true)));
  } else if (Uri.base.queryParameters['review'] == 'brooch-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ScarfFitReviewApp(satchel: true, lantern: true, brooch: true)));
  } else if (Uri.base.queryParameters['review'] == 'brooch') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EquipmentReviewApp(headwear: true, neckwear: true, satchel: true, lantern: true, brooch: true)));
  } else if (Uri.base.queryParameters['review'] == 'lantern-matrix') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const ScarfFitReviewApp(satchel: true, lantern: true)));
  } else if (Uri.base.queryParameters['review'] == 'lantern') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EquipmentReviewApp(headwear: true, neckwear: true, satchel: true, lantern: true)));
  } else if (Uri.base.queryParameters['review'] == 'satchel') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EquipmentReviewApp(headwear: true, neckwear: true, satchel: true)));
  } else if (Uri.base.queryParameters['review'] == 'scarf') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EquipmentReviewApp(headwear: true, neckwear: true)));
  } else if (Uri.base.queryParameters['review'] == 'headwear') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EquipmentReviewApp(headwear: true)));
  } else if (Uri.base.queryParameters['review'] == 'equipment') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(QuestwellPreviewNavigationHost(child: const EquipmentReviewApp()));
  } else {
    application.main();
  }
}

