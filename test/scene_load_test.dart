import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_scene_load.dart';

class ControlledStream extends ImageStreamCompleter {
  void succeed(ui.Image image) => setImage(ImageInfo(image: image));
  void fail() => reportError(
      exception: StateError('fixture download failed'), silent: true);
}

class ControlledImage extends ImageProvider<ControlledImage> {
  ControlledStream stream = ControlledStream();
  int retries = 0;
  bool failEviction = false;
  @override
  Future<ControlledImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream target,
          ControlledImage key, ImageErrorListener handleError) =>
      target.setCompleter(PaintingBinding.instance.imageCache
          .putIfAbsent(key, () => stream, onError: handleError)!);
  @override
  Future<bool> evict(
      {ImageCache? cache,
      ImageConfiguration configuration = ImageConfiguration.empty}) async {
    retries++;
    if (failEviction) throw StateError('fixture eviction failed');
    await super.evict(cache: cache, configuration: configuration);
    stream = ControlledStream();
    return true;
  }
}

Widget scene(ControlledImage image, String label) => MaterialApp(
    home: Scaffold(
        body: SizedBox(
            width: 320,
            height: 240,
            child: QuestwellSceneLoad(
                image: image,
                label: label,
                child: Image(
                    image: image,
                    errorBuilder: (_, __, ___) => const SizedBox.expand())))));

void main() {
  tearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
  testWidgets('retry cache failure stays recoverable', (tester) async {
    final image = ControlledImage()..failEviction = true;
    await tester.pumpWidget(scene(image, 'Workshop'));
    image.stream.fail();
    await tester.pump();
    await tester.tap(find.text('Retry artwork'));
    await tester.pump();
    expect(find.text('Workshop could not load.'), findsOneWidget);
    expect(find.text('Retry artwork'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'pending selection is identified, late prior room cannot replace it',
      (tester) async {
    final a = ControlledImage();
    final b = ControlledImage();
    final pendingDownload = a.stream.keepAlive();
    final first =
        (await tester.runAsync(() => createTestImage(width: 2, height: 2)))!;
    final second =
        (await tester.runAsync(() => createTestImage(width: 2, height: 2)))!;
    await tester.pumpWidget(scene(a, 'Room A'));
    expect(find.text('Loading Room A…'), findsOneWidget);
    await tester.pumpWidget(scene(b, 'Room B'));
    a.stream.succeed(first);
    pendingDownload.dispose();
    await tester.pump();
    expect(find.text('Loading Room B…'), findsOneWidget);
    b.stream.succeed(second);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'failed artwork can retry successfully without changing selection',
      (tester) async {
    final image = ControlledImage();
    final frame =
        (await tester.runAsync(() => createTestImage(width: 2, height: 2)))!;
    await tester.pumpWidget(scene(image, 'Workshop'));
    image.stream.fail();
    await tester.pump();
    expect(find.text('Workshop could not load.'), findsOneWidget);
    await tester.tap(find.text('Retry artwork'));
    await tester.pump();
    expect(image.retries, 1);
    expect(find.text('Loading Workshop…'), findsOneWidget);
    image.stream.succeed(frame);
    await tester.pump();
    expect(find.text('Retry artwork'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'stalled artwork stops spinning and offers retry; disposal is safe',
      (tester) async {
    await tester.pumpWidget(scene(ControlledImage(), 'Library'));
    await tester.pump(const Duration(seconds: 12));
    expect(find.text('Library could not load.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(scene(ControlledImage(), 'Cottage'));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 20));
    expect(tester.takeException(), isNull);
  });
}
