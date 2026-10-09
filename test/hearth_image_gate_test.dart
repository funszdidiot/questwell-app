import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_hearth_image_gate.dart';

class PendingImage extends ImageProvider<PendingImage> {
  PendingStream stream = PendingStream();
  int loads = 0;
  @override
  Future<PendingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(
      PendingImage key, ImageDecoderCallback decode) {
    loads++;
    return stream;
  }

  void complete() => stream.complete();
}

class PendingStream extends ImageStreamCompleter {
  void complete() {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.amber, BlendMode.src);
    setImage(ImageInfo(image: recorder.endRecording().toImageSync(1, 1)));
  }

  void fail() => reportError(
      context: ErrorDescription('test image'),
      exception: StateError('offline'),
      silent: true);
}

void main() {
  testWidgets('retry remounts failed child Image streams', (tester) async {
    final provider = PendingImage();
    await tester.pumpWidget(MaterialApp(
        home: SizedBox(
            width: 390,
            height: 390,
            child: QuestwellHearthImageGate(
                images: [provider],
                child: Image(
                    image: provider,
                    errorBuilder: (_, __, ___) =>
                        const Text('Failed child'))))));
    provider.stream.fail();
    await tester.pump();
    await tester.pump();
    expect(find.text('Retry artwork'), findsOneWidget);
    provider.stream = PendingStream();
    await tester.tap(find.text('Retry artwork'));
    await tester.pump();
    provider.complete();
    await tester.pump();
    await tester.pump();
    expect(find.text('Failed child'), findsNothing);
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
  });

  testWidgets(
      'waits for every selected image and ignores obsolete room completion',
      (tester) async {
    final background = PendingImage();
    final window = PendingImage();
    final nextRoom = PendingImage();
    Future<void> show(List<ImageProvider> images) async {
      await tester.pumpWidget(MaterialApp(
          home: SizedBox(
              width: 390,
              height: 390,
              child: QuestwellHearthImageGate(
                  images: images, child: const Text('Room')))));
    }

    double opacity() =>
        tester.widget<Opacity>(find.byType(Opacity).first).opacity;
    await show([background, window]);
    background.complete();
    await tester.pump();
    expect(opacity(), 0);
    await show([nextRoom]);
    window.complete();
    await tester.pump();
    expect(opacity(), 0);
    nextRoom.complete();
    await tester.pump();
    await tester.pump();
    expect(opacity(), 1);
    expect(find.text('Preparing your Hearth…'), findsNothing);
  });
}
