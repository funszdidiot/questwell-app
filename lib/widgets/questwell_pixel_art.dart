import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scholar_underlayer_clip.dart';
import 'scout_underlayer_clip.dart';
import 'alchemist_underlayer_clip.dart';
import 'guardian_underlayer_clip.dart';
import 'wanderer_underlayer_clip.dart';
import 'questwell_scholar_glasses.dart';
import 'questwell_wizard_hat.dart';
import 'questwell_emerald_scarf.dart';
import 'questwell_leather_satchel.dart';
import 'questwell_brass_lantern.dart';
import 'questwell_moonstone_brooch.dart';
import 'questwell_bookshelf.dart';
import 'questwell_fern.dart';
import 'questwell_reading_chair.dart';
import 'questwell_reading_table.dart';
import 'questwell_wall_art.dart';
import 'questwell_first_journey.dart';
import 'questwell_hearth_decor.dart';
import 'questwell_contact_shadow.dart';
import 'questwell_class_emblem.dart';

class QuestwellPixelPalette {
  const QuestwellPixelPalette._();

  static List<Color> forClass(String archetype) {
    switch (archetype) {
      case 'scholar':
        return const [Color(0xFF2D1B69), Color(0xFF6B4BB8), Color(0xFFF0C96A)];
      case 'scout':
        return const [Color(0xFF173B2B), Color(0xFF477A4C), Color(0xFFD6A84B)];
      case 'alchemist':
        return const [Color(0xFF1749A0), Color(0xFFB6FF36), Color(0xFFCCDCEB)];
      case 'guardian':
        return const [Color(0xFF5C1D1D), Color(0xFFA84432), Color(0xFFF1B24A)];
      case 'wanderer':
        return const [Color(0xFF704526), Color(0xFFA77443), Color(0xFFC79450)];
      default:
        return const [Color(0xFF1A2E5A), Color(0xFF3D5A9A), Color(0xFFF1C75B)];
    }
  }
}


class QuestwellLayeredAdventurerArt extends StatelessWidget {
  const QuestwellLayeredAdventurerArt({
    super.key,
    required this.archetype,
    required this.equippedSlugs,
    this.avatarBodyType = 'neutral',
    this.showRelic = false,
  });

  static const _maleBase =
      'assets/images/questwell/avatar/base/base_male.webp';
  static const _femaleBase =
      'assets/images/questwell/avatar/base/base_female.webp';
  static const _neutralBase =
      'assets/images/questwell/avatar/base/base_neutral.webp';

  static const _scholarMale =
      'assets/images/questwell/avatar/classes/scholar/scholar_robe_male_polish_v2.webp';
  static const _scholarFemale =
      'assets/images/questwell/avatar/classes/scholar/scholar_robe_female_polish_v2.webp';
  static const _scholarNeutral =
      'assets/images/questwell/avatar/classes/scholar/scholar_robe_neutral_polish_v2.webp';

  static const _scoutMale =
      'assets/images/questwell/avatar/classes/scout/scout_coat_male_polish_v1.webp';
  static const _scoutFemale =
      'assets/images/questwell/avatar/classes/scout/scout_coat_female_polish_v1.webp';
  static const _scoutNeutral =
      'assets/images/questwell/avatar/classes/scout/scout_coat_neutral_polish_v1.webp';

  static const _alchemistMale =
      'assets/images/questwell/avatar/classes/alchemist/alchemist_coat_male_lab_v4.webp';
  static const _alchemistFemale =
      'assets/images/questwell/avatar/classes/alchemist/alchemist_coat_female_lab_v4.webp';
  static const _alchemistNeutral =
      'assets/images/questwell/avatar/classes/alchemist/alchemist_coat_neutral_lab_v4.webp';

  static const _guardianMale =
      'assets/images/questwell/avatar/classes/guardian/guardian_coat_male_v2.webp';
  static const _guardianFemale =
      'assets/images/questwell/avatar/classes/guardian/guardian_coat_female_v3.webp';
  static const _guardianNeutral =
      'assets/images/questwell/avatar/classes/guardian/guardian_coat_neutral_v2.webp';

  static const _wandererMale =
      'assets/images/questwell/avatar/classes/wanderer/wanderer_coat_male_v2.webp';
  static const _wandererFemale =
      'assets/images/questwell/avatar/classes/wanderer/wanderer_coat_female_v2.webp';
  static const _wandererNeutral =
      'assets/images/questwell/avatar/classes/wanderer/wanderer_coat_neutral_v2.webp';

  final String archetype;
  final Map<String, String> equippedSlugs;
  final String avatarBodyType;
  final bool showRelic;

  String get _baseAsset {
    switch (avatarBodyType) {
      case 'male':
        return _maleBase;
      case 'female':
        return _femaleBase;
      default:
        return _neutralBase;
    }
  }

  String? get _classOverlayAsset {
    if (archetype == 'scholar') {
      switch (avatarBodyType) {
        case 'male':
          return _scholarMale;
        case 'female':
          return _scholarFemale;
        default:
          return _scholarNeutral;
      }
    }

    if (archetype == 'scout') {
      switch (avatarBodyType) {
        case 'male':
          return _scoutMale;
        case 'female':
          return _scoutFemale;
        default:
          return _scoutNeutral;
      }
    }

    if (archetype == 'alchemist') {
      switch (avatarBodyType) {
        case 'male':
          return _alchemistMale;
        case 'female':
          return _alchemistFemale;
        default:
          return _alchemistNeutral;
      }
    }

    if (archetype == 'guardian') {
      switch (avatarBodyType) {
        case 'male':
          return _guardianMale;
        case 'female':
          return _guardianFemale;
        default:
          return _guardianNeutral;
      }
    }

    if (archetype == 'wanderer') {
      switch (avatarBodyType) {
        case 'male':
          return _wandererMale;
        case 'female':
          return _wandererFemale;
        default:
          return _wandererNeutral;
      }
    }

    return null;
  }

  Widget _assetLayer(String asset, {Widget? fallback}) {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, error, ___) {
        if (Uri.base.queryParameters['review'] == 'hearth') {
          debugPrint('Hearth asset error: $asset: $error');
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }

  // Class garment assets are authored directly on the approved 240 x 320
  // body-specific canvas. Do not apply another generic scale/offset here.
  @override
  Widget build(BuildContext context) {
    final classOverlay = _classOverlayAsset;
    final rearRevision = archetype == 'wanderer' ? 'v2' : 'v1';
    final body = ['male', 'female'].contains(avatarBodyType)
        ? avatarBodyType : 'neutral';

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          if (classOverlay != null)
            _assetLayer('assets/images/questwell/avatar/classes/$archetype/${archetype}_rear_${body}_wrap_$rearRevision.webp'),
          if (archetype == 'scholar')
            ClipPath(
              clipper: ScholarUnderlayerClipper(avatarBodyType),
              child: _assetLayer(_baseAsset),
            )
          else if (archetype == 'scout')
            ClipPath(
              clipper: ScoutUnderlayerClipper(avatarBodyType),
              child: _assetLayer(_baseAsset),
            )
          else if (archetype == 'alchemist')
            ClipPath(
              clipper: AlchemistUnderlayerClipper(avatarBodyType),
              child: _assetLayer(_baseAsset),
            )
          else if (archetype == 'guardian')
            ClipPath(
              clipper: GuardianUnderlayerClipper(avatarBodyType),
              child: _assetLayer(_baseAsset),
            )
          else if (archetype == 'wanderer')
            ClipPath(
              clipper: WandererUnderlayerClipper(avatarBodyType),
              child: _assetLayer(_baseAsset),
            )
          else
            _assetLayer(
              _baseAsset,
              fallback: CustomPaint(
                painter: _EquippedAvatarPainter(
                  archetype: archetype,
                  palette: QuestwellPixelPalette.forClass(archetype),
                  equippedSlugs: equippedSlugs,
                  showRelic: showRelic,
                  portrait: false,
                ),
              ),
            ),
          if (classOverlay != null) _assetLayer(classOverlay),
          if (equippedSlugs['back'] == QuestwellLeatherSatchel.slug) ...[
            QuestwellLeatherSatchel(bodyType: body),
            ClipPath(clipper: SatchelForearmClipper(body), child: _assetLayer(_baseAsset)),
            if (classOverlay != null)
              ClipPath(clipper: SatchelForearmClipper(body), child: _assetLayer(classOverlay)),
          ],
          if (equippedSlugs['hands'] == QuestwellBrassLantern.slug) ...[
            QuestwellBrassLantern(bodyType: body),
            ClipPath(clipper: LanternHandClipper(body), child: _assetLayer(_baseAsset)),
            if (classOverlay != null)
              ClipPath(clipper: LanternHandClipper(body), child: _assetLayer(classOverlay)),
          ],
          if (equippedSlugs['accessory'] == QuestwellMoonstoneBrooch.slug)
            QuestwellMoonstoneBrooch(bodyType: body),
          if (equippedSlugs['neck'] == 'emerald-scholar-scarf')
            QuestwellEmeraldScarf(bodyType: body),
          if (equippedSlugs['face'] == 'round-scholar-glasses')
            QuestwellScholarGlasses(bodyType: body),
          if (equippedSlugs['head'] == 'tiny-wizard-hat')
            QuestwellWizardHat(bodyType: body),
        ],
      ),
    );
  }
}

class QuestwellBrandWordmark extends StatelessWidget {
  const QuestwellBrandWordmark({
    super.key,
    this.compact = false,
    this.subtitle = 'Small wins. Real momentum.',
    this.showSubtitle = true,
  });

  final bool compact;
  final String subtitle;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUESTWELL',
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: GoogleFonts.cinzelDecorative(
            fontSize: compact ? 24 : 30,
            fontWeight: FontWeight.w900,
            height: .95,
            letterSpacing: -.5,
            color: const Color(0xFFFFE7A4),
            shadows: const [
              Shadow(
                color: Color(0xFF5A3419),
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
              Shadow(
                color: Color(0xAAE87947),
                offset: Offset(0, 0),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        if (showSubtitle) ...[
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.roboto(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFB9D8EA),
            letterSpacing: .05,
          ),
        ),
        ],
      ],
    );
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
                    style: GoogleFonts.roboto(
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
    this.avatarBodyType = 'neutral',
    this.equippedSlugs = const {},
    this.showRelic = false,
    this.showAvatar = true,
  });

  static const _environmentAsset =
      'assets/images/questwell/hearth/hearth_environment_v2.webp';

  final double height;
  final String archetype;
  final String avatarBodyType;
  final Map<String, String> equippedSlugs;
  final bool showRelic;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final palette = QuestwellPixelPalette.forClass(archetype);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 8), child: Row(children: [
        Expanded(child: Text('THE HEARTH', style: GoogleFonts.pressStart2p(
          fontSize: 8, color: const Color(0xFFFFD978), height: 1.4))),
        QuestwellClassEmblem(archetype: archetype, size: 22),
        const SizedBox(width: 6),
        Text(archetype.toUpperCase(), style: GoogleFonts.pressStart2p(
          fontSize: 7, color: const Color(0xFFF6E5B8), height: 1.4)),
        if (showRelic) const Padding(padding: EdgeInsets.only(left: 6),
          child: Icon(Icons.star, size: 14, color: Color(0xFFFFD978))),
      ])),
      QuestwellPixelFrame(
      key: const ValueKey('hearth-room-bounds'),
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sceneWidth = constraints.maxWidth;
          final sceneHeight = constraints.maxHeight;
          final compact = sceneWidth < 430;

          // Keep the authored 3:4 canvas ratio, so BoxFit.contain cannot
          // silently shrink the character inside a narrow mobile rectangle.
          final avatarHeight = math.min(sceneHeight * .76, sceneWidth * .62 * 4 / 3);
          final avatarWidth = avatarHeight * 3 / 4;
          final avatarLeft = (sceneWidth - avatarWidth) / 2;
          final footY = sceneHeight * .88;
          // Frozen boots end near row 310 on the shared 320 px canvas.
          final avatarTop = footY - avatarHeight * 310 / 320;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  _environmentAsset,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, .04),
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF27344A),
                          Color(0xFF1A1718),
                          Color(0xFF0E0B0D),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0x202A1920),
                        const Color(0x0CDB9855),
                        const Color(0x12B8753E),
                        const Color(0x24261913),
                      ],
                      stops: const [0, .34, .70, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -sceneWidth * .08,
                top: sceneHeight * .28,
                width: sceneWidth * .60,
                height: sceneHeight * .66,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-.45, .05),
                        radius: .95,
                        colors: [
                          const Color(0x41FFB84C),
                          const Color(0x1DE87947),
                          const Color(0x00E87947),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _HearthAtmospherePainter(
                      accent: palette.last,
                      compact: compact,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: avatarLeft - sceneWidth * .06,
                top: footY - sceneHeight * .09,
                width: avatarWidth + sceneWidth * .12,
                height: sceneHeight * .18,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: .78,
                        colors: [
                          palette.last.withValues(alpha: .11),
                          const Color(0x12E87947),
                          const Color(0x00E87947),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (equippedSlugs['wall_art'] == QuestwellWallArt.slug)
                QuestwellHearthDecor.wallArtPositioned(
                  slug: QuestwellWallArt.slug, side: 'wall_center', scene: Size(sceneWidth, sceneHeight)),
              for (final side in ['wall_left', 'wall_right'])
                if (equippedSlugs['wall_art:$side'] case final String art)
                  if (QuestwellWallArt.isSide(art))
                    QuestwellHearthDecor.wallArtPositioned(
                      slug: art, side: side, scene: Size(sceneWidth, sceneHeight)),
              for (final slot in QuestwellHearthDecor.backToFront(equippedSlugs))
                if ((equippedSlugs['room:$slot'] ?? (slot == 'right' ? equippedSlugs['room'] : null)) case final String slug)
                  if (slug == QuestwellBookshelf.slug || slug == QuestwellFern.slug || slug == QuestwellReadingChair.slug || slug == QuestwellReadingTable.slug)
                    QuestwellHearthDecor.positioned(
                      slug: slug, slot: slot, equipment: equippedSlugs,
                      scene: Size(sceneWidth, sceneHeight),
                    ),
              for (final surface in ['mantel', 'bookshelf_top'])
                if (equippedSlugs['room:$surface'] == QuestwellFirstJourney.slug &&
                  (surface == 'mantel' || equippedSlugs['room:left'] == QuestwellBookshelf.slug || equippedSlugs['room:right'] == QuestwellBookshelf.slug))
                  QuestwellHearthDecor.trophyPositioned(slot: surface,
                    scene: Size(sceneWidth, sceneHeight), equipment: equippedSlugs),
              if (showAvatar) Positioned(
                key: const ValueKey('hearth-contact-shadow'),
                left: avatarLeft,
                top: avatarTop,
                width: avatarWidth,
                height: avatarHeight,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: QuestwellContactShadowPainter(avatarBodyType)),
                ),
              ),
              if (showAvatar) Positioned(
                key: const ValueKey('hearth-avatar-bounds'),
                left: avatarLeft,
                top: avatarTop,
                width: avatarWidth,
                height: avatarHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -.15),
                          radius: .72,
                          colors: [
                            palette.last.withValues(alpha: .22),
                            palette[1].withValues(alpha: .08),
                            const Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                    QuestwellLayeredAdventurerArt(
                      archetype: archetype,
                      avatarBodyType: avatarBodyType,
                      equippedSlugs: equippedSlugs,
                      showRelic: showRelic,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0x774A2D1B),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    ]);
  }
}

class _HearthAtmospherePainter extends CustomPainter {
  const _HearthAtmospherePainter({
    required this.accent,
    required this.compact,
  });

  final Color accent;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;

    // Opaque woven fabric follows the room's floor perspective.
    Offset point(double u, double v) {
      final halfWidth = .17 + .11 * v;
      return Offset(size.width * (.5 + (u - .5) * 2 * halfWidth),
          size.height * (.69 + .26 * v));
    }
    Path panel(double inset) => Path()
      ..addPolygon([point(inset, inset), point(1 - inset, inset),
        point(1 - inset, 1 - inset), point(inset, 1 - inset)], true);
    final rug = panel(0);
    p.color = const Color(0xFF492C30);
    canvas.drawPath(rug, p);
    p.color = const Color(0xFFB58E5F);
    canvas.drawPath(panel(.045), p);
    p.color = const Color(0xFF70434A);
    canvas.drawPath(panel(.075), p);
    p.color = const Color(0xFFB58E5F);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1;
    canvas.drawPath(panel(.105), p);
    p.style = PaintingStyle.fill;

    // Fine horizontal yarn rows stay clipped to the fabric.
    canvas.save();
    canvas.clipPath(panel(.115));
    p.color = const Color(0xFF7B4E54);
    p.strokeWidth = 1;
    for (double v = .13; v < .9; v += .045) {
      canvas.drawLine(point(.1, v), point(.9, v), p);
    }
    canvas.restore();
    // Small woven border stitches widen naturally toward the foreground.
    p.color = const Color(0xFFD2B17F);
    for (double u = .12; u < .9; u += .065) {
      for (final v in [.058, .94]) {
        canvas.drawLine(point(u, v), point(u + .018, v), p);
      }
    }

    // Dark edge strips work as a pixel vignette and keep attention on the
    // Adventurer and the warm room center.
    p.color = const Color(0x24000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * .035, size.height), p);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .965, 0, size.width * .035, size.height),
      p,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .94, size.width, size.height * .06),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _HearthAtmospherePainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.compact != compact;
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
    this.archetype = 'wanderer',
    this.equippedSlugs = const {},
  });

  final double height;
  final bool clear;
  final String archetype;
  final Map<String, String> equippedSlugs;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF17151A),
      child: CustomPaint(
        painter: _QuestBoardPainter(
          clear: clear,
          archetype: archetype,
          equippedSlugs: equippedSlugs,
        ),
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
    this.avatarBodyType = 'neutral',
    this.height = 210,
    this.artHeightFactor = .88,
    this.showRelic = false,
  });

  final String archetype;
  final Map<String, String> equippedSlugs;
  final String avatarBodyType;
  final double height;
  final double artHeightFactor;
  final bool showRelic;

  @override
  Widget build(BuildContext context) {
    final palette = QuestwellPixelPalette.forClass(archetype);
    return QuestwellPixelFrame(
      height: height,
      background: palette.first,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF162437),
                  Color(0xFF101923),
                  Color(0xFF241914),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: .90,
              heightFactor: equippedSlugs['head'] == 'tiny-wizard-hat'
                  ? math.min(artHeightFactor, .88) : artHeightFactor,
              alignment: Alignment.bottomCenter,
              child: QuestwellLayeredAdventurerArt(
                archetype: archetype,
                avatarBodyType: avatarBodyType,
                equippedSlugs: equippedSlugs,
                showRelic: showRelic,
              ),
            ),
          ),
          if (showRelic)
            Positioned(
              left: 12,
              top: 12,
              child: QuestwellRelicPixelArt(
                archetype: archetype,
                size: 46,
              ),
            ),
        ],
      ),
    );
  }
}

class QuestwellEquippedAvatarSprite extends StatelessWidget {
  const QuestwellEquippedAvatarSprite({
    super.key,
    required this.archetype,
    required this.equippedSlugs,
    this.avatarBodyType = 'neutral',
    this.width = 116,
    this.height = 150,
  });

  final String archetype;
  final Map<String, String> equippedSlugs;
  final String avatarBodyType;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: QuestwellLayeredAdventurerArt(
        archetype: archetype,
        avatarBodyType: avatarBodyType,
        equippedSlugs: equippedSlugs,
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
    if (slug == QuestwellFirstJourney.slug) {
      return SizedBox.square(dimension: size, child: const QuestwellFirstJourney());
    }
    // Inventory and Market share one retro icon treatment. Equipped avatar
    // artwork is deliberately separate and keeps its approved detail.
    const palette = [Color(0xFF202B35), Color(0xFF81BFAE), Color(0xFFD0A665)];
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
    this.renderAvatar = true,
  });
  final String archetype;
  final List<Color> palette;
  final Map<String, String> equippedSlugs;
  final bool showRelic;
  final bool renderAvatar;

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

    if (renderAvatar) {
      // Legacy fallback used only where the scene painter is explicitly asked
      // to own the character. The Hearth itself now composes a higher-detail,
      // asset-driven Adventurer over a character-free environment.
      final avatarSize = Size(size.width * .235, size.height * .50);
      canvas.save();
      canvas.translate(size.width * .405, size.height * .315);
      _EquippedAvatarPainter(
        archetype: archetype,
        palette: palette,
        equippedSlugs: equippedSlugs,
        showRelic: showRelic,
        portrait: false,
      ).paint(canvas, avatarSize);
      canvas.restore();
    }

    // Warm/cool light pools are environmental, not painted onto the avatar.
    // The layered Adventurer sits between these sources in the Hearth stack.
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .43, size.height * .54),
      size.height * .11,
      const Color(0xFFE87947),
    );
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .66, size.height * .42),
      size.height * .09,
      const Color(0xFF5C8FBE),
    );

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
      oldDelegate.showRelic != showRelic ||
      oldDelegate.renderAvatar != renderAvatar;
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
  _QuestBoardPainter({
    required this.clear,
    required this.archetype,
    required this.equippedSlugs,
  });

  final bool clear;
  final String archetype;
  final Map<String, String> equippedSlugs;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    final palette = QuestwellPixelPalette.forClass(archetype);

    void r(double x, double y, double w, double h, Color color) =>
        _Pixel64.rect(canvas, p, x, y, w, h, color);

    // Deep room backdrop with layered masonry and timber.
    r(0, 0, size.width, size.height, const Color(0xFF0C1522));
    r(0, 0, size.width, size.height * .70, const Color(0xFF13243A));
    _Pixel64.dither(
      canvas,
      p,
      Rect.fromLTWH(0, 0, size.width, size.height * .70),
      const Color(0xFF1D3550),
      11,
    );
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(0, size.height * .69, size.width, size.height * .31),
      const Color(0xFF3D291D),
      const Color(0xFF6C4930),
      const Color(0xFF20150F),
    );

    // Overhead beam and side shelves.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(0, 0, size.width, size.height * .10),
      const Color(0xFF4E301F),
      const Color(0xFF805238),
      const Color(0xFF24170F),
    );
    for (final x in [size.width * .03, size.width * .86]) {
      _Pixel64.bevel(
        canvas,
        p,
        Rect.fromLTWH(x, size.height * .12, size.width * .11, size.height * .46),
        const Color(0xFF4A2E20),
        const Color(0xFF724B31),
        const Color(0xFF23160F),
      );
    }

    // Books and jars create environment density.
    final shelfColors = [
      const Color(0xFF7A3246),
      const Color(0xFF2C6B5C),
      const Color(0xFF4A6FA4),
      const Color(0xFFA57135),
      const Color(0xFF6B4B82),
    ];
    for (var side = 0; side < 2; side++) {
      final baseX = side == 0 ? size.width * .045 : size.width * .875;
      for (var row = 0; row < 3; row++) {
        final y = size.height * (.18 + row * .12);
        r(baseX, y + size.height * .075, size.width * .07, 3, const Color(0xFF9B6B41));
        for (var i = 0; i < 4; i++) {
          final bx = baseX + i * size.width * .017;
          final bh = size.height * (.045 + ((row + i) % 3) * .010);
          r(bx, y + size.height * .025, size.width * .013, bh,
              shelfColors[(row + i) % shelfColors.length]);
          r(bx + 1, y + size.height * .028, 1, math.max(2, bh - 4),
              const Color(0x33FFFFFF));
        }
      }
    }

    // Lantern pools.
    for (final x in [size.width * .16, size.width * .82]) {
      _Pixel64.stepGlow(
        canvas,
        p,
        Offset(x, size.height * .20),
        size.height * .12,
        const Color(0xFFFFC85A),
      );
      r(x - 7, size.height * .12, 14, size.height * .15, const Color(0xFF9E672B));
      r(x - 4, size.height * .145, 8, size.height * .085, const Color(0xFFFFE294));
    }

    // Main quest board, thick carved frame + parchment center.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .15, size.height * .12, size.width * .70, size.height * .60),
      const Color(0xFF5B3825),
      const Color(0xFF8B5C39),
      const Color(0xFF2A1A12),
    );
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .18, size.height * .16, size.width * .64, size.height * .52),
      const Color(0xFF9B6D3E),
      const Color(0xFFC28F56),
      const Color(0xFF5B3B24),
    );
    r(size.width * .205, size.height * .19, size.width * .59, size.height * .46,
        const Color(0xFFD9C7A1));

    // Aged parchment shading.
    _Pixel64.dither(
      canvas,
      p,
      Rect.fromLTWH(size.width * .205, size.height * .19, size.width * .59, size.height * .46),
      const Color(0x22745431),
      8,
    );
    r(size.width * .22, size.height * .205, size.width * .56, 3, const Color(0xFFB99059));
    r(size.width * .22, size.height * .62, size.width * .56, 3, const Color(0xFF8D6740));

    if (clear) {
      r(size.width * .36, size.height * .30, size.width * .28, size.height * .22,
          const Color(0xFFE6D8B8));
      r(size.width * .40, size.height * .36, size.width * .19, 3,
          const Color(0xFF9C7850));
      r(size.width * .40, size.height * .42, size.width * .15, 3,
          const Color(0xFF9C7850));
    } else {
      final papers = [
        const Color(0xFFE8D9B8),
        const Color(0xFFD8C6A0),
        const Color(0xFFF0E1C0),
        const Color(0xFFCFB991),
      ];
      for (var i = 0; i < 4; i++) {
        final x = size.width * (.25 + (i % 2) * .27);
        final y = size.height * (.25 + (i ~/ 2) * .18);
        final w = size.width * .20;
        final h = size.height * .14;
        _Pixel64.bevel(
          canvas,
          p,
          Rect.fromLTWH(x, y, w, h),
          papers[i],
          const Color(0xFFF3E8CF),
          const Color(0xFFB49C73),
        );
        r(x + w * .13, y + h * .30, w * .65, 3, const Color(0xFF8F7652));
        r(x + w * .13, y + h * .52, w * .48, 3, const Color(0xFF8F7652));
        p.color = i.isEven ? const Color(0xFFB94A3A) : const Color(0xFF4C6FA9);
        canvas.drawCircle(Offset(x + w * .5, y + 3), 4, p);
      }
    }

    // Ivy and leaves tie the Quest Board to the Hearth art language.
    for (var i = 0; i < 16; i++) {
      final x = size.width * (.10 + ((i * 17) % 80) / 100);
      final y = size.height * (.07 + ((i * 11) % 10) / 100);
      r(x, y, 5, 8, i.isEven ? const Color(0xFF2F6B3F) : const Color(0xFF4C8C4D));
      if (i % 3 == 0) r(x + 4, y + 3, 4, 6, const Color(0xFF6FAE58));
    }

    // Integrated live Adventurer at the board, using the same modular renderer.
    final avatarSize = Size(size.width * .18, size.height * .47);
    canvas.save();
    canvas.translate(size.width * .035, size.height * .42);
    _EquippedAvatarPainter(
      archetype: archetype,
      palette: palette,
      equippedSlugs: equippedSlugs,
      showRelic: false,
      portrait: false,
    ).paint(canvas, avatarSize);
    canvas.restore();

    // Desk clutter and quill in foreground.
    _Pixel64.bevel(
      canvas,
      p,
      Rect.fromLTWH(size.width * .66, size.height * .77, size.width * .27, size.height * .12),
      const Color(0xFF58351F),
      const Color(0xFF8A5A35),
      const Color(0xFF28180F),
    );
    r(size.width * .70, size.height * .79, size.width * .08, size.height * .055,
        const Color(0xFFD7C7A6));
    r(size.width * .80, size.height * .79, 4, size.height * .09,
        const Color(0xFFE7D9B6));
    r(size.width * .79, size.height * .77, 10, 3, const Color(0xFFF1C75B));

    // Warm floor bounce and small highlight pixels.
    _Pixel64.stepGlow(
      canvas,
      p,
      Offset(size.width * .50, size.height * .88),
      size.height * .13,
      const Color(0xFFE87947),
    );
    for (var i = 0; i < 18; i++) {
      final x = size.width * (.07 + ((i * 29) % 86) / 100);
      final y = size.height * (.72 + ((i * 17) % 20) / 100);
      r(x, y, 2, 2, i.isEven ? const Color(0xFF9B6A43) : const Color(0xFFD6A84B));
    }
  }

  @override
  bool shouldRepaint(covariant _QuestBoardPainter oldDelegate) =>
      oldDelegate.clear != clear ||
      oldDelegate.archetype != archetype ||
      oldDelegate.equippedSlugs != equippedSlugs;
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
  String? get head => equippedSlugs['head'];
  String? get face => equippedSlugs['face'];
  String? get neck => equippedSlugs['neck'];
  String? get chest => equippedSlugs['chest'];
  String? get hands => equippedSlugs['hands'];
  String? get legs => equippedSlugs['legs'];
  String? get feet => equippedSlugs['feet'];
  String? get back => equippedSlugs['back'];
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
    final outfitSlug = chest ?? outfit ?? '';
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
    final feetSlug = feet ?? '';
    final legacyBoots = outfitSlug.contains('pathfinder-boots');
    final pathfinderBoots =
        feetSlug.contains('pathfinder-boots') || legacyBoots;
    final bootColor =
        pathfinderBoots ? const Color(0xFF6B4229) : boot;
    final bootHi =
        pathfinderBoots ? const Color(0xFFA87843) : const Color(0xFF41302A);
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

    // Modular equipment layers aligned to the canonical body anchors.
    // Each slot can coexist with the others so users can equip/unequip
    // individual pieces without baking them into the base character.
    final legacyAccessory = accessory ?? '';
    final faceSlug = face ?? legacyAccessory;
    final headSlug = head ?? legacyAccessory;
    final neckSlug = neck ?? '';
    final backSlug = back ?? legacyAccessory;
    final handsSlug = hands ?? legacyAccessory;

    if (faceSlug.contains('round-scholar-glasses')) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = math.max(2.0, unit * 1.5);
      p.color = const Color(0xFF24272D);
      canvas.drawRect(
        Rect.fromLTWH(ox + 41 * unit, oy + 29 * unit, 10 * unit, 8 * unit),
        p,
      );
      canvas.drawRect(
        Rect.fromLTWH(ox + 56 * unit, oy + 29 * unit, 10 * unit, 8 * unit),
        p,
      );
      canvas.drawLine(
        Offset(ox + 51 * unit, oy + 33 * unit),
        Offset(ox + 56 * unit, oy + 33 * unit),
        p,
      );
      canvas.drawLine(
        Offset(ox + 40 * unit, oy + 31 * unit),
        Offset(ox + 36 * unit, oy + 29 * unit),
        p,
      );
      canvas.drawLine(
        Offset(ox + 66 * unit, oy + 31 * unit),
        Offset(ox + 70 * unit, oy + 29 * unit),
        p,
      );
      p.style = PaintingStyle.fill;
      pr(43, 31, 6, 2, const Color(0xFF8796A3).withValues(alpha: .42));
      pr(58, 31, 6, 2, const Color(0xFF8796A3).withValues(alpha: .42));
    }

    if (headSlug.contains('tiny-wizard-hat')) {
      pr(35, 12, 37, 5, const Color(0xFF2C1B38));
      pr(42, 3, 23, 12, const Color(0xFF5E3A7D));
      pr(50, 2, 8, 5, const Color(0xFF7851A1));
      pr(53, 5, 4, 4, gold);
    }

    if (neckSlug.contains('emerald-scholar-scarf')) {
      pr(34, 43, 38, 7, const Color(0xFF173C34));
      pr(37, 44, 31, 5, const Color(0xFF2B6755));
      pr(62, 47, 9, 28, const Color(0xFF1E5144));
      pr(64, 49, 5, 23, const Color(0xFF3C7C65));
      pr(64, 69, 7, 3, const Color(0xFFD6A84B));
      pr(65, 73, 2, 5, const Color(0xFFD6A84B));
      pr(69, 73, 2, 5, const Color(0xFFD6A84B));
    }

    if (backSlug.contains('satchel')) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = math.max(2.0, unit * 2);
      p.color = const Color(0xFF4A2B1C);
      canvas.drawLine(
        Offset(ox + 36 * unit, oy + 47 * unit),
        Offset(ox + 67 * unit, oy + 84 * unit),
        p,
      );
      p.style = PaintingStyle.fill;
      pr(62, 72, 20, 20, const Color(0xFF6A3C24));
      pr(64, 74, 16, 5, const Color(0xFF9A6035));
      pr(68, 80, 6, 5, gold);
      pr(65, 87, 14, 3, const Color(0xFF3B2419));
    }

    if (handsSlug.contains('grimoire')) {
      pr(73, 62, 20, 23, const Color(0xFF512467));
      pr(76, 65, 3, 17, gold);
      pr(82, 67, 8, 2, paper);
      pr(82, 72, 7, 2, paper);
      pr(82, 77, 6, 2, paper);
    } else if (handsSlug.contains('compass')) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = math.max(2.0, unit * 1.4);
      p.color = gold;
      canvas.drawCircle(
        Offset(ox + 54 * unit, oy + 65 * unit),
        6 * unit,
        p,
      );
      canvas.drawLine(
        Offset(ox + 54 * unit, oy + 60 * unit),
        Offset(ox + 57 * unit, oy + 68 * unit),
        p,
      );
      p.style = PaintingStyle.fill;
    } else if (handsSlug.contains('phial') ||
        handsSlug.contains('tonic')) {
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

    if (slug == 'starter-business-suit') {
      final unit = size.width / 16;
      void pixel(double x, double y, double w, double h, Color color) =>
          rect(x * unit, y * unit, w * unit, h * unit, color);
      const charcoal = Color(0xFF515563);
      const shadow = Color(0xFF343743);
      const lapel = Color(0xFF777D89);
      // A jacket silhouette with separate sleeves, stepped lapels and a tie.
      pixel(4, 3, 8, 2, charcoal);
      pixel(3, 5, 10, 5, charcoal);
      pixel(2, 6, 2, 6, charcoal);
      pixel(12, 6, 2, 6, shadow);
      pixel(4, 10, 8, 3, charcoal);
      pixel(10, 5, 2, 8, shadow);
      pixel(6, 3, 4, 4, paper);
      pixel(7, 7, 2, 3, paper);
      pixel(5, 3, 1, 3, lapel);
      pixel(6, 6, 1, 2, lapel);
      pixel(7, 8, 1, 2, lapel);
      pixel(10, 3, 1, 3, lapel);
      pixel(9, 6, 1, 2, lapel);
      pixel(8, 8, 1, 2, lapel);
      pixel(7, 4, 2, 1, gold);
      pixel(7, 5, 1, 3, gold);
      pixel(7, 10, 1, 1, gold);
      pixel(9, 10, 2, 1, lapel);
      pixel(2, 12, 2, 1, paper);
      pixel(12, 12, 2, 1, paper);
    } else if (slug == 'round-scholar-glasses') {
      // Stepped round rims, a bridge, and temples on the same 16-unit grid.
      final unit = size.width / 16;
      void pixel(double x, double y, double w, double h, Color color) =>
          rect(x * unit, y * unit, w * unit, h * unit, color);
      for (final x in [2.0, 9.0]) {
        pixel(x + 1, 5, 3, 1, gold);
        pixel(x, 6, 1, 4, gold);
        pixel(x + 4, 6, 1, 4, gold);
        pixel(x + 1, 10, 3, 1, gold);
        pixel(x + 1, 6, 3, 4, const Color(0xFF314753));
        pixel(x + 1, 6, 1, 1, paper);
      }
      pixel(7, 7, 2, 1, gold);
      pixel(1, 6, 1, 1, gold);
      pixel(14, 6, 1, 1, gold);
    } else if (slug == 'tiny-wizard-hat') {
      final unit = size.width / 16;
      void pixel(double x, double y, double w, double h, Color color) =>
          rect(x * unit, y * unit, w * unit, h * unit, color);
      const midnight = Color(0xFF444366);
      const shade = Color(0xFF302F4B);
      pixel(8, 2, 3, 1, midnight);
      pixel(7, 3, 3, 2, midnight);
      pixel(6, 5, 4, 2, midnight);
      pixel(5, 7, 6, 3, midnight);
      pixel(9, 5, 1, 2, shade);
      pixel(9, 7, 2, 3, shade);
      pixel(5, 9, 6, 1, gold);
      pixel(3, 10, 10, 2, midnight);
      pixel(2, 12, 12, 1, shade);
      pixel(6, 10, 1, 1, paper);
    } else if (slug == 'emerald-scholar-scarf') {
      final unit = size.width / 16;
      void pixel(double x, double y, double w, double h, Color color) =>
          rect(x * unit, y * unit, w * unit, h * unit, color);
      const emerald = Color(0xFF27836A);
      const shade = Color(0xFF185541);
      pixel(3, 3, 10, 3, shade);
      pixel(3, 4, 9, 2, emerald);
      pixel(4, 6, 4, 7, emerald);
      pixel(9, 6, 3, 5, shade);
      pixel(4, 11, 4, 1, gold);
      pixel(9, 9, 3, 1, gold);
      pixel(4, 13, 1, 1, emerald);
      pixel(6, 13, 1, 1, emerald);
      pixel(9, 11, 1, 1, shade);
      pixel(11, 11, 1, 1, shade);
    } else if (slug.contains('grimoire') || slug.contains('seal')) {
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
    } else if (QuestwellWallArt.isSide(slug)) {
      final u = size.width / 16;
      void px(double x, double y, double w, double h, Color c) => rect(x*u,y*u,w*u,h*u,c);
      px(3,1,10,14,const Color(0xFF70432D)); px(4,2,8,12,gold);
      final botanical = slug == QuestwellWallArt.fern;
      px(5,3,6,10,botanical ? paper : const Color(0xFF152D54));
      if (botanical) {
        const leaf = Color(0xFF397443);
        px(7,4,1,8,leaf);
        for (final y in [5.0,7.0,9.0]) { px(6,y,1,1,leaf); px(8,y-1,2,1,leaf); }
      } else {
        px(6,4,3,4,gold); px(7,4,3,3,const Color(0xFF152D54));
        px(9,9,1,1,gold); px(7,10,1,1,gold); px(6,12,1,1,gold);
      }
    } else if (slug == QuestwellWallArt.slug) {
      final u = size.width / 16;
      void px(double x, double y, double w, double h, Color c) => rect(x*u,y*u,w*u,h*u,c);
      px(1,2,14,12,const Color(0xFF70432D));
      px(2,3,12,10,gold); px(3,4,10,8,const Color(0xFF233F62));
      px(9,5,2,2,paper);
      px(4,7,2,5,const Color(0xFF244C43)); px(3,9,4,3,const Color(0xFF244C43));
      px(8,9,4,3,const Color(0xFF70432D)); px(9,8,2,1,gold); px(9,10,1,1,gold);
    } else if (slug == QuestwellReadingTable.slug) {
      final u = size.width / 16;
      void px(double x, double y, double w, double h, Color c) => rect(x*u,y*u,w*u,h*u,c);
      const wood = Color(0xFF74452C);
      const edge = Color(0xFFB77D46);
      px(2,8,12,2,wood); px(2,8,12,1,edge);
      px(3,10,2,5,wood); px(11,10,2,5,wood);
      px(4,10,1,2,edge); px(12,10,1,2,edge);
      px(3,6,6,2,const Color(0xFF355B41));
      px(4,4,6,2,const Color(0xFF873C3A));
      px(4,5,5,1,paper); px(3,7,5,1,paper);
      px(11,6,3,1,gold); px(12,3,1,3,paper);
      px(12,1,1,2,const Color(0xFFFFC45B));
    } else if (slug == QuestwellReadingChair.slug) {
      final u = size.width / 16;
      void px(double x, double y, double w, double h, Color c) => rect(x*u,y*u,w*u,h*u,c);
      const dark = Color(0xFF4B2026);
      const wine = Color(0xFF883643);
      const light = Color(0xFFB45155);
      const wood = Color(0xFF71482F);
      px(4,2,8,8,dark); px(5,2,6,1,light); px(5,3,6,6,wine);
      px(3,8,10,5,dark); px(4,9,8,3,wine); px(4,9,8,1,light);
      px(2,7,3,5,wine); px(11,7,3,5,wine);
      px(2,7,3,1,light); px(11,7,3,1,light);
      px(3,12,10,1,wood); px(3,13,2,2,wood); px(11,13,2,2,wood);
      for (final x in [6.0,9.0]) px(x,5,1,1,dark);
      for (final x in [3.0,12.0]) { px(x,8,1,1,gold); px(x,10,1,1,gold); }
    } else if (slug == QuestwellFern.slug) {
      final u = size.width / 16;
      void px(double x, double y, double w, double h, Color c) => rect(x*u,y*u,w*u,h*u,c);
      px(5,10,6,4,const Color(0xFF95692E));
      px(4,10,8,1,gold); px(6,14,4,1,gold);
      for (final x in [3.0,5.0,7.0,9.0,11.0]) {
        px(x,4+(x-7).abs()/2,2,5,const Color(0xFF315A39));
        px(x-1,3+(x-7).abs()/2,2,2,const Color(0xFF739B43));
      }
      px(7,2,2,9,const Color(0xFF88A751));
    } else if (slug == QuestwellBookshelf.slug) {
      final unit = size.width / 16;
      void pixel(double x, double y, double w, double h, Color color) =>
          rect(x * unit, y * unit, w * unit, h * unit, color);
      const walnut = Color(0xFF795032);
      const edge = Color(0xFFB37C45);
      pixel(2, 2, 12, 12, walnut);
      pixel(3, 3, 10, 10, const Color(0xFF281B18));
      for (final y in [2.0, 6.0, 10.0, 13.0]) {
        pixel(2, y, 12, 1, edge);
      }
      for (final y in [3.0, 7.0, 11.0]) {
        pixel(4, y, 2, 3, const Color(0xFF315A49));
        pixel(7, y, 2, 3, const Color(0xFF8B3F34));
        pixel(10, y, 2, 3, const Color(0xFF3D526D));
        for (final x in [4.0, 7.0, 10.0]) pixel(x, y + 1, 2, .4, gold);
      }
      pixel(2, 2, 1, 1, gold);
      pixel(13, 2, 1, 1, gold);
      pixel(3, 14, 2, 1, walnut);
      pixel(11, 14, 2, 1, walnut);
    } else if (slug == QuestwellMoonstoneBrooch.slug) {
      final unit = size.width / 16;
      void pixel(double x, double y, double w, double h, Color color) =>
          rect(x * unit, y * unit, w * unit, h * unit, color);
      const blue = Color(0xFF89BEE6);
      const deep = Color(0xFF456B9B);
      const ice = Color(0xFFD9EDFA);
      pixel(6, 2, 4, 1, gold);
      pixel(5, 3, 6, 1, gold);
      pixel(4, 4, 8, 7, gold);
      pixel(5, 11, 6, 1, gold);
      pixel(6, 12, 4, 1, gold);
      pixel(7, 13, 2, 1, gold);
      pixel(6, 3, 4, 9, deep);
      pixel(5, 5, 6, 5, deep);
      pixel(6, 4, 3, 7, blue);
      pixel(9, 5, 1, 4, blue);
      pixel(6, 4, 2, 2, ice);
      pixel(7, 8, 2, 2, ice);
      pixel(2, 5, 1, 4, gold);
      pixel(3, 8, 1, 3, gold);
      pixel(13, 5, 1, 4, gold);
      pixel(12, 8, 1, 3, gold);
    } else if (slug == 'brass-lantern') {
      // Match the inventory's 16-unit grid; equipped art stays illustrated.
      final unit = size.width / 16;
      void pixel(double x, double y, double w, double h, Color color) =>
          rect(x * unit, y * unit, w * unit, h * unit, color);
      const brass = Color(0xFFB47A2B);
      const shade = Color(0xFF79502A);
      const amber = Color(0xFFE99D32);
      const flame = Color(0xFFFFE5A1);
      pixel(6, 1, 4, 1, gold);
      pixel(5, 2, 1, 3, brass);
      pixel(10, 2, 1, 3, brass);
      pixel(6, 4, 4, 1, gold);
      pixel(7, 4, 2, 1, teal);
      pixel(4, 5, 8, 1, gold);
      pixel(3, 6, 10, 1, shade);
      pixel(4, 7, 8, 6, brass);
      pixel(5, 7, 6, 5, amber);
      pixel(5, 7, 1, 5, gold);
      pixel(10, 7, 1, 5, shade);
      pixel(7, 8, 1, 2, flame);
      pixel(7, 10, 2, 2, paper);
      pixel(3, 13, 10, 1, gold);
      pixel(4, 14, 8, 1, shade);
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
