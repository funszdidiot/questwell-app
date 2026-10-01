import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';
import 'package:project_momentum/pages/expedition_page/expedition_page_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Finder tab(String label) => find.descendant(of: find.byType(QuestwellAppNavigation),
    matching: find.widgetWithText(TextButton, label));

  for (final start in QuestwellDestination.values) {
    testWidgets('Direct entry to ${start.label} can reach every page and Hearth', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final router = GoRouter(initialLocation: '/${start.name}', routes: [
        for (final item in QuestwellDestination.values)
          GoRoute(path: '/${item.name}', name: item.routeName, builder: (_, __) => Scaffold(
            body: Center(child: Text('Screen: ${item.label}')),
            bottomNavigationBar: QuestwellAppNavigation(current: item))),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router,
        builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2), disableAnimations: true), child: child!)));
      await tester.pumpAndSettle();
      for (final destination in QuestwellDestination.values) {
        await tester.tap(tab('Explore')); await tester.pumpAndSettle();
        expect(find.text('You are here'), findsOneWidget);
        final target = find.widgetWithText(ListTile, destination.label);
        await tester.ensureVisible(target); await tester.pumpAndSettle();
        await tester.tap(target); await tester.pumpAndSettle();
        expect(find.text('Screen: ${destination.label}'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.tap(tab('Hearth')); await tester.pumpAndSettle();
      expect(find.text('Screen: Hearth'), findsOneWidget);
      expect(router.canPop(), isFalse, reason: 'Main navigation must not accumulate duplicate pages');
      await tester.tap(tab('Quests')); await tester.pumpAndSettle();
      expect(find.text('Screen: Quests'), findsOneWidget);
      expect(tab('Hearth').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('Leaving an unfinished expedition requires a deliberate choice', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    QuestwellDestination? destination;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: QuestwellNavigationScope(onSelect: (value) => destination = value,
        child: const ExpeditionPageWidget())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Begin Expedition'));
    await tester.tap(find.text('Begin Expedition')); await tester.pump();
    await tester.tap(tab('Hearth')); await tester.pumpAndSettle();
    expect(find.text('Leave this expedition?'), findsOneWidget);
    await tester.tap(find.text('Stay here')); await tester.pumpAndSettle();
    expect(destination, isNull);
    await tester.tap(tab('Hearth')); await tester.pumpAndSettle();
    await tester.tap(find.text('End and leave')); await tester.pumpAndSettle();
    expect(destination, QuestwellDestination.hearth);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
