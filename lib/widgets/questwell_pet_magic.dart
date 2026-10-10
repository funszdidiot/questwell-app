import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_pet_motion.dart';

/// Shares the companion's clock; no additional ticker or asset downloads.
class QuestwellPetMagicPainter extends CustomPainter {
  const QuestwellPetMagicPainter(
      {required this.slug, required this.phase, this.still = false});
  final String slug;
  final double phase;
  final bool still;

  /// Windows align with the authored wiggle (dog) and slow blink (cat).
  static double progress(String slug, double phase) {
    if (!QuestwellPetMotion.names.containsKey(slug) ||
        !phase.isFinite ||
        phase < 0 ||
        phase > 1) return -1;
    final ms = phase * QuestwellPetMotion.duration(slug).inMilliseconds;
    final start = slug == 'boston-terrier' ? 8470 : 3300;
    final end = slug == 'boston-terrier' ? 9600 : 4300;
    return ms >= start && ms < end ? (ms - start) / (end - start) : -1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!QuestwellPetMotion.names.containsKey(slug) ||
        !phase.isFinite ||
        phase < 0 ||
        phase > 1) return;
    final action = progress(slug, phase);
    final burst = still || action < 0 ? 0.0 : math.sin(math.pi * action);
    // Always visible from the first frame. The existing action adds a shimmer,
    // rather than leaving the familiar without magic for most of its loop.
    final t = still ? .4 : .5 - .5 * math.cos(phase * math.pi * 2);
    final alpha = still ? .7 : .62 + burst * .33;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 54, size.height / 72);
    final paint = Paint()..isAntiAlias = true;
    if (slug == 'boston-terrier') {
      for (var i = 0; i < 6; i++) {
        final x = i.isEven ? 5.0 + (i % 3) * 2 : 45.0 + (i % 3) * 2;
        final y = 58 - (i % 3) * 6 - t * 7;
        paint.color = const Color(0xFFFFBA43).withValues(alpha: alpha * .22);
        canvas.drawCircle(Offset(x, y), 3.5 + burst, paint);
        paint.color = const Color(0xFFFFE4A3).withValues(alpha: alpha);
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: 4, height: 1.5),
            paint);
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: 1.5, height: 4),
            paint);
      }
    } else {
      // Crescent on the empty left margin, clear of eyes and collar artwork.
      final outer = Path()..addOval(const Rect.fromLTWH(1, 24, 10, 12));
      final cutout = Path()..addOval(const Rect.fromLTWH(5, 22, 9, 12));
      paint.color = const Color(0xFFA89CEB).withValues(alpha: alpha * .2);
      canvas.drawCircle(const Offset(6, 30), 7, paint);
      paint.color = const Color(0xFFE9E3FF).withValues(alpha: alpha);
      canvas.drawPath(
          Path.combine(PathOperation.difference, outer, cutout), paint);
      for (var i = 0; i < 4; i++) {
        paint.color = const Color(0xFFEBECFA).withValues(alpha: alpha * .8);
        canvas.drawCircle(
            Offset(i.isEven ? 5 : 49, 44.0 + i * 5 - t * 6), 1.3, paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant QuestwellPetMagicPainter oldDelegate) =>
      slug != oldDelegate.slug ||
      phase != oldDelegate.phase ||
      still != oldDelegate.still;
}
