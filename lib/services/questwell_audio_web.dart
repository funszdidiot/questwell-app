import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;
import 'questwell_audio.dart';

QuestwellAudioChannel createQuestwellAudioChannel() =>
    QuestwellWebAudioChannel();

/// Keep the context unlocked across asynchronous loads and route changes.
/// A GainNode provides independent volume on iPhone as well as desktop.
class QuestwellWebAudioChannel
    implements QuestwellAudioChannel, QuestwellGestureAudioChannel {
  web.AudioContext? _context;
  web.GainNode? _gain;
  web.AudioBuffer? _buffer;
  web.AudioBufferSourceNode? _source;
  Future<void>? _unlocking;
  double _offset = 0, _startedAt = 0, _volume = 0;
  bool _closed = false;

  @override
  void unlock() {
    if (_closed) return;
    final context = _context ??= web.AudioContext();
    if (_gain == null) {
      _gain = context.createGain();
      _gain!.gain.value = _volume;
      _gain!.connect(context.destination);
    }
    // Invoke resume in the gesture stack, never after a network await.
    _unlocking = context
        .resume()
        .toDart
        .timeout(const Duration(seconds: 3))
        .catchError((Object _) {
      // resume() below checks state and surfaces a retry through the controls.
    });
  }

  @override
  Future<void> prepare(String asset) async {
    final context = _context;
    if (_closed || context == null) throw StateError('Audio needs a tap');
    final data = await rootBundle
        .load('assets/$asset')
        .timeout(const Duration(seconds: 8));
    final bytes = Uint8List.fromList(data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    )).toJS.buffer;
    final buffer = await context
        .decodeAudioData(bytes)
        .toDart
        .timeout(const Duration(seconds: 8));
    if (_closed) return;
    _buffer = buffer;
    _offset = 0;
  }

  @override
  Future<void> resume() async {
    await _unlocking;
    final context = _context;
    final buffer = _buffer;
    if (_closed || context == null || buffer == null) return;
    if (context.state != 'running') {
      await context.resume().toDart.timeout(const Duration(seconds: 3));
    }
    if (context.state != 'running') throw StateError('Audio needs a tap');
    if (_source != null) return;
    final source = context.createBufferSource();
    source.buffer = buffer;
    source.loop = true;
    source.connect(_gain!);
    source.start(0, _offset);
    _startedAt = context.currentTime;
    _source = source;
  }

  @override
  Future<void> pause() async {
    final source = _source;
    if (source == null) return;
    _offset =
        (_offset + _context!.currentTime - _startedAt) % _buffer!.duration;
    _source = null;
    source.stop();
    source.disconnect();
  }

  @override
  Future<void> volume(double value) async {
    _volume = value.clamp(0, 1);
    _gain?.gain.value = _volume;
  }

  @override
  Future<void> close() async {
    _closed = true;
    await pause();
    _buffer = null;
    _gain?.disconnect();
    await _context?.close().toDart;
  }
}
