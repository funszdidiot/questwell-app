import 'package:flutter_test/flutter_test.dart';
import '../lib/services/questwell_progression.dart';
import '../lib/services/questwell_cosmetic_service.dart';

void main() {
  test('Gentle curve boundaries and carryover stay consistent', () {
    final thresholds = [0, 100, 215, 345, 490, 650];
    for (var i = 0; i < thresholds.length; i++) {
      final level = i + 1;
      expect(QuestwellProgression.totalAtLevel(level), thresholds[i]);
      expect(QuestwellProgression.xpToNextLevel(level), 100 + i * 15);
      expect(QuestwellProgression.levelForXp(thresholds[i]), level);
      expect(QuestwellProgression.xpIntoLevel(thresholds[i]), 0);
      if (i > 0) {
        expect(QuestwellProgression.levelForXp(thresholds[i] - 1), level - 1);
      }
    }
    expect(QuestwellProgression.levelForXp(260), 3);
    expect(QuestwellProgression.xpIntoLevel(260), 45);
    expect(QuestwellProgression.levelForXp(-10), 1);
    expect(QuestwellProgression.xpIntoLevel(-10), 0);
    for (final level in [25, 100, 1000, 10000]) {
      final threshold = QuestwellProgression.totalAtLevel(level);
      expect(QuestwellProgression.levelForXp(threshold - 1), level - 1);
      expect(QuestwellProgression.levelForXp(threshold), level);
    }
  });

  test('Legacy credit preserves level and earned XP without counting as rewards', () {
    final profile = QuestwellProfile.fromJson({
      'level': 4, 'total_xp': 355, 'level_xp_offset': 45, 'coin_balance': 79,
    });
    expect(profile.level, 4);
    expect(profile.totalXp, 355);
    expect(profile.coinBalance, 79);
    expect(profile.xpIntoLevel, 55);
    expect(QuestwellProgression.xpToNextLevel(profile.level) - profile.xpIntoLevel, 90);
    expect(QuestwellProgression.levelForXp(444, legacyOffset: 45), 4);
    expect(QuestwellProgression.levelForXp(445, legacyOffset: 45), 5);
    expect(QuestwellProgression.xpIntoLevel(455, legacyOffset: 45), 10);
  });
}
