import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';
import 'package:project_momentum/pages/expedition_page/expedition_page_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Finder tab(String label) => find.descendant(
      of: find.byType(QuestwellAppNavigation),
      matching: find.widgetWithText(TextButton, label));

  for (final start in QuestwellDestination.values) {
    testWidgets(
        'Direct entry to ${start.label} can reach every page and Hearth',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final router = GoRouter(initialLocation: '/${start.name}', routes: [
        for (final item in QuestwellDestination.values)
          GoRoute(
              path: '/${item.name}',
              name: item.routeName,
              builder: (_, __) => Scaffold(
                  body: Center(child: Text('Screen: ${item.label}')),
                  bottomNavigationBar: QuestwellAppNavigation(current: item))),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: true),
              child: child!)));
      await tester.pumpAndSettle();
      for (final destination in QuestwellDestination.values) {
        await tester.tap(tab('Explore'));
        await tester.pumpAndSettle();
        expect(find.text('You are here'), findsOneWidget);
        final target = find.widgetWithText(ListTile, destination.label);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(find.text('Screen: ${destination.label}'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.tap(tab('Hearth'));
      await tester.pumpAndSettle();
      expect(find.text('Screen: Hearth'), findsOneWidget);
      expect(router.canPop(), isFalse,
          reason: 'Main navigation must not accumulate duplicate pages');
      await tester.tap(tab('Quests'));
      await tester.pumpAndSettle();
      expect(find.text('Screen: Quests'), findsOneWidget);
      expect(tab('Hearth').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('Leaving an unfinished expedition requires a deliberate choice',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    QuestwellDestination? destination;
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: QuestwellNavigationScope(
            onSelect: (value) => destination = value,
            child: const ExpeditionPageWidget())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Begin'));
    await tester.tap(find.text('Begin'));
    await tester.pump();
    await tester.tap(tab('Hearth'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this expedition?'), findsOneWidget);
    await tester.tap(find.text('Stay here'));
    await tester.pumpAndSettle();
    expect(destination, isNull);
    await tester.tap(tab('Hearth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End and leave'));
    await tester.pumpAndSettle();
    expect(destination, QuestwellDestination.hearth);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'Expedition Home confirms running and paused sessions without losing time',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var now = DateTime(2026, 10, 1);
    QuestwellDestination? destination;
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: QuestwellNavigationScope(
            onSelect: (value) => destination = value,
            child: ExpeditionPageWidget(clock: () => now))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Begin'));
    await tester.tap(find.text('Begin'));
    await tester.pump();
    await tester.scrollUntilVisible(find.byTooltip('Back to the Hearth'), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back to the Hearth'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this expedition?'), findsOneWidget);
    expect(destination, isNull);
    await tester.tap(find.text('Stay here'));
    await tester.pumpAndSettle();
    now = now.add(const Duration(seconds: 7));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:53'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    await tester.ensureVisible(find.text('Pause'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    await tester.pump();
    await tester.scrollUntilVisible(find.byTooltip('Back to the Hearth'), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back to the Hearth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stay here'));
    await tester.pumpAndSettle();
    now = now.add(const Duration(seconds: 20));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:53'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(destination, isNull);
    await tester.scrollUntilVisible(find.byTooltip('Back to the Hearth'), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back to the Hearth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End and leave'));
    await tester.pumpAndSettle();
    expect(destination, QuestwellDestination.hearth);
    expect(find.text('Begin'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Device back cannot silently end an active expedition',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    QuestwellDestination? destination;
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: QuestwellNavigationScope(
            onSelect: (value) => destination = value,
            child: const ExpeditionPageWidget())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Begin'));
    await tester.tap(find.text('Begin'));
    await tester.pump();
    final navigator =
        Navigator.of(tester.element(find.byType(ExpeditionPageWidget)));
    await navigator.maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Leave this expedition?'), findsOneWidget);
    await tester.tap(find.text('Stay here'));
    await tester.pumpAndSettle();
    expect(destination, isNull);
    expect(find.text('Pause'), findsOneWidget);
    await navigator.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('End and leave'));
    await tester.pumpAndSettle();
    expect(destination, QuestwellDestination.hearth);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Home leaves idle and completed expeditions without a warning',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var now = DateTime(2026, 10, 1);
    var visits = 0;
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: QuestwellNavigationScope(
            onSelect: (_) => visits++,
            child: ExpeditionPageWidget(
                initialDuration: const Duration(seconds: 1),
                clock: () => now))));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('Back to the Hearth'), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back to the Hearth'));
    await tester.pumpAndSettle();
    expect(visits, 1);
    expect(find.text('Leave this expedition?'), findsNothing);
    await tester.ensureVisible(find.text('Begin'));
    await tester.tap(find.text('Begin'));
    await tester.pump();
    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('EXPEDITION COMPLETE'), findsOneWidget);
    await tester.scrollUntilVisible(find.byTooltip('Back to the Hearth'), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back to the Hearth'));
    await tester.pumpAndSettle();
    expect(visits, 2);
    expect(find.text('Leave this expedition?'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
