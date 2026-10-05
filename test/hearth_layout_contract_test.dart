import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_hearth_layout.dart';
import '../lib/widgets/questwell_room_picker.dart';

void main() {
  test('same Hearth family uses the same visual scale and ground line per slot', () {
    const scene = Size(390, 420);

    final autumn = QuestwellHearthLayout.bounds(
      slug: 'autumn-ember-lantern',
      slot: 'right',
      scene: scene,
    );
    final warding = QuestwellHearthLayout.bounds(
      slug: 'warding-lantern',
      slot: 'right',
      scene: scene,
    );

    expect(autumn.height, closeTo(warding.height, .01));
    expect(autumn.bottom, closeTo(warding.bottom, .01));

    final shelf = QuestwellHearthLayout.bounds(
      slug: 'walnut-bookshelf',
      slot: 'left',
      scene: scene,
    );
    final workbench = QuestwellHearthLayout.bounds(
      slug: 'copper-potion-workbench',
      slot: 'left',
      scene: scene,
    );
    final harvest = QuestwellHearthLayout.bounds(
      slug: 'harvest-apothecary-display',
      slot: 'left',
      scene: scene,
    );

    expect(shelf.height, closeTo(workbench.height, .01));
    expect(workbench.height, closeTo(harvest.height, .01));
    expect(
      shelf.top + shelf.height *
          QuestwellHearthLayout.profile('walnut-bookshelf')!.visibleBase,
      closeTo(
        workbench.top + workbench.height *
            QuestwellHearthLayout.profile('copper-potion-workbench')!.visibleBase,
        .01,
      ),
    );
  });

  test('pedestal lights share one placement vocabulary', () {
    expect(
      QuestwellHearthLayout.choicesFor('autumn-ember-lantern'),
      const {'left': 'Back left', 'right': 'Back right'},
    );
    expect(
      QuestwellHearthLayout.choicesFor('warding-lantern'),
      const {'left': 'Back left', 'right': 'Back right'},
    );
  });

  testWidgets('room picker prefers backend placement choices', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    RoomPlacement? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            result = await showRoomPicker(
              context,
              name: 'Future Seasonal Lamp',
              id: 'future-lamp',
              slug: 'unregistered-future-lamp',
              archetype: 'wanderer',
              bodyType: 'neutral',
              equippedSlugs: const {},
              occupants: const {},
              placementChoices: const {
                'left': 'Backend left',
                'right': 'Backend right',
              },
            );
          },
          child: const Text('Open'),
        ),
      )),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Backend left'), findsOneWidget);
    expect(find.text('Backend right'), findsOneWidget);
    expect(find.text('Foreground'), findsNothing);

    await tester.tap(find.text('Backend right'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save placement'));
    await tester.pumpAndSettle();

    expect(result?.slot, 'right');
  });
}
