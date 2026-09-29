import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';

class HearthReviewApp extends StatefulWidget {
  const HearthReviewApp({super.key});

  @override
  State<HearthReviewApp> createState() => _HearthReviewAppState();
}

class _HearthReviewAppState extends State<HearthReviewApp> {
  String _archetype = 'wanderer';
  String _body = 'neutral';
  double _width = 390;

  @override
  void initState() {
    super.initState();
    _checkAssetDecoding();
  }

  Future<void> _checkAssetDecoding() async {
    const asset = 'assets/images/questwell/avatar/base/base_neutral.webp';
    try {
      final bytes = await rootBundle.load(asset);
      debugPrint('Hearth review: loaded ${bytes.lengthInBytes} base bytes');
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      final frame = await codec.getNextFrame();
      debugPrint('Hearth review: decoded ${frame.image.width} x ${frame.image.height}');
      frame.image.dispose(); codec.dispose();
    } catch (error) {
      debugPrint('Hearth review decoding error: $error');
    }
  }

  Widget _choice<T>(String label, T value, List<T> values,
      String Function(T) title, ValueChanged<T> changed) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label  '),
      DropdownButton<T>(
        key: ValueKey(label),
        value: value,
        items: values.map((item) => DropdownMenuItem<T>(
          value: item, child: Text(title(item)),
        )).toList(),
        onChanged: (item) { if (item != null) changed(item); },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: false),
      home: Scaffold(
        backgroundColor: const Color(0xFF111827),
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          final viewport = math.min(_width, constraints.maxWidth);
          final compact = viewport < 430;
          return SingleChildScrollView(child: Center(child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 4),
                child: Text('Hearth integration review',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text('Preview choices do not change your saved profile.',
                  textAlign: TextAlign.center),
              ),
              Padding(padding: const EdgeInsets.all(12), child: Wrap(
                spacing: 18, runSpacing: 4, alignment: WrapAlignment.center,
                children: [
                  _choice('Class', _archetype,
                    ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer'],
                    (s) => s[0].toUpperCase() + s.substring(1),
                    (s) => setState(() => _archetype = s)),
                  _choice('Body', _body, ['male', 'female', 'neutral'],
                    (s) => s == 'neutral' ? 'Gender Neutral' : s[0].toUpperCase() + s.substring(1),
                    (s) => setState(() => _body = s)),
                  _choice('Width', _width, [320.0, 390.0, 430.0, 768.0],
                    (v) => '${v.toInt()} px',
                    (v) => setState(() => _width = v)),
                ],
              )),
              SizedBox(width: viewport, child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(children: [
                  QuestwellHearthPixelScene(
                    key: const ValueKey('review-hearth'),
                    height: compact ? 342 : 392,
                    archetype: _archetype, avatarBodyType: _body,
                  ),
                  const SizedBox(height: 24),
                  const Text('Matching Adventurer portrait'),
                  const SizedBox(height: 12),
                  QuestwellEquippedAvatar(
                    key: const ValueKey('review-adventurer'),
                    archetype: _archetype, avatarBodyType: _body,
                    equippedSlugs: const {}, height: 286, artHeightFactor: .96,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Check boot contact, robe visibility, room brightness and framing. '
                      'Epic 2 awaits final iPhone Safari acceptance.', textAlign: TextAlign.center)),
                ]),
              )),
            ],
          )));
        })),
      ),
    );
  }
}
