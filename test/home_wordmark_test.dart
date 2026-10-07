import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../lib/widgets/questwell_home_overview.dart';
import '../lib/widgets/questwell_home_sections.dart';

void main() {
  for (final width in [320.0, 390.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Full Hearth wordmark fits at $width px / ${scale}x',
          (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        await tester.binding.setSurfaceSize(Size(width, 740));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const Scaffold(
              body: QuestwellHomeCanvas(children: [
            QuestwellHomeHeader(),
            Text('Readable content', style: TextStyle(fontSize: 16)),
          ])),
        )));
        await tester.pump(const Duration(milliseconds: 300));

        final logo =
            tester.renderObject<RenderParagraph>(find.text('QUESTWELL'));
        // A fade can hide letters without producing a Flutter overflow error.
        expect(logo.didExceedMaxLines, isFalse);
        expect(
            logo.size.width,
            greaterThanOrEqualTo(
                logo.getMaxIntrinsicWidth(double.infinity) - .01));
        final painted = Rect.fromPoints(logo.localToGlobal(Offset.zero),
            logo.localToGlobal(logo.size.bottomRight(Offset.zero)));
        final header = tester.getRect(find.byType(QuestwellHomeHeader));
        expect(painted.left, greaterThanOrEqualTo(header.left - .01));
        expect(painted.right, lessThanOrEqualTo(header.right + .01));
        expect(painted.top, greaterThanOrEqualTo(header.top - .01));
        expect(painted.bottom, lessThanOrEqualTo(header.bottom + .01));
        final content =
            tester.renderObject<RenderParagraph>(find.text('Readable content'));
        expect(content.textScaler.scale(16), 16 * scale);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
