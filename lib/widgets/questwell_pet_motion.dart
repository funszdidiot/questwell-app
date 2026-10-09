/// Presentation-only timing. This never changes inventory or gameplay state.
abstract final class QuestwellPetMotion {
  static const names = <String, String>{
    'boston-terrier': 'Boston Terrier',
    'hearth-cat': 'Hearth Cat',
  };

  // (sheet frame, hold in milliseconds). Rest holds keep these companions calm.
  static const _dog = <(int, int)>[
    (0, 3000),
    (1, 150),
    (0, 700),
    (2, 120),
    (0, 2400),
    (4, 500),
    (0, 600),
    (5, 500),
    (0, 500),
    (6, 180),
    (0, 350),
    (6, 180),
    (0, 820),
  ];
  static const _cat = <(int, int)>[
    (0, 3300),
    (1, 180),
    (2, 220),
    (1, 180),
    (0, 1500),
    (4, 300),
    (5, 350),
    (4, 300),
    (0, 1000),
    (6, 300),
    (7, 200),
    (6, 300),
    (7, 200),
    (0, 1670),
  ];

  static List<(int, int)> _sequence(String slug) => switch (slug) {
    'boston-terrier' => _dog,
    'hearth-cat' => _cat,
    _ => throw ArgumentError.value(slug, 'slug', 'Unknown pet'),
  };

  static Duration duration(String slug) => Duration(
    milliseconds: _sequence(slug).fold(0, (total, step) => total + step.$2),
  );

  static int frame(String slug, double phase) {
    if (!phase.isFinite || phase < 0 || phase > 1) {
      throw ArgumentError.value(
        phase,
        'phase',
        'Expected a finite value in 0..1',
      );
    }
    var elapsed = (phase * duration(slug).inMilliseconds).floor();
    for (final step in _sequence(slug)) {
      if (elapsed < step.$2) return step.$1;
      elapsed -= step.$2;
    }
    return 0;
  }

  static String asset(String slug) {
    _sequence(slug); // Reject typos rather than resolve a nonexistent asset.
    return 'assets/images/questwell_familiar_${slug}_idle_v1.webp';
  }
}
