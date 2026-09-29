import 'package:flutter/material.dart';
import 'main.dart' as application;
import 'preview/hearth_review.dart';

// Only the development preview workflow targets this entry point.
// The visual fixture uses no account, profile writes, or authentication bypass.
void main() {
  if (Uri.base.queryParameters['review'] == 'hearth') {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const HearthReviewApp());
  } else {
    application.main();
  }
}
