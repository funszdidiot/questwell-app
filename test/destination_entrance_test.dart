import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_destination_entrance.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final width in [320.0, 390.0, 430.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('All arrival signs preserve whole words at $width/$scale',
          (tester) async {
        final font = FontLoader(GoogleFonts.pressStart2p().fontFamily!)
          ..addFont(rootBundle.load('assets/fonts/PressStart2P-Regular.ttf'));
        await font.load();
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        for (final entry in const {
          'quests': 'QUEST BOARD',
          'bosses': 'BOSS BATTLES',
          'adventurer': 'ADVENTURER',
          'chronicle': 'CHRONICLE',
          'expedition': 'EXPEDITION',
          'market': 'MARKET'
        }.entries) {
          var home = false;
          var settings = false;
          await tester.pumpWidget(MaterialApp(
              home: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: Scaffold(
                      body: SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: QuestwellDestinationEntrance(
                              destination: entry.key,
                              title: entry.value,
                              subtitle: 'Welcome, adventurer.',
                              onHome: () => home = true,
                              action: IconButton(
                                  tooltip: 'Account settings',
                                  onPressed: () => settings = true,
                                  icon: const Icon(Icons.settings))))))));
          await tester.pump();
          final title =
              tester.renderObject<RenderParagraph>(find.text(entry.value));
          var offset = 0;
          for (final word in entry.value.split(' ')) {
            expect(
                title.getBoxesForSelection(TextSelection(
                    baseOffset: offset, extentOffset: offset + word.length)),
                hasLength(1),
                reason: entry.value);
            offset += word.length + 1;
          }
          expect(title.textScaler.scale(12), 12 * scale);
          await tester.tap(find.text('Hearth'));
          await tester.tap(find.byTooltip('Account settings'));
          expect(home && settings, isTrue);
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
