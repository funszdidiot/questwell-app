import 'package:flutter/material.dart';
import 'main.dart' as application;
import 'preview/hearth_review.dart';
import 'preview/quest_board_review.dart';
import 'preview/home_sections_review.dart';
import 'preview/adventurer_review.dart';

// Only the development preview workflow targets this entry point.
// The visual fixture uses no account, profile writes, or authentication bypass.
void main() {
  if (Uri.base.queryParameters['review'] == 'hearth') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const HearthReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'quests') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const QuestBoardReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'home') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const HomeSectionsReviewApp());
  } else if (Uri.base.queryParameters['review'] == 'adventurer') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const AdventurerReviewApp());
  } else {
    application.main();
  }
}
