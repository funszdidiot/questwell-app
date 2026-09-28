import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestwellPixelPalette {
  const QuestwellPixelPalette._();

  static List<Color> forClass(String archetype) {
    switch (archetype) {
      case 'scholar':
        return const [Color(0xFF2D1B69), Color(0xFF6B4BB8), Color(0xFFF0C96A)];
      case 'scout':
        return const [Color(0xFF173B2B), Color(0xFF477A4C), Color(0xFFD6A84B)];
      case 'alchemist':
        return const [Color(0xFF0C4A4F), Color(0xFF2F9B8F), Color(0xFFB7E86A)];
      case 'guardian':
        return const [Color(0xFF5C1D1D), Color(0xFFA84432), Color(0xFFF1B24A)];
      default:
        return const [Color(0xFF1A2E5A), Color(0xFF3D5A9A), Color(0xFFF1C75B)];
    }
  }
}

class QuestwellPixelDivider extends StatelessWidget {
  const QuestwellPixelDivider({
    super.key,
    this.accent = const Color(0xFF8E6B35),
  });

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        children: [
          Container(width: 8, height: 8, color: const Color(0xFFF1C75B)),
          Expanded(
            child: Container(height: 2, color: accent),
          ),
          Container(width: 8, height: 8, color: const Color(0xFFF1C75B)),
        ],
      ),
    );
  }
}

class QuestwellTopActionButton extends StatelessWidget {
  const QuestwellTopActionButton({
    super.key,
    required this.kind,
    required this.tooltip,
    required this.onTap,
  });

  final String kind;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF15141B),
            border: Border.all(
              color: const Color(0xFFD6A84B),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x77000000),
                blurRadius: 0,
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: Center(
            child: QuestwellNavPixelIcon(
              kind: kind,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class QuestwellScreenHeader extends StatelessWidget {
  const QuestwellScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.onBack,
    this.accent = const Color(0xFFD6A84B),
  });

  final String title;
  final String subtitle;
  final String kind;
  final VoidCallback onBack;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;
    return Column(
      children: [
        Row(
          children: [
            QuestwellTopActionButton(
              kind: 'back',
              tooltip: 'Back to the Hearth',
              onTap: onBack,
            ),
            SizedBox(width: compact ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.pressStart2p(
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 15 : 21,
                      color: const Color(0xFFF2D9A0),
                      letterSpacing: compact ? .2 : .5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 12 : 14,
                      height: 1.25,
                      color: const Color(0xFFB7C4D4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 7 : 10),
            QuestwellNavPixelIcon(
              kind: kind,
              size: compact ? 30 : 36,
            ),
          ],
        ),
        const SizedBox(height: 12),
        QuestwellPixelDivider(accent: accent),
      ],
    );
  }
}

class QuestwellRetroMenuButton extends StatelessWidget {
  const QuestwellRetroMenuButton({
    super.key,
    required this.label,
    required this.kind,
    required this.onTap,
    this.accent = const Color(0xFF8E6B35),
    this.compact = false,
  });

  final String label;
  final String kind;
  final VoidCallback? onTap;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: compact ? 44 : 50,
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFF15141B)
                : const Color(0xFF26262B),
            border: Border.all(
              color: enabled ? accent : const Color(0xFF55565C),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x77000000),
                blurRadius: 0,
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuestwellNavPixelIcon(
                kind: kind,
                size: compact ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled
                        ? const Color(0xFFF2E7CE)
                        : const Color(0xFF77787E),
                    fontSize: compact ? 9 : 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestwellPixelToggle extends StatelessWidget {
  const QuestwellPixelToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Container(
          width: 58,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0C11),
            border: Border.all(
              color: value
                  ? const Color(0xFFF1C75B)
                  : const Color(0xFF5A5B62),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              if (value) const Spacer(),
              Container(
                width: 22,
                height: 20,
                decoration: BoxDecoration(
                  color: enabled
                      ? (value
                          ? const Color(0xFFE87947)
                          : const Color(0xFFB9B9B9))
                      : const Color(0xFF595A60),
                  border: Border.all(
                    color: const Color(0xFFF2E7CE),
                    width: 2,
                  ),
                ),
              ),
              if (!value) const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestwellRetroPanel extends StatelessWidget {
  const QuestwellRetroPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent = const Color(0xFF8E6B35),
    this.background = const Color(0xFF15141B),
  });

  final Widget child;
  final EdgeInsets padding;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 0,
            offset: Offset(6, 6),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _RetroBorderPainter(accent: accent),
        child: Container(
          padding: padding.add(const EdgeInsets.all(8)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(background, const Color(0xFF24344A), .20)!,
                background,
                Color.lerp(background, const Color(0xFF05080D), .34)!,
              ],
              stops: const [0, .48, 1],
            ),
          ),
          child: CustomPaint(
            painter: _QuestwellPanelAtmospherePainter(accent: accent),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _QuestwellPanelAtmospherePainter extends CustomPainter {
  const _QuestwellPanelAtmospherePainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;

    // Very restrained 64-bit-era environmental texture: stepped corner light,
    // low-contrast masonry marks, and a warm accent glow. This keeps text
    // readable while making panels feel like pieces of the same game world.
    for (var i = 0; i < 4; i++) {
      final inset = i * 10.0;
      p.color = accent.withValues(alpha: .035 - (i * .006));
      canvas.drawRect(
        Rect.fromLTWH(inset, inset, size.width - inset * 2, 2),
        p,
      );
    }

    p.color = const Color(0x14FFFFFF);
    for (double y = 18; y < size.height; y += 34) {
      final stagger = ((y / 34).floor().isEven) ? 10.0 : 28.0;
      for (double x = stagger; x < size.width - 18; x += 58) {
        canvas.drawRect(Rect.fromLTWH(x, y, 16, 1), p);
        canvas.drawRect(Rect.fromLTWH(x + 4, y + 3, 8, 1), p);
      }
    }

    p.color = accent.withValues(alpha: .08);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .72, size.height * .08, size.width * .20, 2),
      p,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * .82, size.height * .08, 2, size.height * .16),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _QuestwellPanelAtmospherePainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _RetroBorderPainter extends CustomPainter {
  const _RetroBorderPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void r(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    // Outer and inner hard-edged RPG frame.
    r(0, 0, size.width, 3, accent);
    r(0, size.height - 3, size.width, 3, accent);
    r(0, 0, 3, size.height, accent);
    r(size.width - 3, 0, 3, size.height, accent);

    const inner = Color(0xFF5B4227);
    r(6, 6, size.width - 12, 2, inner);
    r(6, size.height - 8, size.width - 12, 2, inner);
    r(6, 6, 2, size.height - 12, inner);
    r(size.width - 8, 6, 2, size.height - 12, inner);

    const gold = Color(0xFFF1C75B);
    const darkGold = Color(0xFF8E6B35);
    for (final o in [
      const Offset(2, 2),
      Offset(size.width - 15, 2),
      Offset(2, size.height - 15),
      Offset(size.width - 15, size.height - 15),
    ]) {
      r(o.dx, o.dy, 13, 13, gold);
      r(o.dx + 4, o.dy + 4, 5, 5, darkGold);
    }

    if (size.width > 60) {
      r(24, 2, size.width - 48, 2, const Color(0xFF6A4C2C));
      r(24, size.height - 4, size.width - 48, 2, const Color(0xFF6A4C2C));
    }
  }

  @override
  bool shouldRepaint(covariant _RetroBorderPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class QuestwellPixelFrame extends StatelessWidget {
  const QuestwellPixelFrame({
    super.key,
    required this.child,
    this.height = 180,
    this.background = const Color(0xFF15141B),
  });

  final Widget child;
  final double height;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: const Color(0xFF8E6B35), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 0, offset: Offset(4, 4)),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: child),
          const _PixelCorner(alignment: Alignment.topLeft),
          const _PixelCorner(alignment: Alignment.topRight),
          const _PixelCorner(alignment: Alignment.bottomLeft),
          const _PixelCorner(alignment: Alignment.bottomRight),
        ],
      ),
    );
  }
}

class _PixelCorner extends StatelessWidget {
  const _PixelCorner({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 10,
        height: 10,
        color: const Color(0xFFF1C75B),
      ),
    );
  }
}

class QuestwellHearthPixelScene extends StatelessWidget {
  const QuestwellHearthPixelScene({
    super.key,
    this.height = 170,
    this.archetype = 'wanderer',
    this.equippedSlugs = const {},
    this.showRelic = false,
  });

  final double height;
  final String archetype;
  final Map<String, String> equippedSlugs;
  final bool showRelic;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      child: CustomPaint(
        painter: _HearthPainter(
          archetype: archetype,
          palette: QuestwellPixelPalette.forClass(archetype),
          equippedSlugs: equippedSlugs,
          showRelic: showRelic,
        ),
      ),
    );
  }
}

class QuestwellParchmentPanel extends StatelessWidget {
  const QuestwellParchmentPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.selected = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E2BD),
        border: Border.all(
          color: selected
              ? const Color(0xFFF1C75B)
              : const Color(0xFF9A7B50),
          width: selected ? 3 : 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55322018),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class QuestwellPixelMeter extends StatelessWidget {
  const QuestwellPixelMeter({
    super.key,
    required this.value,
    this.height = 18,
    this.segments = 12,
    this.kind = 'xp',
  });

  final double value;
  final double height;
  final int segments;
  final String kind;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final active = (clamped * segments).round();
    final activeColor = kind == 'hp'
        ? const Color(0xFFE87947)
        : kind == 'coin'
            ? const Color(0xFFF1C75B)
            : const Color(0xFF8D65D6);

    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF111419),
        border: Border.all(color: const Color(0xFF8E6B35), width: 2),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments; i++) ...[
            Expanded(
              child: Container(
                color: i < active
                    ? activeColor
                    : const Color(0xFF2B2A31),
              ),
            ),
            if (i != segments - 1) const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}

class QuestwellNavPixelIcon extends StatelessWidget {
  const QuestwellNavPixelIcon({
    super.key,
    required this.kind,
    this.size = 20,
  });

  final String kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _NavIconPainter(kind: kind),
      ),
    );
  }
}

class QuestwellCurrencyPixelIcon extends StatelessWidget {
  const QuestwellCurrencyPixelIcon({
    super.key,
    required this.kind,
    this.size = 18,
  });

  final String kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _CurrencyPainter(kind: kind),
      ),
    );
  }
}

class QuestwellRarityPixelBadge extends StatelessWidget {
  const QuestwellRarityPixelBadge({
    super.key,
    required this.rarity,
    this.compact = false,
  });

  final String rarity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = rarity.toLowerCase();
    final color = switch (normalized) {
      'uncommon' => const Color(0xFF4F9C65),
      'rare' => const Color(0xFF4E78C8),
      'epic' => const Color(0xFF8A55C8),
      'legendary' => const Color(0xFFD99B35),
      _ => const Color(0xFF7A7F87),
    };

    final label = rarity.isEmpty
        ? 'Common'
        : '${rarity[0].toUpperCase()}${rarity.substring(1)}';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF17151A),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .22),
            blurRadius: 0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 7 : 8,
            height: compact ? 7 : 8,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

class QuestwellStatusPixelBadge extends StatelessWidget {
  const QuestwellStatusPixelBadge({
    super.key,
    required this.kind,
    this.size = 44,
    this.active = true,
  });

  final String kind;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StatusBadgePainter(kind: kind, active: active),
      ),
    );
  }
}

class QuestwellQuestBoardPixelArt extends StatelessWidget {
  const QuestwellQuestBoardPixelArt({
    super.key,
    this.height = 105,
    this.clear = false,
  });

  final double height;
  final bool clear;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF17151A),
      child: CustomPaint(
        painter: _QuestBoardPainter(clear: clear),
      ),
    );
  }
}

class QuestwellFrictionPixelBadge extends StatelessWidget {
  const QuestwellFrictionPixelBadge({
    super.key,
    required this.level,
    this.size = 42,
  });

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _FrictionPainter(level: level),
      ),
    );
  }
}

class QuestwellVictoryPixelArt extends StatelessWidget {
  const QuestwellVictoryPixelArt({
    super.key,
    this.height = 110,
    this.bossVictory = false,
  });

  final double height;
  final bool bossVictory;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF17151A),
      child: CustomPaint(
        painter: _VictoryPainter(bossVictory: bossVictory),
      ),
    );
  }
}

class QuestwellChroniclePixelScene extends StatelessWidget {
  const QuestwellChroniclePixelScene({
    super.key,
    this.height = 135,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF17151A),
      child: CustomPaint(painter: _ChroniclePainter()),
    );
  }
}

class QuestwellExpeditionPixelScene extends StatelessWidget {
  const QuestwellExpeditionPixelScene({
    super.key,
    this.height = 150,
    this.campfire = false,
  });

  final double height;
  final bool campfire;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF101827),
      child: CustomPaint(
        painter: _ExpeditionPainter(campfire: campfire),
      ),
    );
  }
}

class QuestwellClassMiniSprite extends StatelessWidget {
  const QuestwellClassMiniSprite({
    super.key,
    required this.archetype,
    this.size = 58,
  });

  final String archetype;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: QuestwellPixelFrame(
        height: size,
        background: QuestwellPixelPalette.forClass(archetype).first,
        child: CustomPaint(
          painter: _ClassMiniPainter(
            archetype: archetype,
            palette: QuestwellPixelPalette.forClass(archetype),
          ),
        ),
      ),
    );
  }
}

class QuestwellClassPixelPortrait extends StatelessWidget {
  const QuestwellClassPixelPortrait({
    super.key,
    required this.archetype,
    this.height = 190,
    this.showRelic = false,
  });

  final String archetype;
  final double height;
  final bool showRelic;

  @override
  Widget build(BuildContext context) {
    final palette = QuestwellPixelPalette.forClass(archetype);
    return QuestwellPixelFrame(
      height: height,
      background: palette.first,
      child: CustomPaint(
        painter: _ClassPortraitPainter(
          archetype: archetype,
          palette: palette,
          showRelic: showRelic,
        ),
      ),
    );
  }
}

class QuestwellEquippedAvatar extends StatelessWidget {
  const QuestwellEquippedAvatar({
    super.key,
    required this.archetype,
    required this.equippedSlugs,
    this.height = 210,
    this.showRelic = false,
  });

  final String archetype;
  final Map<String, String> equippedSlugs;
  final double height;
  final bool showRelic;

  @override
  Widget build(BuildContext context) {
    final palette = QuestwellPixelPalette.forClass(archetype);
    return QuestwellPixelFrame(
      height: height,
      background: palette.first,
      child: CustomPaint(
        painter: _EquippedAvatarPainter(
          archetype: archetype,
          palette: palette,
          equippedSlugs: equippedSlugs,
          showRelic: showRelic,
          portrait: true,
        ),
      ),
    );
  }
}

class QuestwellEquippedAvatarSprite extends StatelessWidget {
  const QuestwellEquippedAvatarSprite({
    super.key,
    required this.archetype,
    required this.equippedSlugs,
    this.width = 116,
    this.height = 150,
  });

  final String archetype;
  final Map<String, String> equippedSlugs;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EquippedAvatarPainter(
          archetype: archetype,
          palette: QuestwellPixelPalette.forClass(archetype),
          equippedSlugs: equippedSlugs,
          showRelic: false,
          portrait: false,
        ),
      ),
    );
  }
}

class QuestwellRelicPixelArt extends StatelessWidget {
  const QuestwellRelicPixelArt({
    super.key,
    required this.archetype,
    this.size = 72,
  });

  final String archetype;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RelicPainter(
          archetype: archetype,
          palette: QuestwellPixelPalette.forClass(archetype),
        ),
      ),
    );
  }
}

class QuestwellItemPixelArt extends StatelessWidget {
  const QuestwellItemPixelArt({
    super.key,
    required this.slug,
    required this.category,
    this.archetype,
    this.size = 62,
    this.locked = false,
  });

  final String slug;
  final String category;
  final String? archetype;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final palette = QuestwellPixelPalette.forClass(archetype ?? 'wanderer');
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ItemPainter(
          slug: slug,
          category: category,
          palette: palette,
          locked: locked,
        ),
      ),
    );
  }
}

class QuestwellMarketPixelScene extends StatelessWidget {
  const QuestwellMarketPixelScene({
    super.key,
    required this.archetype,
    this.height = 150,
  });

  final String archetype;
  final double height;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF17151A),
      child: CustomPaint(
        painter: _MarketPainter(
          palette: QuestwellPixelPalette.forClass(archetype),
        ),
      ),
    );
  }
}

class QuestwellBossSigilPixelArt extends StatelessWidget {
  const QuestwellBossSigilPixelArt({
    super.key,
    required this.bossType,
    this.size = 50,
  });

  final String bossType;
  final double size;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: size,
      background: const Color(0xFF14131A),
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _BossSigilPainter(bossType)),
      ),
    );
  }
}

class QuestwellBossPixelArt extends StatelessWidget {
  const QuestwellBossPixelArt({
    super.key,
    required this.bossType,
    this.height = 130,
  });

  final String bossType;
  final double height;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF14131A),
      child: CustomPaint(painter: _BossPainter(bossType)),
    );
  }
}

class _Pixel64 {
  static void rect(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double w,
    double h,
    Color color,
  ) {
    paint.color = color;
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
  }

  static void stepGlow(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
    Color color,
  ) {
    for (var i = 3; i >= 1; i--) {
      final r = radius * i / 3;
      final alpha = i == 3 ? .10 : i == 2 ? .16 : .24;
      rect(
        canvas,
        paint,
        center.dx - r,
        center.dy - r,
        r * 2,
        r * 2,
        color.withValues(alpha: alpha),
      );
    }
  }

  static void dither(
    Canvas canvas,
    Paint paint,
    Rect area,
    Color color,
    double step,
  ) {
    for (double y = area.top; y < area.bottom; y += step) {
      for (double x = area.left; x < area.right; x += step) {
        if ((((x / step).floor() + (y / step).floor()) & 1) == 0) {
          rect(canvas, paint, x, y, step * .46, step * .46, color);
        }
      }
    }
  }

  static void bevel(
    Canvas canvas,
    Paint paint,
    Rect area,
    Color base,
    Color light,
    Color dark,
  ) {
    rect(canvas, paint, area.left, area.top, area.width, area.height, base);
    rect(canvas, paint, area.left, area.top, area.width, 4, light);
    rect(canvas, paint, area.left, area.top, 4, area.height, light);
    rect(canvas, paint, area.left, area.bottom - 4, area.width, 4, dark);
    rect(canvas, paint, area.right - 4, area.top, 4, area.height, dark);
  }

  static void character(
    Canvas canvas,
    Paint paint, {
    required Offset origin,
    required double scale,
    required List<Color> palette,
    required String archetype,
  }) {
    void r(double x, double y, double w, double h, Color color) =>
        rect(canvas, paint, origin.dx + x * scale, origin.dy + y * scale,
            w * scale, h * scale, color);

    final skin = const Color(0xFFD6A16D);
    final skinHi = const Color(0xFFEBC18E);
    final hair = const Color(0xFF2A211E);
    final boot = const Color(0xFF211B19);
    final outline = const Color(0xFF121116);

    // Shadow.
    r(-7, 28, 17, 4, const Color(0x66000000));

    // Legs and boots.
    r(-4, 16, 5, 11, palette.first);
    r(3, 16, 5, 11, palette.first);
    r(-5, 25, 6, 4, boot);
    r(3, 25, 7, 4, boot);

    // Torso with highlight/shadow.
    r(-7, 3, 16, 15, outline);
    r(-6, 4, 14, 13, palette[1]);
    r(-5, 5, 3, 11, palette.last.withValues(alpha: .82));
    r(5, 5, 2, 10, palette.first);

    // Arms.
    r(-10, 6, 4, 11, outline);
    r(-9, 7, 3, 9, palette[1]);
    r(8, 6, 4, 11, outline);
    r(8, 7, 3, 9, palette[1]);

    // Head.
    r(-5, -8, 12, 12, outline);
    r(-4, -7, 10, 10, skin);
    r(-3, -6, 7, 3, skinHi);
    r(-4, -9, 10, 4, hair);
    r(-3, -3, 2, 2, const Color(0xFF15141B));
    r(3, -3, 2, 2, const Color(0xFF15141B));

    switch (archetype) {
      case 'scholar':
        r(-8, -13, 16, 3, palette.last);
        r(-4, -18, 8, 6, palette[1]);
        r(9, 8, 7, 9, const Color(0xFF6A337C));
        r(11, 10, 4, 2, const Color(0xFFE5D6B7));
        break;
      case 'scout':
        r(-6, -12, 13, 4, const Color(0xFF355E3B));
        r(10, 2, 2, 20, palette.last);
        r(12, 5, 3, 3, const Color(0xFFD7C29D));
        break;
      case 'alchemist':
        r(-5, -5, 4, 2, const Color(0xFFB9E7F4));
        r(2, -5, 4, 2, const Color(0xFFB9E7F4));
        r(10, 8, 3, 7, const Color(0xFFB9E7F4));
        r(8, 14, 7, 5, const Color(0xFF79D85D));
        r(10, 15, 2, 2, const Color(0xFFE9FFD8));
        break;
      case 'guardian':
        r(-11, 3, 4, 15, const Color(0xFF7D2828));
        r(9, 5, 8, 12, const Color(0xFF9B4A32));
        r(11, 7, 4, 8, palette.last);
        break;
      default:
        r(-12, 5, 5, 11, const Color(0xFF6A5031));
        r(11, -1, 2, 25, palette.last);
        r(9, -4, 6, 3, palette.last);
    }
  }
}

class _HearthPainter extends CustomPainter {
  _HearthPainter({
    required this.archetype,
    required this.palette,
    required this.equippedSlugs,
    required this.showRelic,
  });
  final String archetype;
  final List<Color> palette;
  final Map<String, String> equippedSlugs;
  final bool showRelic;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void r(double x, double y, double w, double h, Color color) =>
        _Pixel64.rect(canvas, p, x, y, w, h, color);

    // Layered night wall with higher-color-depth dithering.
    r(0, 0, size.width, size.height, const Color(0xFF0D1523));
    r(0, 0, size.width, size.height * .58, const Color(0xFF15233A));
    _Pixel64.dither(
      canvas,
      p,
      Rect.fromLTWH(0, 0, size.width, size.height * .58),
      const Color(0xFF1B2E49),
      10,
    );

    // Structural beams, beveled like late-90s RPG tiles.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(0, size.height * .565, size.width, 9),
      const Color(0xFF6A4328),
      const Color(0xFF93613B),
      const Color(0xFF3A2418),
    );
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .405, 0, 10, size.height * .58),
      const Color(0xFF5A3724),
      const Color(0xFF825437),
      const Color(0xFF2A1913),
    );
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .785, 0, 10, size.height * .58),
      const Color(0xFF5A3724),
      const Color(0xFF825437),
      const Color(0xFF2A1913),
    );

    // Floor with perspective strips.
    r(0, size.height * .60, size.width, size.height * .40, const Color(0xFF3F281B));
    for (var i = 0; i < 9; i++) {
      final y = size.height * (.62 + i * .043);
      r(0, y, size.width, 2, i.isEven ? const Color(0xFF6F4830) : const Color(0xFF261812));
    }
    for (var i = 0; i < 14; i++) {
      final x = size.width * (i / 14);
      r(x, size.height * .60, 2, size.height * .40, const Color(0xFF2D1C15));
    }

    // Window: deep frame, rain, moon glow.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .67, size.height * .075, size.width * .27, size.height * .39),
      const Color(0xFF18243A),
      const Color(0xFF385B7B),
      const Color(0xFF09111E),
    );
    r(size.width * .69, size.height * .10, size.width * .23, size.height * .32, const Color(0xFF254E78));
    r(size.width * .80, size.height * .10, 5, size.height * .32, const Color(0xFF173451));
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .86, size.height * .18),
      24,
      const Color(0xFFFFE28C),
    );
    p.color = const Color(0xFFFFE28C);
    canvas.drawCircle(Offset(size.width * .86, size.height * .18), 10, p);
    for (var i = 0; i < 15; i++) {
      final x = size.width * (.70 + ((i * 17) % 20) / 100);
      final y = size.height * (.13 + ((i * 29) % 26) / 100);
      r(x, y, 2, 9, const Color(0xFF87C7E4));
      r(x + 2, y + 7, 2, 5, const Color(0xFF4D8EB2));
    }
    r(size.width * .66, size.height * .44, size.width * .29, 9, const Color(0xFF6A4328));
    r(size.width * .67, size.height * .44, size.width * .27, 3, const Color(0xFFA7794C));

    // Fireplace body with brick texture and depth.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .035, size.height * .17, size.width * .36, size.height * .66),
      const Color(0xFF65432F),
      const Color(0xFF916547),
      const Color(0xFF38231A),
    );
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 5; col++) {
        final x = size.width * (.05 + col * .065 + (row.isOdd ? .032 : 0));
        final y = size.height * (.20 + row * .092);
        r(
          x,
          y,
          size.width * .057,
          size.height * .070,
          (row + col).isEven
              ? const Color(0xFF81563B)
              : const Color(0xFF744B35),
        );
        r(x + 3, y + 3, size.width * .04, 3, const Color(0xFFA16F4B));
      }
    }
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .095, size.height * .36, size.width * .245, size.height * .31),
      const Color(0xFF1B1110),
      const Color(0xFF3A2018),
      const Color(0xFF080707),
    );
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .22, size.height * .55),
      34,
      const Color(0xFFF08A32),
    );
    r(size.width * .12, size.height * .61, size.width * .20, size.height * .055, const Color(0xFF733A20));
    r(size.width * .15, size.height * .53, size.width * .14, size.height * .11, const Color(0xFFF17828));
    r(size.width * .18, size.height * .45, size.width * .08, size.height * .18, const Color(0xFFF6B83F));
    r(size.width * .205, size.height * .40, size.width * .035, size.height * .20, const Color(0xFFFFE37C));
    r(size.width * .145, size.height * .49, 4, 4, const Color(0xFFFFC44E));
    r(size.width * .292, size.height * .46, 3, 3, const Color(0xFFFFE37C));

    // Bookcase with more color/shading.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .44, size.height * .15, size.width * .17, size.height * .48),
      const Color(0xFF4B2C1C),
      const Color(0xFF7A4D2D),
      const Color(0xFF241711),
    );
    final books = [
      const Color(0xFF8D3347),
      const Color(0xFF2E725F),
      const Color(0xFF4B73A8),
      const Color(0xFFB07B37),
      const Color(0xFF78528A),
      const Color(0xFFB75B42),
      const Color(0xFF3C8B8A),
      const Color(0xFF9A5F2F),
    ];
    for (var row = 0; row < 3; row++) {
      final sy = size.height * (.20 + row * .14);
      r(size.width * .455, sy + size.height * .09, size.width * .14, 4, const Color(0xFFB9854B));
      for (var book = 0; book < 7; book++) {
        final bx = size.width * (.46 + book * .019);
        final bh = size.height * (.055 + ((book + row) % 4) * .010);
        r(bx, sy + size.height * .025, size.width * .014, bh, books[(book + row * 2) % books.length]);
        r(bx + 1, sy + size.height * .028, 2, bh - 5, const Color(0x44FFFFFF));
      }
    }
    // Bottles and relic on the top shelf.
    r(size.width * .488, size.height * .105, 5, 10, const Color(0xFF8F5C34));
    r(size.width * .482, size.height * .135, 16, 18, const Color(0xFF3DA69A));
    r(size.width * .505, size.height * .112, 5, 8, const Color(0xFF8F5C34));
    r(size.width * .501, size.height * .137, 13, 15, const Color(0xFF8B58C3));
    r(size.width * .545, size.height * .12, 16, 8, palette.last);

    // Perspective rug with patterned center.
    final rug = Rect.fromLTWH(size.width * .42, size.height * .73, size.width * .32, size.height * .16);
    _Pixel64.bevel(
      canvas,
      p,
      rug,
      const Color(0xFF23544E),
      const Color(0xFF3B786D),
      const Color(0xFF102B28),
    );
    r(size.width * .45, size.height * .755, size.width * .26, size.height * .11, const Color(0xFF2D665D));
    for (var i = 0; i < 7; i++) {
      final x = size.width * (.46 + i * .035);
      r(x, size.height * .77, 4, 4, const Color(0xFFE1B75A));
      r(x, size.height * .845, 4, 4, const Color(0xFFE1B75A));
    }
    r(size.width * .555, size.height * .787, 7, 7, const Color(0xFFE1B75A));
    r(size.width * .555, size.height * .817, 7, 7, const Color(0xFFE1B75A));
    r(size.width * .54, size.height * .802, 7, 7, const Color(0xFFE1B75A));
    r(size.width * .57, size.height * .802, 7, 7, const Color(0xFFE1B75A));

    // Live Adventurer is rendered inside the same scene painter so it belongs
    // to the room instead of looking pasted over a generated background.
    final avatarSize = Size(size.width * .235, size.height * .50);
    canvas.save();
    canvas.translate(
      size.width * .405,
      size.height * .315,
    );
    _EquippedAvatarPainter(
      archetype: archetype,
      palette: palette,
      equippedSlugs: equippedSlugs,
      showRelic: showRelic,
      portrait: false,
    ).paint(canvas, avatarSize);
    canvas.restore();

    // Cat with visible ears, tail, body shading.
    r(size.width * .54, size.height * .80, 34, 9, const Color(0xFF9E5C30));
    r(size.width * .57, size.height * .775, 16, 17, const Color(0xFFC87B3E));
    r(size.width * .575, size.height * .755, 5, 8, const Color(0xFFC87B3E));
    r(size.width * .589, size.height * .755, 5, 8, const Color(0xFFC87B3E));
    r(size.width * .598, size.height * .786, 14, 4, const Color(0xFF8E542D));
    r(size.width * .605, size.height * .778, 4, 4, const Color(0xFFF5DB82));

    // Class banner and trophy shelf.
    r(size.width * .815, size.height * .49, size.width * .12, 7, const Color(0xFF6A4328));
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .84, size.height * .30, size.width * .07, size.height * .17),
      palette[1],
      palette.last,
      palette.first,
    );
    r(size.width * .862, size.height * .345, 8, 8, palette.last);
    r(size.width * .455, size.height * .665, size.width * .14, 5, const Color(0xFF8E6B35));
    p.color = const Color(0xFFF1C75B);
    canvas.drawCircle(Offset(size.width * .48, size.height * .645), 5, p);
    canvas.drawCircle(Offset(size.width * .565, size.height * .645), 5, p);

    // Foreground desk, chair, and trophy clutter to create more 64-bit-era depth.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .72, size.height * .68, size.width * .23, size.height * .11),
      const Color(0xFF5B3825),
      const Color(0xFF8A5A38),
      const Color(0xFF281913),
    );
    r(size.width * .75, size.height * .71, size.width * .045, size.height * .05, const Color(0xFFD8C7A3));
    r(size.width * .805, size.height * .705, size.width * .032, size.height * .055, const Color(0xFF3D8F86));
    r(size.width * .848, size.height * .70, size.width * .06, size.height * .06, const Color(0xFF6A337C));
    r(size.width * .86, size.height * .685, size.width * .035, size.height * .018, const Color(0xFFE7C96A));

    // Layered foreground shadowing and warm bounce light.
    r(0, size.height * .91, size.width, size.height * .09, const Color(0x66201018));
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .30, size.height * .72),
      size.height * .16,
      const Color(0xFFE57A2A),
    );
    _Pixel64.dither(
      canvas,
      p,
      Rect.fromLTWH(size.width * .02, size.height * .62, size.width * .36, size.height * .25),
      const Color(0x337E4B2D),
      7,
    );

    // Fine highlight pixels on wood and props to reduce flat 16-bit appearance.
    for (var i = 0; i < 24; i++) {
      final x = size.width * (.04 + ((i * 37) % 92) / 100);
      final y = size.height * (.61 + ((i * 19) % 28) / 100);
      r(x, y, 2, 2, i.isEven ? const Color(0xFF8A5B3A) : const Color(0xFFB07A4B));
    }

    // Lantern pools.
    for (final x in [size.width * .42, size.width * .61, size.width * .95]) {
      _Pixel64.stepGlow(
        canvas,
        p,
        Offset(x, size.height * .19),
        20,
        const Color(0xFFFFC95C),
      );
      r(x, size.height * .06, 4, 20, const Color(0xFF6C442C));
      r(x - 7, size.height * .14, 18, 23, const Color(0xFFB77A2D));
      r(x - 4, size.height * .16, 12, 14, const Color(0xFFFFE39A));
    }
  }

  @override
  bool shouldRepaint(covariant _HearthPainter oldDelegate) =>
      oldDelegate.archetype != archetype ||
      oldDelegate.palette != palette ||
      oldDelegate.equippedSlugs != equippedSlugs ||
      oldDelegate.showRelic != showRelic;
}

class _NavIconPainter extends CustomPainter {
  _NavIconPainter({required this.kind});
  final String kind;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    final gold = const Color(0xFFF1C75B);
    final violet = const Color(0xFF7654D8);
    final teal = const Color(0xFF4AA89A);
    final ember = const Color(0xFFE87947);
    final paper = const Color(0xFFD8C7A3);

    switch (kind) {
      case 'expedition':
        final mountain = Path()
          ..moveTo(size.width * .08, size.height * .78)
          ..lineTo(size.width * .38, size.height * .26)
          ..lineTo(size.width * .56, size.height * .56)
          ..lineTo(size.width * .72, size.height * .32)
          ..lineTo(size.width * .94, size.height * .78)
          ..close();
        p.color = teal;
        canvas.drawPath(mountain, p);
        rect(size.width * .43, size.height * .53, size.width * .08, size.height * .36, gold);
        break;
      case 'boss':
        rect(size.width * .18, size.height * .28, size.width * .64, size.height * .44, ember);
        rect(size.width * .28, size.height * .20, size.width * .12, size.height * .14, ember);
        rect(size.width * .60, size.height * .20, size.width * .12, size.height * .14, ember);
        rect(size.width * .32, size.height * .42, 4, 4, paper);
        rect(size.width * .62, size.height * .42, 4, 4, paper);
        break;
      case 'chronicle':
        rect(size.width * .18, size.height * .16, size.width * .64, size.height * .68, violet);
        rect(size.width * .27, size.height * .22, size.width * .08, size.height * .56, gold);
        rect(size.width * .42, size.height * .33, size.width * .30, 4, paper);
        rect(size.width * .42, size.height * .48, size.width * .24, 4, paper);
        rect(size.width * .42, size.height * .63, size.width * .28, 4, paper);
        break;
      case 'adventurer':
        p.color = const Color(0xFFD9A56E);
        canvas.drawCircle(Offset(size.width * .50, size.height * .32), size.width * .16, p);
        rect(size.width * .30, size.height * .48, size.width * .40, size.height * .36, teal);
        rect(size.width * .22, size.height * .52, size.width * .10, size.height * .25, teal);
        rect(size.width * .68, size.height * .52, size.width * .10, size.height * .25, teal);
        break;
      case 'market':
        for (var i = 0; i < 4; i++) {
          rect(
            size.width * (.12 + i * .19),
            size.height * .15,
            size.width * .18,
            size.height * .18,
            i.isEven ? ember : paper,
          );
        }
        rect(size.width * .14, size.height * .34, size.width * .72, size.height * .48, const Color(0xFF7B4F2B));
        rect(size.width * .28, size.height * .47, size.width * .18, size.height * .20, gold);
        rect(size.width * .56, size.height * .47, size.width * .18, size.height * .20, teal);
        break;
      default:
        rect(size.width * .46, size.height * .10, size.width * .08, size.height * .80, gold);
        rect(size.width * .10, size.height * .46, size.width * .80, size.height * .08, gold);
    }
  }

  @override
  bool shouldRepaint(covariant _NavIconPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

class _CurrencyPainter extends CustomPainter {
  _CurrencyPainter({required this.kind});
  final String kind;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    if (kind == 'coin') {
      p.color = const Color(0xFFF1C75B);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.shortestSide * .42,
        p,
      );
      p.color = const Color(0xFF8D6424);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.shortestSide * .25,
        p,
      );
      rect(size.width * .46, size.height * .25, size.width * .08, size.height * .50, const Color(0xFFF7DB7D));
    } else {
      final crystal = Path()
        ..moveTo(size.width * .50, size.height * .04)
        ..lineTo(size.width * .90, size.height * .42)
        ..lineTo(size.width * .62, size.height * .94)
        ..lineTo(size.width * .38, size.height * .94)
        ..lineTo(size.width * .10, size.height * .42)
        ..close();
      p.color = const Color(0xFF8D65D6);
      canvas.drawPath(crystal, p);
      final shine = Path()
        ..moveTo(size.width * .50, size.height * .14)
        ..lineTo(size.width * .60, size.height * .44)
        ..lineTo(size.width * .50, size.height * .73)
        ..lineTo(size.width * .43, size.height * .42)
        ..close();
      p.color = const Color(0xFFDCC9FF);
      canvas.drawPath(shine, p);
    }
  }

  @override
  bool shouldRepaint(covariant _CurrencyPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

class _StatusBadgePainter extends CustomPainter {
  _StatusBadgePainter({required this.kind, required this.active});
  final String kind;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF111419));
    final gold = active ? const Color(0xFFF1C75B) : const Color(0xFF7A7D84);
    final violet = active ? const Color(0xFF7654D8) : const Color(0xFF50535A);
    final ember = active ? const Color(0xFFE87947) : const Color(0xFF66686D);

    if (kind == 'momentum') {
      // Rising stair + spark.
      rect(size.width * .18, size.height * .63, size.width * .15, size.height * .16, violet);
      rect(size.width * .36, size.height * .49, size.width * .15, size.height * .30, violet);
      rect(size.width * .54, size.height * .33, size.width * .15, size.height * .46, violet);
      rect(size.width * .72, size.height * .20, size.width * .09, size.height * .59, violet);
      rect(size.width * .68, size.height * .12, 4, 9, gold);
      rect(size.width * .57, size.height * .20, 9, 4, gold);
      rect(size.width * .77, size.height * .20, 9, 4, gold);
    } else if (kind == 'campfire') {
      // Logs + layered pixel flame.
      rect(size.width * .20, size.height * .68, size.width * .60, size.height * .10, const Color(0xFF7A4A2E));
      rect(size.width * .29, size.height * .58, size.width * .42, size.height * .12, const Color(0xFF9B6236));
      rect(size.width * .34, size.height * .34, size.width * .32, size.height * .34, ember);
      rect(size.width * .42, size.height * .20, size.width * .18, size.height * .42, gold);
      rect(size.width * .47, size.height * .32, size.width * .09, size.height * .28, const Color(0xFFFFE39A));
    } else {
      // Generic quest star.
      rect(size.width * .46, size.height * .14, size.width * .08, size.height * .72, gold);
      rect(size.width * .14, size.height * .46, size.width * .72, size.height * .08, gold);
      rect(size.width * .28, size.height * .28, size.width * .44, size.height * .44, violet);
    }

    // Pixel border.
    rect(0, 0, size.width, 2, const Color(0xFF8E6B35));
    rect(0, size.height - 2, size.width, 2, const Color(0xFF8E6B35));
    rect(0, 0, 2, size.height, const Color(0xFF8E6B35));
    rect(size.width - 2, 0, 2, size.height, const Color(0xFF8E6B35));
  }

  @override
  bool shouldRepaint(covariant _StatusBadgePainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.active != active;
}

class _QuestBoardPainter extends CustomPainter {
  _QuestBoardPainter({required this.clear});
  final bool clear;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF17151A));

    // Wooden notice board.
    rect(size.width * .10, size.height * .16, size.width * .80, size.height * .66, const Color(0xFF6A4328));
    rect(size.width * .13, size.height * .20, size.width * .74, size.height * .58, const Color(0xFF8A5A35));

    if (clear) {
      // One waiting parchment and a tiny hopeful sparkle.
      rect(size.width * .34, size.height * .31, size.width * .32, size.height * .34, const Color(0xFFD8C7A3));
      rect(size.width * .39, size.height * .40, size.width * .22, 4, const Color(0xFF9A7B50));
      rect(size.width * .39, size.height * .49, size.width * .16, 4, const Color(0xFF9A7B50));
      p.color = const Color(0xFFF1C75B);
      canvas.drawCircle(Offset(size.width * .74, size.height * .30), 5, p);
      rect(size.width * .735, size.height * .19, 4, 10, const Color(0xFFF1C75B));
      rect(size.width * .735, size.height * .38, 4, 10, const Color(0xFFF1C75B));
      rect(size.width * .68, size.height * .285, 10, 4, const Color(0xFFF1C75B));
      rect(size.width * .79, size.height * .285, 10, 4, const Color(0xFFF1C75B));
    } else {
      final papers = [
        const Color(0xFFD8C7A3),
        const Color(0xFFC8B78F),
        const Color(0xFFE3D7B9),
      ];
      for (var i = 0; i < 3; i++) {
        final x = size.width * (.19 + i * .22);
        final y = size.height * (.27 + (i % 2) * .09);
        rect(x, y, size.width * .18, size.height * .30, papers[i]);
        rect(x + size.width * .03, y + size.height * .09, size.width * .12, 4, const Color(0xFF9A7B50));
        rect(x + size.width * .03, y + size.height * .17, size.width * .09, 4, const Color(0xFF9A7B50));
        p.color = const Color(0xFFB74A3A);
        canvas.drawCircle(Offset(x + size.width * .09, y - 2), 4, p);
      }
    }

    // Bottom hooks / tiny lanterns.
    rect(size.width * .19, size.height * .82, 4, size.height * .12, const Color(0xFF8E6B35));
    rect(size.width * .79, size.height * .82, 4, size.height * .12, const Color(0xFF8E6B35));
    rect(size.width * .15, size.height * .89, size.width * .10, size.height * .07, const Color(0xFFF1B64B));
    rect(size.width * .75, size.height * .89, size.width * .10, size.height * .07, const Color(0xFFF1B64B));
  }

  @override
  bool shouldRepaint(covariant _QuestBoardPainter oldDelegate) =>
      oldDelegate.clear != clear;
}

class _FrictionPainter extends CustomPainter {
  _FrictionPainter({required this.level});
  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    final colors = <int, Color>{
      1: const Color(0xFF4C8B5B),
      2: const Color(0xFFB58A3A),
      3: const Color(0xFFB65C3B),
      4: const Color(0xFF7D3E85),
    };
    final color = colors[level] ?? const Color(0xFF5B6575);

    p.color = const Color(0xFF17151A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), p);
    p.color = color;
    canvas.drawRect(Rect.fromLTWH(3, 3, size.width - 6, size.height - 6), p);

    final center = Offset(size.width / 2, size.height / 2);
    p.color = const Color(0xFFFFE5A0);

    switch (level) {
      case 1:
        canvas.drawCircle(center, size.width * .16, p);
        break;
      case 2:
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: size.width * .34,
            height: size.height * .12,
          ),
          p,
        );
        break;
      case 3:
        final tri = Path()
          ..moveTo(center.dx, size.height * .22)
          ..lineTo(size.width * .75, size.height * .72)
          ..lineTo(size.width * .25, size.height * .72)
          ..close();
        canvas.drawPath(tri, p);
        p.color = const Color(0xFF17151A);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(center.dx, size.height * .54),
            width: 4,
            height: size.height * .18,
          ),
          p,
        );
        break;
      default:
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final start = Offset(
            center.dx + math.cos(a) * size.width * .10,
            center.dy + math.sin(a) * size.height * .10,
          );
          final end = Offset(
            center.dx + math.cos(a) * size.width * .28,
            center.dy + math.sin(a) * size.height * .28,
          );
          p.strokeWidth = 4;
          canvas.drawLine(start, end, p);
        }
        canvas.drawCircle(center, size.width * .11, p);
    }
  }

  @override
  bool shouldRepaint(covariant _FrictionPainter oldDelegate) =>
      oldDelegate.level != level;
}

class _VictoryPainter extends CustomPainter {
  _VictoryPainter({required this.bossVictory});
  final bool bossVictory;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF17151A));

    // Radiating reward particles.
    final sparkColors = [
      const Color(0xFFF1C75B),
      const Color(0xFFB98CFF),
      const Color(0xFF6DD9C2),
      const Color(0xFFE87947),
    ];
    for (var i = 0; i < 22; i++) {
      final x = ((i * 47) % 97) / 97 * size.width;
      final y = ((i * 31) % 83) / 83 * size.height;
      final s = i % 3 == 0 ? 5.0 : 3.0;
      rect(x, y, s, s, sparkColors[i % sparkColors.length]);
    }

    // Coin.
    p.color = const Color(0xFFF1C75B);
    canvas.drawCircle(
      Offset(size.width * .27, size.height * .53),
      size.height * .21,
      p,
    );
    p.color = const Color(0xFF8D6424);
    canvas.drawCircle(
      Offset(size.width * .27, size.height * .53),
      size.height * .12,
      p,
    );
    rect(size.width * .255, size.height * .43, size.width * .03, size.height * .20, const Color(0xFFF1C75B));

    // XP crystal / defeated boss crest.
    if (bossVictory) {
      final shield = Path()
        ..moveTo(size.width * .68, size.height * .27)
        ..lineTo(size.width * .80, size.height * .36)
        ..lineTo(size.width * .77, size.height * .66)
        ..lineTo(size.width * .68, size.height * .78)
        ..lineTo(size.width * .59, size.height * .66)
        ..lineTo(size.width * .56, size.height * .36)
        ..close();
      p.color = const Color(0xFFB64735);
      canvas.drawPath(shield, p);
      rect(size.width * .655, size.height * .42, size.width * .05, size.height * .20, const Color(0xFFF1C75B));
      rect(size.width * .61, size.height * .49, size.width * .14, size.height * .05, const Color(0xFFF1C75B));
    } else {
      final crystal = Path()
        ..moveTo(size.width * .68, size.height * .24)
        ..lineTo(size.width * .78, size.height * .48)
        ..lineTo(size.width * .68, size.height * .77)
        ..lineTo(size.width * .58, size.height * .48)
        ..close();
      p.color = const Color(0xFF8D65D6);
      canvas.drawPath(crystal, p);
      rect(size.width * .665, size.height * .32, size.width * .03, size.height * .32, const Color(0xFFDCC9FF));
    }
  }

  @override
  bool shouldRepaint(covariant _VictoryPainter oldDelegate) =>
      oldDelegate.bossVictory != bossVictory;
}

class _ChroniclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF17151A));
    rect(0, size.height * .72, size.width, size.height * .28, const Color(0xFF4B2E1F));

    // Shelves.
    rect(size.width * .05, size.height * .30, size.width * .90, 7, const Color(0xFF8E6B35));
    rect(size.width * .05, size.height * .66, size.width * .90, 7, const Color(0xFF8E6B35));

    // Chronicle books.
    final bookColors = [
      const Color(0xFF5E2E5F),
      const Color(0xFF2E5F4B),
      const Color(0xFF35527A),
      const Color(0xFF7A4A2E),
      const Color(0xFF6B3B2E),
    ];
    for (var i = 0; i < 10; i++) {
      final x = size.width * (.09 + i * .075);
      final h = size.height * (.18 + (i % 3) * .035);
      rect(x, size.height * .30 - h, size.width * .045, h, bookColors[i % bookColors.length]);
      rect(x + 3, size.height * .30 - h + 5, size.width * .028, 3, const Color(0xFFD8B464));
    }

    // Trophy / boss skull.
    rect(size.width * .70, size.height * .40, size.width * .12, size.height * .16, const Color(0xFFD8C7A3));
    rect(size.width * .72, size.height * .54, size.width * .08, size.height * .08, const Color(0xFF8E6B35));
    rect(size.width * .725, size.height * .44, 5, 5, const Color(0xFF17151A));
    rect(size.width * .77, size.height * .44, 5, 5, const Color(0xFF17151A));

    // Coins and XP spark.
    p.color = const Color(0xFFF1C75B);
    canvas.drawCircle(Offset(size.width * .18, size.height * .53), size.height * .08, p);
    canvas.drawCircle(Offset(size.width * .25, size.height * .56), size.height * .06, p);
    for (var i = 0; i < 7; i++) {
      final a = i * math.pi * 2 / 7;
      rect(
        size.width * .49 + math.cos(a) * 24,
        size.height * .50 + math.sin(a) * 22,
        4,
        4,
        const Color(0xFFB98CFF),
      );
    }
    rect(size.width * .485, size.height * .45, 10, 28, const Color(0xFF7B4BC0));
    rect(size.width * .46, size.height * .49, 30, 8, const Color(0xFF7B4BC0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExpeditionPainter extends CustomPainter {
  _ExpeditionPainter({required this.campfire});
  final bool campfire;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF101827));
    rect(0, size.height * .68, size.width, size.height * .32, const Color(0xFF203A2D));

    // Moon / sun.
    p.color = campfire ? const Color(0xFFE7D67A) : const Color(0xFFF4CB67);
    canvas.drawCircle(
      Offset(size.width * .80, size.height * .23),
      size.height * .11,
      p,
    );

    // Mountain silhouettes.
    final back = Path()
      ..moveTo(0, size.height * .70)
      ..lineTo(size.width * .18, size.height * .36)
      ..lineTo(size.width * .33, size.height * .67)
      ..lineTo(size.width * .50, size.height * .25)
      ..lineTo(size.width * .70, size.height * .68)
      ..lineTo(size.width, size.height * .42)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    p.color = const Color(0xFF31506A);
    canvas.drawPath(back, p);

    final front = Path()
      ..moveTo(0, size.height * .82)
      ..lineTo(size.width * .24, size.height * .58)
      ..lineTo(size.width * .42, size.height * .80)
      ..lineTo(size.width * .61, size.height * .52)
      ..lineTo(size.width * .80, size.height * .82)
      ..lineTo(size.width, size.height * .60)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    p.color = const Color(0xFF17362A);
    canvas.drawPath(front, p);

    // Trail.
    final trail = Path()
      ..moveTo(size.width * .38, size.height)
      ..quadraticBezierTo(
        size.width * .48,
        size.height * .79,
        size.width * .56,
        size.height * .68,
      )
      ..quadraticBezierTo(
        size.width * .62,
        size.height * .60,
        size.width * .66,
        size.height * .52,
      )
      ..lineTo(size.width * .70, size.height * .55)
      ..quadraticBezierTo(
        size.width * .61,
        size.height * .72,
        size.width * .55,
        size.height,
      )
      ..close();
    p.color = const Color(0xFFB98A4B);
    canvas.drawPath(trail, p);

    if (campfire) {
      rect(size.width * .15, size.height * .75, size.width * .12, 7, const Color(0xFF6B4528));
      rect(size.width * .19, size.height * .68, size.width * .06, size.height * .13, const Color(0xFFF09A2A));
      rect(size.width * .205, size.height * .63, size.width * .03, size.height * .14, const Color(0xFFFFD35A));
    }

    // Stars.
    for (var i = 0; i < 16; i++) {
      final x = (i * 43 % 91) / 91 * size.width;
      final y = (i * 29 % 57) / 57 * size.height * .42;
      rect(x, y, 2, 2, const Color(0xFFD7E6F7));
    }
  }

  @override
  bool shouldRepaint(covariant _ExpeditionPainter oldDelegate) =>
      oldDelegate.campfire != campfire;
}

class _ClassMiniPainter extends CustomPainter {
  _ClassMiniPainter({
    required this.archetype,
    required this.palette,
  });

  final String archetype;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void r(double x, double y, double w, double h, Color color) =>
        _Pixel64.rect(canvas, p, x, y, w, h, color);

    r(0, 0, size.width, size.height, const Color(0xFF11131A));
    _Pixel64.dither(
      canvas,
      p,
      Rect.fromLTWH(0, 0, size.width, size.height * .74),
      palette.first.withValues(alpha: .55),
      6,
    );

    // Class halo behind the sprite.
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .50, size.height * .43),
      size.width * .31,
      palette[1],
    );

    // Ground / pedestal.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(
        size.width * .12,
        size.height * .73,
        size.width * .76,
        size.height * .17,
      ),
      const Color(0xFF2D241D),
      const Color(0xFF5A4430),
      const Color(0xFF15110E),
    );

    _Pixel64.character(
      canvas,
      p,
      origin: Offset(size.width * .50, size.height * .40),
      scale: size.width / 58 * 1.05,
      palette: palette,
      archetype: archetype,
    );

    // Tiny class insignia.
    r(size.width * .10, size.height * .10, 4, 4, palette.last);
    r(size.width * .82, size.height * .16, 4, 4, palette.last);
    r(size.width * .14, size.height * .20, 2, 2, const Color(0xFFF2E7CE));
  }

  @override
  bool shouldRepaint(covariant _ClassMiniPainter oldDelegate) =>
      oldDelegate.archetype != archetype ||
      oldDelegate.palette != palette;
}

class _ClassPortraitPainter extends CustomPainter {
  _ClassPortraitPainter({
    required this.archetype,
    required this.palette,
    required this.showRelic,
  });

  final String archetype;
  final List<Color> palette;
  final bool showRelic;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void r(double x, double y, double w, double h, Color color) =>
        _Pixel64.rect(canvas, p, x, y, w, h, color);

    // Deep class backdrop with tiled texture and glow.
    r(0, 0, size.width, size.height, const Color(0xFF0D1118));
    _Pixel64.dither(
      canvas,
      p,
      Rect.fromLTWH(0, 0, size.width, size.height * .72),
      palette.first.withValues(alpha: .65),
      9,
    );
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .50, size.height * .42),
      size.width * .29,
      palette[1],
    );

    // Decorative stone arch.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .08, size.height * .10, size.width * .84, size.height * .62),
      const Color(0xFF2B2B31),
      const Color(0xFF55505C),
      const Color(0xFF111217),
    );
    r(size.width * .12, size.height * .14, size.width * .76, size.height * .54, const Color(0xFF11151D));

    // Class banner.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .12, size.height * .17, size.width * .16, size.height * .30),
      palette[1],
      palette.last,
      palette.first,
    );
    r(size.width * .17, size.height * .24, size.width * .06, size.height * .08, palette.last);

    // Character platform.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .28, size.height * .70, size.width * .44, size.height * .12),
      const Color(0xFF3B3025),
      const Color(0xFF7B6447),
      const Color(0xFF17130F),
    );
    for (var i = 0; i < 5; i++) {
      r(size.width * (.34 + i * .075), size.height * .75, 5, 5, const Color(0xFFD6A84B));
    }

    // Full 64-bit Adventurer sprite.
    _Pixel64.character(
      canvas,
      p,
      origin: Offset(size.width * .50, size.height * .37),
      scale: size.height / 190 * 2.45,
      palette: palette,
      archetype: archetype,
    );

    // Side props tuned by class.
    switch (archetype) {
      case 'scholar':
        _Pixel64.bevel(
          canvas,
          p,
          Rect.fromLTWH(size.width * .70, size.height * .42, size.width * .16, size.height * .17),
          const Color(0xFF613778),
          const Color(0xFF9569B2),
          const Color(0xFF2E183A),
        );
        r(size.width * .735, size.height * .455, size.width * .09, 4, const Color(0xFFE5D6B7));
        r(size.width * .735, size.height * .50, size.width * .07, 4, const Color(0xFFE5D6B7));
        break;
      case 'scout':
        r(size.width * .77, size.height * .32, 4, size.height * .32, palette.last);
        for (var i = 0; i < 4; i++) {
          r(size.width * .745, size.height * (.35 + i * .06), 11, 3, const Color(0xFFD8C7A3));
        }
        break;
      case 'alchemist':
        for (var i = 0; i < 3; i++) {
          final x = size.width * (.72 + i * .055);
          r(x, size.height * .45, 8, 22, const Color(0xFFB8EAF1));
          r(x - 2, size.height * .55, 12, 14, i == 0
              ? const Color(0xFF75D65D)
              : i == 1
                  ? const Color(0xFF8D65D6)
                  : const Color(0xFFE87947));
        }
        break;
      case 'guardian':
        _Pixel64.bevel(
          canvas,
          p,
          Rect.fromLTWH(size.width * .71, size.height * .37, size.width * .16, size.height * .24),
          const Color(0xFF8F3B2D),
          const Color(0xFFD8754A),
          const Color(0xFF4A211C),
        );
        r(size.width * .765, size.height * .43, 8, size.height * .11, palette.last);
        break;
      default:
        r(size.width * .77, size.height * .30, 4, size.height * .36, palette.last);
        r(size.width * .745, size.height * .30, 22, 6, palette.last);
        _Pixel64.bevel(
          canvas,
          p,
          Rect.fromLTWH(size.width * .70, size.height * .50, size.width * .13, size.height * .14),
          const Color(0xFF6A5031),
          const Color(0xFF9A7748),
          const Color(0xFF342619),
        );
    }

    // Pixel sparks / ambient particles.
    for (var i = 0; i < 12; i++) {
      final x = size.width * (.15 + ((i * 17) % 70) / 100);
      final y = size.height * (.18 + ((i * 23) % 45) / 100);
      r(x, y, i.isEven ? 3 : 2, i.isEven ? 3 : 2, palette.last.withValues(alpha: .75));
    }

    if (showRelic) {
      final relic = _RelicPainter(archetype: archetype, palette: palette);
      canvas.save();
      canvas.translate(size.width * .70, size.height * .62);
      relic.paint(canvas, Size(size.width * .19, size.width * .19));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ClassPortraitPainter oldDelegate) =>
      oldDelegate.archetype != archetype ||
      oldDelegate.palette != palette ||
      oldDelegate.showRelic != showRelic;
}

class _EquippedAvatarPainter extends CustomPainter {
  _EquippedAvatarPainter({
    required this.archetype,
    required this.palette,
    required this.equippedSlugs,
    required this.showRelic,
    required this.portrait,
  });

  final String archetype;
  final List<Color> palette;
  final Map<String, String> equippedSlugs;
  final bool showRelic;
  final bool portrait;

  String? get outfit => equippedSlugs['outfit'];
  String? get accessory => equippedSlugs['accessory'];
  String? get familiar => equippedSlugs['familiar'];
  String? get effect => equippedSlugs['effect'];
  String? get room => equippedSlugs['room'];

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    final unit = math.max(1.0, math.min(size.width / 104, size.height / 132));
    final stageW = 104 * unit;
    final stageH = 132 * unit;
    final ox = (size.width - stageW) / 2;
    final oy = (size.height - stageH) / 2;

    void pr(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(
        Rect.fromLTWH(
          ox + (x * unit).roundToDouble(),
          oy + (y * unit).roundToDouble(),
          math.max(unit, (w * unit).roundToDouble()),
          math.max(unit, (h * unit).roundToDouble()),
        ),
        p,
      );
    }

    void glow(double x, double y, double radius, Color color) {
      _Pixel64.stepGlow(
        canvas,
        p,
        Offset(ox + x * unit, oy + y * unit),
        radius * unit,
        color,
      );
    }

    final dark = const Color(0xFF111318);
    final deepest = const Color(0xFF090B10);
    final skin = const Color(0xFFD89A68);
    final skinHi = const Color(0xFFF0BD88);
    final skinShadow = const Color(0xFF9C6345);
    final hair = const Color(0xFF3B261D);
    final hairHi = const Color(0xFF70432A);
    final hairShadow = const Color(0xFF1C1513);
    final gold = const Color(0xFFD6A84B);
    final paper = const Color(0xFFE8D7B4);
    final leather = const Color(0xFF80512F);
    final leatherHi = const Color(0xFFB57A43);
    final suit = const Color(0xFF262A35);
    final suitHi = const Color(0xFF3E4658);
    final suitShadow = const Color(0xFF171A22);
    final boot = const Color(0xFF211A18);
    final teal = const Color(0xFF4AA89A);

    // Portrait mode gets an in-world backdrop; sprite mode stays transparent.
    if (portrait) {
      pr(0, 0, 104, 132, const Color(0xFF101923));
      for (var i = 0; i < 8; i++) {
        pr(4 + ((i * 17) % 94).toDouble(), 8 + ((i * 29) % 74).toDouble(), 2, 2,
            palette.last.withValues(alpha: .45));
      }
      pr(0, 102, 104, 30, const Color(0xFF2A1D18));
      pr(0, 101, 104, 2, const Color(0xFF63432C));
      glow(26, 47, 22, const Color(0xFFE87947));
      glow(78, 36, 16, palette.last);

      // Small class-room props make the portrait feel like the same world.
      pr(5, 73, 25, 19, const Color(0xFF4C2F20));
      pr(8, 76, 19, 3, const Color(0xFF855636));
      pr(75, 69, 22, 4, const Color(0xFF6B4327));
      if ((room ?? '').contains('rainy-window')) {
        pr(68, 10, 29, 31, const Color(0xFF173450));
        pr(71, 13, 23, 25, const Color(0xFF28547B));
        for (var i = 0; i < 6; i++) {
          pr(73 + ((i * 7) % 18).toDouble(), 15 + ((i * 5) % 18).toDouble(), 1, 5,
              const Color(0xFF9DD6EA));
        }
      } else if ((room ?? '').contains('lantern')) {
        glow(84, 28, 12, const Color(0xFFFFD76A));
        pr(81, 15, 6, 18, const Color(0xFF9E6A2D));
        pr(82, 19, 4, 10, const Color(0xFFFFE49A));
      } else if ((room ?? '').contains('map')) {
        pr(70, 12, 25, 22, const Color(0xFF263E5B));
        for (var i = 0; i < 6; i++) {
          pr(73 + ((i * 11) % 18).toDouble(), 15 + ((i * 7) % 13).toDouble(), 2, 2,
              const Color(0xFFFFDF78));
        }
      }
    }

    // Effects belong behind the body.
    final effectSlug = effect ?? '';
    if (effectSlug.isNotEmpty) {
      final effectColor = effectSlug.contains('victory-sparkle')
          ? const Color(0xFFFFE07A)
          : effectSlug.contains('seal') || effectSlug.contains('crest')
              ? const Color(0xFFD9B15F)
              : palette.last;
      glow(50, 58, 29, effectColor);
      for (var i = 0; i < 13; i++) {
        final sx = 21 + ((i * 19) % 59).toDouble();
        final sy = 20 + ((i * 31) % 71).toDouble();
        pr(sx, sy, i.isEven ? 2 : 1, i.isEven ? 2 : 1, effectColor);
      }
    }

    // Ground shadow.
    pr(29, 108, 48, 5, const Color(0x77000000));
    pr(35, 112, 36, 3, const Color(0x44000000));

    // Back equipment/cloak layer.
    final outfitSlug = outfit ?? '';
    if (outfitSlug.contains('moss-green-cloak') ||
        outfitSlug.contains('hearthguard-mantle')) {
      final cloakColor = outfitSlug.contains('hearthguard')
          ? const Color(0xFF8E2D30)
          : const Color(0xFF28523A);
      final cloakLight = outfitSlug.contains('hearthguard')
          ? const Color(0xFFC65A46)
          : const Color(0xFF4D7D53);
      pr(28, 45, 10, 48, cloakColor);
      pr(68, 45, 10, 48, cloakColor);
      pr(24, 58, 12, 36, cloakColor);
      pr(70, 58, 12, 36, cloakColor);
      pr(29, 48, 3, 40, cloakLight);
      pr(74, 48, 3, 40, cloakLight);
      pr(34, 91, 7, 5, deepest);
      pr(65, 91, 7, 5, deepest);
    }

    // Legs.
    pr(39, 74, 12, 29, deepest);
    pr(55, 74, 12, 29, deepest);
    pr(41, 76, 8, 25, suitShadow);
    pr(57, 76, 8, 25, suitShadow);

    // Boots, with class/exclusive boot override.
    final bootColor = outfitSlug.contains('pathfinder-boots')
        ? const Color(0xFF6B4229)
        : boot;
    final bootHi = outfitSlug.contains('pathfinder-boots')
        ? const Color(0xFFA87843)
        : const Color(0xFF41302A);
    pr(36, 99, 16, 9, deepest);
    pr(55, 99, 17, 9, deepest);
    pr(38, 98, 13, 7, bootColor);
    pr(57, 98, 14, 7, bootColor);
    pr(40, 99, 8, 2, bootHi);
    pr(59, 99, 9, 2, bootHi);

    // Torso base; item-specific outfit takes over the silhouette.
    if (outfitSlug.contains('starter-business-suit')) {
      pr(34, 45, 38, 34, deepest);
      pr(36, 47, 34, 30, suit);
      pr(38, 49, 8, 26, suitHi);
      pr(60, 49, 8, 26, suitShadow);
      pr(47, 47, 12, 24, paper);
      pr(50, 50, 6, 18, const Color(0xFF2E6C64));
      pr(51, 52, 4, 14, const Color(0xFFD9E9DB));
      // Lapels.
      pr(42, 48, 5, 16, const Color(0xFF525A6B));
      pr(59, 48, 5, 16, const Color(0xFF191C24));
      pr(42, 61, 5, 4, gold);
      pr(59, 61, 5, 4, gold);
      // Belt.
      pr(38, 72, 30, 4, leather);
      pr(50, 72, 6, 4, gold);
    } else {
      pr(34, 45, 38, 34, deepest);
      pr(36, 47, 34, 30, palette[1]);
      pr(39, 49, 6, 25, palette.last.withValues(alpha: .72));
      pr(61, 49, 6, 25, palette.first);
      pr(39, 72, 28, 4, leather);
      pr(50, 72, 6, 4, gold);
    }

    // Arms and hands.
    pr(28, 50, 9, 27, deepest);
    pr(69, 50, 9, 27, deepest);
    pr(30, 52, 6, 21, outfitSlug.contains('starter-business-suit') ? suit : palette[1]);
    pr(70, 52, 6, 21, outfitSlug.contains('starter-business-suit') ? suit : palette[1]);
    pr(30, 72, 7, 7, skinShadow);
    pr(69, 72, 7, 7, skinShadow);
    pr(31, 71, 5, 5, skin);

    // Neck.
    pr(47, 40, 12, 8, deepest);
    pr(49, 40, 8, 7, skin);

    // Head outline/ears.
    pr(35, 18, 36, 27, deepest);
    pr(38, 20, 30, 24, skin);
    pr(36, 28, 4, 9, skinShadow);
    pr(68, 28, 4, 9, skinShadow);
    pr(40, 21, 24, 5, skinHi);

    // Hair: layered, asymmetric, more 64-bit-era detail than the old block head.
    pr(34, 14, 38, 9, hairShadow);
    pr(37, 11, 9, 8, hair);
    pr(46, 9, 15, 9, hair);
    pr(59, 12, 12, 8, hair);
    pr(34, 20, 8, 18, hair);
    pr(66, 18, 8, 21, hair);
    pr(38, 13, 7, 5, hairHi);
    pr(48, 11, 8, 4, hairHi);
    pr(61, 14, 6, 4, hairHi);
    pr(33, 36, 5, 9, hairShadow);
    pr(70, 35, 5, 10, hairShadow);

    // Brows, eyes, nose, mouth.
    pr(43, 28, 7, 2, hairShadow);
    pr(57, 28, 7, 2, hairShadow);
    pr(44, 32, 4, 4, const Color(0xFF1C2533));
    pr(59, 32, 4, 4, const Color(0xFF1C2533));
    pr(45, 32, 1, 1, const Color(0xFFEAF7FF));
    pr(60, 32, 1, 1, const Color(0xFFEAF7FF));
    pr(53, 35, 2, 3, skinShadow);
    pr(49, 40, 9, 2, const Color(0xFF7A3E39));

    // Archetype identity remains subtle so outfits still matter.
    switch (archetype) {
      case 'alchemist':
        pr(77, 63, 5, 11, deepest);
        pr(78, 62, 3, 4, paper);
        pr(75, 73, 10, 8, const Color(0xFF52C96C));
        pr(78, 74, 4, 3, const Color(0xFFC7FFD2));
        glow(80, 76, 9, const Color(0xFF52C96C));
        break;
      case 'scholar':
        pr(76, 63, 14, 18, const Color(0xFF4B2A70));
        pr(79, 66, 8, 2, paper);
        pr(79, 71, 7, 2, paper);
        pr(79, 76, 6, 2, paper);
        break;
      case 'scout':
        pr(78, 49, 2, 34, leatherHi);
        pr(80, 52, 6, 2, gold);
        pr(80, 59, 6, 2, gold);
        break;
      case 'guardian':
        pr(76, 52, 14, 22, const Color(0xFF7D2A2C));
        pr(79, 55, 8, 16, gold);
        break;
      default:
        pr(77, 51, 3, 33, gold);
        pr(75, 49, 7, 4, gold);
    }

    // Accessories aligned to the canonical body anchors.
    final accessorySlug = accessory ?? '';
    if (accessorySlug.contains('round-scholar-glasses')) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = math.max(2.0, unit * 1.5);
      p.color = const Color(0xFFD5B05A);
      canvas.drawRect(Rect.fromLTWH(ox + 41 * unit, oy + 29 * unit, 10 * unit, 8 * unit), p);
      canvas.drawRect(Rect.fromLTWH(ox + 56 * unit, oy + 29 * unit, 10 * unit, 8 * unit), p);
      canvas.drawLine(Offset(ox + 51 * unit, oy + 33 * unit),
          Offset(ox + 56 * unit, oy + 33 * unit), p);
      p.style = PaintingStyle.fill;
      pr(43, 31, 6, 2, const Color(0xFF9CD9EE).withValues(alpha: .8));
      pr(58, 31, 6, 2, const Color(0xFF9CD9EE).withValues(alpha: .8));
    } else if (accessorySlug.contains('tiny-wizard-hat')) {
      pr(35, 12, 37, 5, const Color(0xFF2C1B38));
      pr(42, 3, 23, 12, const Color(0xFF5E3A7D));
      pr(50, 2, 8, 5, const Color(0xFF7851A1));
      pr(53, 5, 4, 4, gold);
    } else if (accessorySlug.contains('satchel')) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = math.max(2.0, unit * 2);
      p.color = gold;
      canvas.drawLine(
        Offset(ox + 37 * unit, oy + 48 * unit),
        Offset(ox + 67 * unit, oy + 83 * unit),
        p,
      );
      p.style = PaintingStyle.fill;
      pr(62, 72, 19, 19, leather);
      pr(65, 75, 13, 4, leatherHi);
      pr(69, 81, 5, 4, gold);
    } else if (accessorySlug.contains('grimoire')) {
      pr(73, 62, 20, 23, const Color(0xFF512467));
      pr(76, 65, 3, 17, gold);
      pr(82, 67, 8, 2, paper);
      pr(82, 72, 7, 2, paper);
      pr(82, 77, 6, 2, paper);
    } else if (accessorySlug.contains('compass')) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = math.max(2.0, unit * 1.4);
      p.color = gold;
      canvas.drawCircle(Offset(ox + 54 * unit, oy + 65 * unit), 6 * unit, p);
      canvas.drawLine(Offset(ox + 54 * unit, oy + 60 * unit),
          Offset(ox + 57 * unit, oy + 68 * unit), p);
      p.style = PaintingStyle.fill;
    } else if (accessorySlug.contains('phial') ||
        accessorySlug.contains('tonic')) {
      pr(74, 63, 6, 13, const Color(0xFFB9EAF3));
      pr(72, 75, 10, 8, const Color(0xFF48C96A));
      pr(75, 76, 4, 3, const Color(0xFFD2FFDB));
      glow(77, 78, 8, const Color(0xFF48C96A));
    }

    // Familiar companion is rendered with the same logical grid and palette density.
    final familiarSlug = familiar ?? '';
    if (familiarSlug.isNotEmpty) {
      final fx = 86.0;
      final fy = 93.0;
      if (familiarSlug.contains('fox')) {
        pr(fx - 9, fy - 2, 18, 12, const Color(0xFFC9682E));
        pr(fx - 7, fy - 7, 14, 11, const Color(0xFFE28B43));
        pr(fx - 8, fy - 11, 5, 6, const Color(0xFFE28B43));
        pr(fx + 3, fy - 11, 5, 6, const Color(0xFFE28B43));
        pr(fx - 5, fy - 3, 3, 3, deepest);
        pr(fx + 2, fy - 3, 3, 3, deepest);
        pr(fx + 8, fy + 3, 10, 5, const Color(0xFF7F4224));
      } else if (familiarSlug.contains('owl')) {
        pr(fx - 7, fy - 8, 14, 17, const Color(0xFF9B6736));
        pr(fx - 10, fy - 5, 5, 12, const Color(0xFF6E4729));
        pr(fx + 5, fy - 5, 5, 12, const Color(0xFF6E4729));
        pr(fx - 5, fy - 3, 4, 4, const Color(0xFFFFE07A));
        pr(fx + 1, fy - 3, 4, 4, const Color(0xFFFFE07A));
        pr(fx - 1, fy + 2, 3, 3, gold);
      } else if (familiarSlug.contains('slime')) {
        pr(fx - 9, fy - 3, 18, 11, const Color(0xFF4CCDC4));
        pr(fx - 7, fy - 8, 14, 8, const Color(0xFF6EE2D8));
        pr(fx - 4, fy - 2, 3, 3, deepest);
        pr(fx + 2, fy - 2, 3, 3, deepest);
        pr(fx - 4, fy + 4, 8, 2, const Color(0xFFBDF9F3));
      } else if (familiarSlug.contains('moth')) {
        pr(fx - 2, fy - 7, 4, 14, const Color(0xFF536D35));
        pr(fx - 10, fy - 8, 8, 13, const Color(0xFF9FE16A));
        pr(fx + 2, fy - 8, 8, 13, const Color(0xFF9FE16A));
        pr(fx - 8, fy - 5, 5, 7, const Color(0xFFD9F39B));
        pr(fx + 3, fy - 5, 5, 7, const Color(0xFFD9F39B));
      } else if (familiarSlug.contains('mushroom')) {
        pr(fx - 2, fy, 4, 9, paper);
        pr(fx - 8, fy - 7, 16, 8, const Color(0xFFB84D3A));
        pr(fx - 5, fy - 5, 3, 3, const Color(0xFFF4E7C7));
        pr(fx + 2, fy - 4, 3, 3, const Color(0xFFF4E7C7));
      }
    }

    if (showRelic) {
      final relic = _RelicPainter(archetype: archetype, palette: palette);
      canvas.save();
      canvas.translate(ox + 6 * unit, oy + 7 * unit);
      relic.paint(canvas, Size(21 * unit, 21 * unit));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _EquippedAvatarPainter oldDelegate) =>
      oldDelegate.archetype != archetype ||
      oldDelegate.equippedSlugs != equippedSlugs ||
      oldDelegate.showRelic != showRelic ||
      oldDelegate.portrait != portrait;
}

class _RelicPainter extends CustomPainter {
  _RelicPainter({required this.archetype, required this.palette});
  final String archetype;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    final c = Offset(size.width / 2, size.height / 2);

    p.color = const Color(0x33111111);
    canvas.drawCircle(c, size.shortestSide * .46, p);
    p.color = palette.last;
    canvas.drawCircle(c, size.shortestSide * .34, p);
    p.color = palette[1];
    canvas.drawCircle(c, size.shortestSide * .25, p);
    p.color = const Color(0xFF17151A);

    switch (archetype) {
      case 'scholar':
        canvas.drawRect(
          Rect.fromCenter(center: c, width: size.width * .34, height: size.height * .42),
          p,
        );
        p.color = palette.last;
        canvas.drawRect(
          Rect.fromCenter(center: c, width: size.width * .06, height: size.height * .26),
          p,
        );
        break;
      case 'scout':
        p.style = PaintingStyle.stroke;
        p.strokeWidth = 4;
        canvas.drawCircle(c, size.shortestSide * .18, p);
        canvas.drawLine(Offset(c.dx, c.dy - 17), Offset(c.dx + 10, c.dy + 11), p);
        p.style = PaintingStyle.fill;
        break;
      case 'alchemist':
        canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 11), width: 8, height: 14), p);
        canvas.drawCircle(Offset(c.dx, c.dy + 7), size.shortestSide * .16, p);
        break;
      case 'guardian':
        final path = Path()
          ..moveTo(c.dx, c.dy - 20)
          ..lineTo(c.dx + 17, c.dy - 10)
          ..lineTo(c.dx + 12, c.dy + 18)
          ..lineTo(c.dx, c.dy + 26)
          ..lineTo(c.dx - 12, c.dy + 18)
          ..lineTo(c.dx - 17, c.dy - 10)
          ..close();
        canvas.drawPath(path, p);
        break;
      default:
        p.style = PaintingStyle.stroke;
        p.strokeWidth = 4;
        canvas.drawCircle(c, size.shortestSide * .18, p);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
            Offset(c.dx + math.cos(a) * 10, c.dy + math.sin(a) * 10),
            Offset(c.dx + math.cos(a) * 22, c.dy + math.sin(a) * 22),
            p,
          );
        }
        p.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(covariant _RelicPainter oldDelegate) =>
      oldDelegate.archetype != archetype;
}

class _ItemPainter extends CustomPainter {
  _ItemPainter({
    required this.slug,
    required this.category,
    required this.palette,
    required this.locked,
  });

  final String slug;
  final String category;
  final List<Color> palette;
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF17151A));
    rect(3, 3, size.width - 6, size.height - 6, palette.first);

    final gold = palette.last;
    final accent = palette[1];
    final paper = const Color(0xFFD8C7A3);
    final leather = const Color(0xFF8B5A32);
    final teal = const Color(0xFF76D7C4);

    if (slug.contains('grimoire') || slug.contains('seal')) {
      rect(size.width * .24, size.height * .20, size.width * .52, size.height * .58, const Color(0xFF6A337C));
      rect(size.width * .29, size.height * .24, size.width * .06, size.height * .50, gold);
      rect(size.width * .43, size.height * .35, size.width * .27, 5, paper);
      rect(size.width * .43, size.height * .47, size.width * .20, 5, paper);
      rect(size.width * .43, size.height * .59, size.width * .24, 5, paper);
    } else if (slug.contains('owl')) {
      p.color = const Color(0xFFB77A3A);
      canvas.drawCircle(Offset(size.width * .50, size.height * .47), size.width * .24, p);
      rect(size.width * .29, size.height * .20, size.width * .13, size.height * .18, const Color(0xFF7A4C2B));
      rect(size.width * .58, size.height * .20, size.width * .13, size.height * .18, const Color(0xFF7A4C2B));
      rect(size.width * .36, size.height * .40, 8, 8, const Color(0xFFFFE07A));
      rect(size.width * .58, size.height * .40, 8, 8, const Color(0xFFFFE07A));
      rect(size.width * .47, size.height * .50, 6, 9, gold);
    } else if (slug.contains('boot')) {
      rect(size.width * .23, size.height * .21, size.width * .20, size.height * .45, leather);
      rect(size.width * .49, size.height * .25, size.width * .20, size.height * .41, leather);
      rect(size.width * .17, size.height * .61, size.width * .30, size.height * .14, const Color(0xFF3B2A20));
      rect(size.width * .43, size.height * .61, size.width * .30, size.height * .14, const Color(0xFF3B2A20));
      rect(size.width * .27, size.height * .32, size.width * .12, 4, gold);
      rect(size.width * .53, size.height * .36, size.width * .12, 4, gold);
    } else if (slug.contains('fox')) {
      p.color = const Color(0xFFD77A32);
      canvas.drawCircle(Offset(size.width * .48, size.height * .48), size.width * .22, p);
      final ears = Path()
        ..moveTo(size.width * .30, size.height * .34)
        ..lineTo(size.width * .35, size.height * .12)
        ..lineTo(size.width * .44, size.height * .35)
        ..moveTo(size.width * .54, size.height * .35)
        ..lineTo(size.width * .64, size.height * .12)
        ..lineTo(size.width * .70, size.height * .36);
      p.style = PaintingStyle.stroke;
      p.strokeWidth = 8;
      p.color = const Color(0xFFD77A32);
      canvas.drawPath(ears, p);
      p.style = PaintingStyle.fill;
      rect(size.width * .37, size.height * .44, 6, 6, const Color(0xFF17151A));
      rect(size.width * .57, size.height * .44, 6, 6, const Color(0xFF17151A));
      rect(size.width * .46, size.height * .56, 8, 6, const Color(0xFF17151A));
    } else if (slug.contains('tonic') || slug.contains('phial')) {
      rect(size.width * .43, size.height * .15, size.width * .15, size.height * .18, gold);
      rect(size.width * .36, size.height * .30, size.width * .29, size.height * .10, paper);
      p.color = teal;
      canvas.drawCircle(Offset(size.width * .50, size.height * .58), size.width * .23, p);
      rect(size.width * .34, size.height * .57, size.width * .32, size.height * .18, const Color(0xFF42B883));
      rect(size.width * .42, size.height * .48, 5, 5, const Color(0xFFD9FFD0));
      rect(size.width * .57, size.height * .56, 4, 4, const Color(0xFFD9FFD0));
    } else if (slug.contains('slime')) {
      p.color = const Color(0xFF55D7CB);
      canvas.drawCircle(Offset(size.width * .50, size.height * .56), size.width * .25, p);
      rect(size.width * .25, size.height * .58, size.width * .50, size.height * .16, const Color(0xFF55D7CB));
      rect(size.width * .39, size.height * .51, 6, 6, const Color(0xFF173B2B));
      rect(size.width * .58, size.height * .51, 6, 6, const Color(0xFF173B2B));
    } else if (slug.contains('mantle')) {
      final path = Path()
        ..moveTo(size.width * .50, size.height * .16)
        ..lineTo(size.width * .72, size.height * .32)
        ..lineTo(size.width * .67, size.height * .78)
        ..lineTo(size.width * .50, size.height * .67)
        ..lineTo(size.width * .33, size.height * .78)
        ..lineTo(size.width * .28, size.height * .32)
        ..close();
      p.color = const Color(0xFFA53A32);
      canvas.drawPath(path, p);
      rect(size.width * .47, size.height * .20, size.width * .06, size.height * .50, gold);
    } else if (slug.contains('lantern')) {
      rect(size.width * .40, size.height * .15, size.width * .20, size.height * .10, gold);
      rect(size.width * .31, size.height * .28, size.width * .38, size.height * .42, const Color(0xFFB47A2B));
      rect(size.width * .38, size.height * .34, size.width * .24, size.height * .28, const Color(0xFFFFD76A));
      rect(size.width * .39, size.height * .11, size.width * .22, 5, const Color(0xFF8E6B35));
    } else if (slug.contains('satchel')) {
      rect(size.width * .25, size.height * .34, size.width * .50, size.height * .40, leather);
      rect(size.width * .31, size.height * .26, size.width * .38, size.height * .16, const Color(0xFF6A4328));
      rect(size.width * .46, size.height * .44, size.width * .10, size.height * .10, gold);
      p.style = PaintingStyle.stroke;
      p.strokeWidth = 5;
      p.color = gold;
      canvas.drawArc(
        Rect.fromLTWH(size.width * .29, size.height * .15, size.width * .42, size.height * .35),
        math.pi,
        math.pi,
        false,
        p,
      );
      p.style = PaintingStyle.fill;
    } else if (slug.contains('moth')) {
      p.color = const Color(0xFFA8E36D);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .38, size.height * .48), width: size.width * .30, height: size.height * .38), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .62, size.height * .48), width: size.width * .30, height: size.height * .38), p);
      rect(size.width * .47, size.height * .31, size.width * .06, size.height * .36, const Color(0xFF6F8D3A));
      rect(size.width * .31, size.height * .43, 5, 5, gold);
      rect(size.width * .65, size.height * .43, 5, 5, gold);
    } else if (slug.contains('compass') || slug.contains('map')) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = 5;
      p.color = gold;
      canvas.drawCircle(Offset(size.width * .50, size.height * .50), size.width * .25, p);
      canvas.drawLine(Offset(size.width * .50, size.height * .27), Offset(size.width * .58, size.height * .56), p);
      canvas.drawLine(Offset(size.width * .58, size.height * .56), Offset(size.width * .38, size.height * .49), p);
      p.style = PaintingStyle.fill;
    } else if (category == 'familiar') {
      p.color = accent;
      canvas.drawCircle(Offset(size.width * .50, size.height * .48), size.width * .23, p);
      rect(size.width * .39, size.height * .43, 6, 6, gold);
      rect(size.width * .58, size.height * .43, 6, 6, gold);
    } else {
      // Universal guild-good sigil.
      p.color = gold;
      canvas.drawCircle(Offset(size.width * .50, size.height * .50), size.width * .24, p);
      rect(size.width * .46, size.height * .28, size.width * .08, size.height * .44, const Color(0xFF17151A));
      rect(size.width * .29, size.height * .46, size.width * .42, size.height * .08, const Color(0xFF17151A));
    }

    if (locked) {
      rect(0, 0, size.width, size.height, const Color(0x88000000));
      rect(size.width * .40, size.height * .45, size.width * .20, size.height * .23, const Color(0xFF101114));
      p.style = PaintingStyle.stroke;
      p.strokeWidth = 4;
      p.color = const Color(0xFFD8C7A3);
      canvas.drawArc(
        Rect.fromLTWH(size.width * .39, size.height * .25, size.width * .22, size.height * .30),
        math.pi,
        math.pi,
        false,
        p,
      );
      p.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(covariant _ItemPainter oldDelegate) =>
      oldDelegate.slug != slug ||
      oldDelegate.category != category ||
      oldDelegate.locked != locked;
}

class _MarketPainter extends CustomPainter {
  _MarketPainter({required this.palette});
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void r(double x, double y, double w, double h, Color color) =>
        _Pixel64.rect(canvas, p, x, y, w, h, color);

    r(0, 0, size.width, size.height, const Color(0xFF10131A));
    r(0, size.height * .70, size.width, size.height * .30, const Color(0xFF3E291D));
    _Pixel64.dither(
      canvas,
      p,
      Rect.fromLTWH(0, 0, size.width, size.height * .70),
      const Color(0xFF1E2730),
      9,
    );

    // Rich striped awning with trim.
    for (var i = 0; i < 8; i++) {
      final x = size.width * (.05 + i * .115);
      final stripe = i.isEven ? palette[1] : const Color(0xFFE1D0AA);
      _Pixel64.bevel(
        canvas,
        p,
        Rect.fromLTWH(x, size.height * .06, size.width * .115, size.height * .17),
        stripe,
        stripe.withValues(alpha: .92),
        const Color(0xFF5A402A),
      );
    }
    r(size.width * .045, size.height * .225, size.width * .92, 7, const Color(0xFF8E6B35));
    r(size.width * .06, size.height * .245, size.width * .89, 3, const Color(0xFFD2A656));

    // Back shelves with stacked goods.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .08, size.height * .29, size.width * .34, size.height * .36),
      const Color(0xFF4D2E20),
      const Color(0xFF7B4C2F),
      const Color(0xFF281812),
    );
    for (var row = 0; row < 3; row++) {
      r(size.width * .10, size.height * (.37 + row * .095), size.width * .30, 5, const Color(0xFFB58049));
    }
    final goods = [
      const Color(0xFF75D7C5),
      const Color(0xFFB98CFF),
      const Color(0xFFF1C75B),
      const Color(0xFFE87947),
      const Color(0xFF6BA6E8),
      const Color(0xFF86C66A),
    ];
    for (var i = 0; i < 15; i++) {
      final col = i % 5;
      final row = i ~/ 5;
      final x = size.width * (.115 + col * .055);
      final y = size.height * (.31 + row * .095);
      r(x, y, 8, 18, goods[i % goods.length]);
      r(x + 2, y - 4, 4, 5, const Color(0xFFD9C8A1));
      r(x + 1, y + 3, 2, 10, const Color(0x55FFFFFF));
    }

    // Hanging class pennants.
    for (var i = 0; i < 3; i++) {
      final x = size.width * (.46 + i * .09);
      r(x, size.height * .27, 3, size.height * .12, const Color(0xFF6A4328));
      final path = Path()
        ..moveTo(x + 3, size.height * .29)
        ..lineTo(x + size.width * .055, size.height * .31)
        ..lineTo(x + size.width * .028, size.height * .43)
        ..close();
      p.color = i == 1 ? palette[1] : palette.first;
      canvas.drawPath(path, p);
      r(x + size.width * .025, size.height * .335, 5, 5, palette.last);
    }

    // Shopkeeper with more 64-bit shading.
    final keeperOrigin = Offset(size.width * .67, size.height * .32);
    _Pixel64.character(
      canvas,
      p,
      origin: keeperOrigin,
      scale: size.height / 145 * 1.35,
      palette: palette,
      archetype: 'wanderer',
    );
    // Apron overlay.
    r(size.width * .625, size.height * .46, size.width * .09, size.height * .18, const Color(0xFF6B5034));
    r(size.width * .642, size.height * .49, size.width * .055, size.height * .13, const Color(0xFF8B6A43));

    // Counter, display cloth, and sparkle.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .44, size.height * .59, size.width * .47, size.height * .14),
      const Color(0xFF74482B),
      const Color(0xFFA16A3E),
      const Color(0xFF3B2419),
    );
    r(size.width * .48, size.height * .62, size.width * .14, size.height * .07, palette.first);
    r(size.width * .49, size.height * .63, size.width * .12, 3, palette.last);

    // Coin stacks and gem.
    for (var i = 0; i < 4; i++) {
      p.color = const Color(0xFFF1C75B);
      canvas.drawCircle(
        Offset(size.width * (.80 + i * .018), size.height * (.56 - i * .013)),
        5,
        p,
      );
      r(size.width * (.80 + i * .018) - 2, size.height * (.56 - i * .013) - 3, 3, 3, const Color(0xFFFFE69B));
    }
    final gem = Path()
      ..moveTo(size.width * .735, size.height * .53)
      ..lineTo(size.width * .755, size.height * .56)
      ..lineTo(size.width * .74, size.height * .61)
      ..lineTo(size.width * .72, size.height * .56)
      ..close();
    p.color = const Color(0xFF8FD9FF);
    canvas.drawPath(gem, p);

    // Floor rug / path.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .20, size.height * .78, size.width * .58, size.height * .13),
      const Color(0xFF21433F),
      const Color(0xFF3A6A62),
      const Color(0xFF102320),
    );
    for (var i = 0; i < 8; i++) {
      r(size.width * (.235 + i * .065), size.height * .815, 5, 5, const Color(0xFFD4AA55));
    }

    // Lantern glow.
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .91, size.height * .38),
      24,
      const Color(0xFFFFC95C),
    );
    r(size.width * .905, size.height * .16, 4, size.height * .18, const Color(0xFF7B4A2A));
    r(size.width * .875, size.height * .34, size.width * .075, size.height * .16, const Color(0xFFB77A2D));
    r(size.width * .891, size.height * .375, size.width * .043, size.height * .085, const Color(0xFFFFE39A));
  }

  @override
  bool shouldRepaint(covariant _MarketPainter oldDelegate) =>
      oldDelegate.palette != palette;
}

class _BossSigilPainter extends CustomPainter {
  _BossSigilPainter(this.bossType);
  final String bossType;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF14131A));
    final ember = const Color(0xFFE87947);
    final violet = const Color(0xFF7654D8);
    final paper = const Color(0xFFD8C7A3);
    final teal = const Color(0xFF4AA89A);

    switch (bossType) {
      case 'meeting_mimic':
        rect(size.width * .20, size.height * .24, size.width * .60, size.height * .52, violet);
        rect(size.width * .30, size.height * .35, size.width * .14, size.height * .14, paper);
        rect(size.width * .56, size.height * .35, size.width * .14, size.height * .14, paper);
        rect(size.width * .43, size.height * .58, size.width * .14, 5, ember);
        break;
      case 'spreadsheet_slime':
        p.color = teal;
        canvas.drawCircle(Offset(size.width * .50, size.height * .56), size.width * .25, p);
        rect(size.width * .25, size.height * .58, size.width * .50, size.height * .15, teal);
        rect(size.width * .37, size.height * .48, 5, 5, paper);
        rect(size.width * .58, size.height * .48, 5, 5, paper);
        break;
      case 'calendar_kraken':
        rect(size.width * .22, size.height * .18, size.width * .56, size.height * .58, const Color(0xFF8A5A35));
        rect(size.width * .28, size.height * .30, size.width * .44, size.height * .32, paper);
        for (var i = 0; i < 4; i++) {
          rect(size.width * (.33 + (i % 2) * .20), size.height * (.36 + (i ~/ 2) * .14), 6, 6, ember);
        }
        break;
      case 'printer_poltergeist':
        rect(size.width * .20, size.height * .30, size.width * .60, size.height * .38, const Color(0xFF5E6670));
        rect(size.width * .30, size.height * .14, size.width * .40, size.height * .28, paper);
        rect(size.width * .30, size.height * .62, size.width * .40, size.height * .20, paper);
        rect(size.width * .64, size.height * .43, 6, 6, ember);
        break;
      case 'notification_swarm':
        for (var i = 0; i < 7; i++) {
          final x = size.width * (.16 + (i * .11) % .62);
          final y = size.height * (.18 + ((i * 3) % 5) * .12);
          rect(x, y, 9, 9, i.isEven ? ember : violet);
        }
        break;
      case 'ticket_troll':
        rect(size.width * .24, size.height * .24, size.width * .52, size.height * .52, const Color(0xFF4A5D3C));
        rect(size.width * .31, size.height * .37, 6, 6, paper);
        rect(size.width * .61, size.height * .37, 6, 6, paper);
        rect(size.width * .40, size.height * .58, size.width * .20, 5, ember);
        break;
      case 'update_dragon':
        final wing = Path()
          ..moveTo(size.width * .20, size.height * .66)
          ..lineTo(size.width * .35, size.height * .24)
          ..lineTo(size.width * .48, size.height * .62)
          ..lineTo(size.width * .64, size.height * .22)
          ..lineTo(size.width * .80, size.height * .68)
          ..close();
        p.color = const Color(0xFF9B3B36);
        canvas.drawPath(wing, p);
        rect(size.width * .46, size.height * .44, 6, 6, paper);
        rect(size.width * .56, size.height * .44, 6, 6, paper);
        break;
      default:
        // Inbox Hydra - three paper heads.
        for (var i = 0; i < 3; i++) {
          final x = size.width * (.18 + i * .24);
          rect(x, size.height * (.25 + (i % 2) * .10), size.width * .18, size.height * .34, paper);
          rect(x + size.width * .05, size.height * (.43 + (i % 2) * .10), 5, 5, ember);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _BossSigilPainter oldDelegate) =>
      oldDelegate.bossType != bossType;
}

class _BossPainter extends CustomPainter {
  _BossPainter(this.bossType);
  final String bossType;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF14131A));
    final violet = const Color(0xFF5B2C83);
    final ember = const Color(0xFFE06B2D);
    final paper = const Color(0xFFD8C7A3);

    if (bossType == 'inbox_hydra') {
      rect(size.width * .25, size.height * .35, size.width * .50, size.height * .48, const Color(0xFF44362E));
      for (var i = 0; i < 3; i++) {
        rect(size.width * (.26 + i * .18), size.height * (.18 + (i % 2) * .06), 26, 50, paper);
        rect(size.width * (.29 + i * .18), size.height * (.29 + (i % 2) * .06), 8, 8, ember);
      }
      rect(size.width * .36, size.height * .50, size.width * .28, 14, const Color(0xFF1A1010));
      rect(size.width * .40, size.height * .53, 9, 7, ember);
      rect(size.width * .56, size.height * .53, 9, 7, ember);
    } else if (bossType == 'meeting_mimic') {
      rect(size.width * .31, size.height * .16, size.width * .38, size.height * .67, violet);
      for (var i = 0; i < 6; i++) {
        final x = size.width * (.12 + (i % 3) * .30);
        final y = size.height * (.17 + (i ~/ 3) * .38);
        rect(x, y, 36, 30, const Color(0xFF2E5480));
        rect(x + 12, y + 8, 12, 12, const Color(0xFFB9D4E8));
      }
      rect(size.width * .43, size.height * .42, 9, 9, const Color(0xFFE94A6B));
      rect(size.width * .55, size.height * .42, 9, 9, const Color(0xFFE94A6B));
    } else if (bossType == 'calendar_kraken') {
      rect(size.width * .31, size.height * .15, size.width * .38, size.height * .67, const Color(0xFF7A4D2B));
      rect(size.width * .34, size.height * .22, size.width * .32, size.height * .35, paper);
      for (var i = 0; i < 9; i++) {
        rect(size.width * (.37 + (i % 3) * .09), size.height * (.28 + (i ~/ 3) * .09), 9, 9, ember);
      }
      p.color = const Color(0xFF22242B);
      canvas.drawCircle(Offset(size.width * .50, size.height * .69), 22, p);
      p.color = paper;
      canvas.drawLine(Offset(size.width * .50, size.height * .69), Offset(size.width * .50, size.height * .56), p..strokeWidth = 3);
      canvas.drawLine(Offset(size.width * .50, size.height * .69), Offset(size.width * .61, size.height * .69), p);
    } else if (bossType == 'notification_swarm') {
      for (var i = 0; i < 14; i++) {
        final x = size.width * ((i * 37 % 91) / 100 + .04);
        final y = size.height * ((i * 29 % 73) / 100 + .08);
        rect(x, y, 16, 16, i.isEven ? const Color(0xFFE94A6B) : const Color(0xFF4B8DE8));
      }
      rect(size.width * .39, size.height * .28, size.width * .22, size.height * .52, const Color(0xFF22142E));
      rect(size.width * .44, size.height * .42, 8, 8, const Color(0xFFF064AF));
      rect(size.width * .55, size.height * .42, 8, 8, const Color(0xFFF064AF));
    } else if (bossType == 'spreadsheet_slime') {
      // Glossy grid slime with cell highlights and dripping formulas.
      _Pixel64.stepGlow(
        canvas,
        p,
        Offset(size.width * .50, size.height * .55),
        42,
        const Color(0xFF45B7A8),
      );
      rect(size.width * .24, size.height * .39, size.width * .52, size.height * .34, const Color(0xFF236C68));
      rect(size.width * .28, size.height * .33, size.width * .44, size.height * .34, const Color(0xFF3EA89C));
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 5; col++) {
          final x = size.width * (.31 + col * .075);
          final y = size.height * (.38 + row * .075);
          rect(x, y, 10, 8, (row + col).isEven ? const Color(0xFF9DE1C8) : const Color(0xFF267C75));
        }
      }
      rect(size.width * .36, size.height * .46, 8, 8, const Color(0xFFF7E58E));
      rect(size.width * .60, size.height * .46, 8, 8, const Color(0xFFF7E58E));
      rect(size.width * .44, size.height * .61, size.width * .12, 6, const Color(0xFF16433F));
      rect(size.width * .30, size.height * .70, size.width * .08, size.height * .13, const Color(0xFF2E8D84));
      rect(size.width * .62, size.height * .70, size.width * .07, size.height * .10, const Color(0xFF2E8D84));
    } else if (bossType == 'printer_poltergeist') {
      // Haunted office printer with spectral paper trail.
      _Pixel64.stepGlow(
        canvas,
        p,
        Offset(size.width * .50, size.height * .44),
        45,
        const Color(0xFF8D65D6),
      );
      _Pixel64.bevel(
        canvas,
        p,
        Rect.fromLTWH(size.width * .28, size.height * .31, size.width * .44, size.height * .38),
        const Color(0xFF5E6670),
        const Color(0xFF8A949E),
        const Color(0xFF2C3138),
      );
      rect(size.width * .35, size.height * .16, size.width * .30, size.height * .25, paper);
      rect(size.width * .38, size.height * .20, size.width * .22, 5, const Color(0xFF7C7466));
      rect(size.width * .38, size.height * .28, size.width * .18, 5, const Color(0xFF7C7466));
      rect(size.width * .34, size.height * .61, size.width * .32, size.height * .20, paper);
      rect(size.width * .39, size.height * .66, size.width * .22, 4, const Color(0xFF8A8170));
      rect(size.width * .62, size.height * .42, 8, 8, const Color(0xFFE87947));
      rect(size.width * .37, size.height * .46, 7, 7, const Color(0xFF8D65D6));
      rect(size.width * .56, size.height * .46, 7, 7, const Color(0xFF8D65D6));
      for (var i = 0; i < 5; i++) {
        rect(
          size.width * (.17 + i * .13),
          size.height * (.12 + (i % 2) * .07),
          12,
          8,
          const Color(0x99DCC9FF),
        );
      }
    } else if (bossType == 'ticket_troll') {
      // Help-desk troll built from tickets and backlog cards.
      _Pixel64.bevel(
        canvas,
        p,
        Rect.fromLTWH(size.width * .30, size.height * .30, size.width * .40, size.height * .45),
        const Color(0xFF40523B),
        const Color(0xFF6C805F),
        const Color(0xFF202B1E),
      );
      rect(size.width * .25, size.height * .39, size.width * .08, size.height * .26, const Color(0xFF6B5034));
      rect(size.width * .67, size.height * .39, size.width * .08, size.height * .26, const Color(0xFF6B5034));
      rect(size.width * .36, size.height * .20, size.width * .28, size.height * .17, const Color(0xFF5D704F));
      rect(size.width * .39, size.height * .26, 8, 8, const Color(0xFFF7E58E));
      rect(size.width * .58, size.height * .26, 8, 8, const Color(0xFFF7E58E));
      rect(size.width * .43, size.height * .52, size.width * .14, 7, const Color(0xFF1B1715));
      for (var i = 0; i < 6; i++) {
        final x = size.width * (.13 + (i % 3) * .30);
        final y = size.height * (.12 + (i ~/ 3) * .60);
        _Pixel64.bevel(
          canvas,
          p,
          Rect.fromLTWH(x, y, 28, 18),
          i.isEven ? const Color(0xFFD8C7A3) : const Color(0xFFE5D8B8),
          const Color(0xFFF5E9C9),
          const Color(0xFF8A7652),
        );
        rect(x + 5, y + 6, 18, 3, const Color(0xFF8E6B35));
      }
    } else if (bossType == 'update_dragon') {
      // Patch-note dragon with progress-bar scales.
      _Pixel64.stepGlow(
        canvas,
        p,
        Offset(size.width * .52, size.height * .49),
        48,
        const Color(0xFFE87947),
      );
      final leftWing = Path()
        ..moveTo(size.width * .45, size.height * .46)
        ..lineTo(size.width * .16, size.height * .22)
        ..lineTo(size.width * .27, size.height * .60)
        ..close();
      final rightWing = Path()
        ..moveTo(size.width * .55, size.height * .46)
        ..lineTo(size.width * .84, size.height * .22)
        ..lineTo(size.width * .73, size.height * .60)
        ..close();
      p.color = const Color(0xFF8E2F2B);
      canvas.drawPath(leftWing, p);
      canvas.drawPath(rightWing, p);
      rect(size.width * .40, size.height * .30, size.width * .20, size.height * .42, const Color(0xFFB44735));
      rect(size.width * .43, size.height * .24, size.width * .14, size.height * .15, const Color(0xFFD56242));
      rect(size.width * .45, size.height * .29, 7, 7, const Color(0xFFFFE07A));
      rect(size.width * .55, size.height * .29, 7, 7, const Color(0xFFFFE07A));
      for (var i = 0; i < 4; i++) {
        rect(size.width * .44, size.height * (.44 + i * .055), size.width * .12, 5, i < 3 ? const Color(0xFFF1C75B) : const Color(0xFF5B3127));
      }
      rect(size.width * .47, size.height * .72, 6, size.height * .12, const Color(0xFF7D2A26));
      rect(size.width * .55, size.height * .72, 6, size.height * .12, const Color(0xFF7D2A26));
      // Tiny flame / update spark.
      rect(size.width * .62, size.height * .42, 9, 7, const Color(0xFFF4A13A));
      rect(size.width * .66, size.height * .39, 7, 5, const Color(0xFFFFDF78));
    } else {
      // Fallback backlog monster.
      for (var i = 0; i < 10; i++) {
        final w = size.width * (.22 + (i % 3) * .03);
        rect(size.width * (.18 + (i % 4) * .16), size.height * (.12 + i * .055), w, 13, paper);
      }
      rect(size.width * .40, size.height * .55, size.width * .20, size.height * .28, const Color(0xFF382B26));
      rect(size.width * .44, size.height * .63, 8, 8, ember);
      rect(size.width * .55, size.height * .63, 8, 8, ember);
    }
  }

  @override
  bool shouldRepaint(covariant _BossPainter oldDelegate) =>
      oldDelegate.bossType != bossType;
}
