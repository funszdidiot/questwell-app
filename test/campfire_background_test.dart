import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_campfire_background.dart';

void main() {
  testWidgets('Embers follow mode, preserve taps and stop with reduced motion', (tester) async {
    var taps = 0;
    Widget scene({required bool active, bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: QuestwellCampfireBackground(active: active,
          child: Center(child: TextButton(onPressed: () => taps++, child: const Text('Quest'))))),
      ),
    );
    await tester.pumpWidget(scene(active: false));
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(active: true));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.tap(find.text('Quest'));
    expect(taps, 1);
    await tester.pumpWidget(scene(active: true, reduceMotion: true));
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(active: false));
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
