import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/preview/mobile_review.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';
import 'package:project_momentum/widgets/questwell_app_style.dart';
import 'package:project_momentum/widgets/questwell_delete_account.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final screen in [
    'Hearth',
    'Quests',
    'New quest',
    'Market',
    'Adventurer',
    'Boss Battles',
    'Chronicle',
    'Expedition'
  ]) {
    for (final setting in [(390.0, 1.0), (320.0, 2.0)]) {
      testWidgets(
          '$screen uses the shared shell at ${setting.$1}/${setting.$2}',
          (tester) async {
        final font = FontLoader('HearthSerif')
          ..addFont(rootBundle.load('assets/fonts/DejaVuSerif-Bold.ttf'));
        await font.load();
        await tester.binding.setSurfaceSize(const Size(1000, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(TickerMode(
            enabled: false,
            child: MobileReviewApp(
                initialScreen: screen,
                initialWidth: setting.$1,
                initialTextScale: setting.$2)));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(QuestwellAppNavigation), findsOneWidget);
        expect(find.text('Hearth'), findsWidgets);
        expect(tester.takeException(), isNull,
            reason: '$screen must preserve layout with the common navigation');
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('Deletion keeps its warning color under the shared button theme',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: QuestwellAppStyle.theme(),
        home: Scaffold(
            body: QuestwellDeleteAccountButton(
                preview: true, onDelete: () async {}, onDeleted: () {}))));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Permanently delete'));
    expect(button.style!.backgroundColor!.resolve({}), const Color(0xFF9E352E));
    // A local red fill must not inherit the theme's emerald painting layer.
    const child = SizedBox(width: 4, height: 4);
    expect(
        button.style!.backgroundBuilder!(
            tester.element(find.byType(AlertDialog)), {}, child),
        same(child));
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
