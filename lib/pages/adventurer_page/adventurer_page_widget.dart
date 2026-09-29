import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_pixel_art.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdventurerPageWidget extends StatefulWidget {
  const AdventurerPageWidget({super.key});

  static String routeName = 'AdventurerPage';
  static String routePath = '/adventurer';

  @override
  State<AdventurerPageWidget> createState() => _AdventurerPageWidgetState();
}

class _AdventurerPageWidgetState extends State<AdventurerPageWidget> {
  static const bool _richEquipmentLayersReady = false;

  late Future<QuestwellCosmeticsSnapshot> _future;
  String? _busyCosmeticId;
  bool _savingArchetype = false;
  bool _savingBodyType = false;
  bool _claimingMastery = false;
  String? _avatarBodyOverride;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = QuestwellCosmeticService.load();
  }

  Future<void> _equip(QuestwellCosmetic cosmetic) async {
    if (!_richEquipmentLayersReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment visuals are being upgraded. Your item stays owned.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_busyCosmeticId != null) return;
    setState(() => _busyCosmeticId = cosmetic.id);

    try {
      await QuestwellCosmeticService.equip(cosmetic.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cosmetic.name} equipped.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(_refresh);
    } finally {
      if (mounted) setState(() => _busyCosmeticId = null);
    }
  }

  Future<void> _unequip(QuestwellCosmetic cosmetic) async {
    if (_busyCosmeticId != null) return;
    setState(() => _busyCosmeticId = cosmetic.id);

    try {
      await QuestwellCosmeticService.unequip(cosmetic.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cosmetic.name} unequipped.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(_refresh);
    } finally {
      if (mounted) setState(() => _busyCosmeticId = null);
    }
  }

  String _archetypeLabel(String value) {
    switch (value) {
      case 'scholar':
        return 'Scholar';
      case 'scout':
        return 'Scout';
      case 'alchemist':
        return 'Alchemist';
      case 'guardian':
        return 'Guardian';
      default:
        return 'Wanderer';
    }
  }

  String _archetypeDescription(String value) {
    switch (value) {
      case 'scholar':
        return 'Turns curiosity into clarity. Built for notes, research, and thoughtful progress.';
      case 'scout':
        return 'Finds the shortest useful path and keeps moving when the route changes.';
      case 'alchemist':
        return 'Experiments, adjusts, and turns messy ingredients into workable momentum.';
      case 'guardian':
        return 'Protects attention, steadies the room, and makes space for what matters.';
      default:
        return 'Follows curiosity without needing a perfect map. Flexible by design.';
    }
  }

  String _masteryRelicName(String value) {
    switch (value) {
      case 'scholar':
        return 'Scholar Seal';
      case 'scout':
        return 'Scout Compass';
      case 'alchemist':
        return 'Alchemist Phial';
      case 'guardian':
        return 'Guardian Crest';
      default:
        return 'Wanderer Star Map';
    }
  }

  IconData _archetypeIcon(String value) {
    switch (value) {
      case 'scholar':
        return Icons.menu_book_outlined;
      case 'scout':
        return Icons.explore_outlined;
      case 'alchemist':
        return Icons.science_outlined;
      case 'guardian':
        return Icons.shield_outlined;
      default:
        return Icons.hiking_outlined;
    }
  }

  Future<void> _claimMasteryReward() async {
    if (_claimingMastery) return;
    setState(() => _claimingMastery = true);

    try {
      await QuestwellCosmeticService.claimClassMasteryReward();
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class mastery reward claimed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mastery reward is not ready yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _claimingMastery = false);
    }
  }

  Future<void> _chooseBodyType(String bodyType) async {
    if (_savingBodyType) return;

    final previous = _avatarBodyOverride;
    setState(() {
      _savingBodyType = true;
      _avatarBodyOverride = bodyType;
    });

    try {
      await QuestwellCosmeticService.setAvatarBodyType(bodyType);
      if (!mounted) return;
      _refresh();
      setState(() => _savingBodyType = false);
      // The selected border and label confirm success without hiding the art.
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savingBodyType = false;
        _avatarBodyOverride = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar change failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _chooseArchetype(String archetype) async {
    if (_savingArchetype) return;
    setState(() => _savingArchetype = true);

    try {
      await QuestwellCosmeticService.setAdventurerArchetype(archetype);
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_archetypeLabel(archetype)} selected.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingArchetype = false);
    }
  }

  Future<void> _requestArchetypeChange(
    String archetype,
    QuestwellCosmeticsSnapshot data,
  ) async {
    if (archetype == data.profile.adventurerArchetype || _savingArchetype) {
      return;
    }

    final incompatible = data.cosmetics
        .where(
          (item) =>
              item.equipped &&
              item.requiredArchetype != null &&
              item.requiredArchetype != archetype,
        )
        .toList();

    if (incompatible.isNotEmpty) {
      final preview = incompatible
          .take(3)
          .map((item) => item.name)
          .join(', ');
      final remaining = incompatible.length - 3;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogTheme = FlutterFlowTheme.of(dialogContext);
          return AlertDialog(
            backgroundColor: dialogTheme.secondaryBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Change to ${_archetypeLabel(archetype)}?',
              style: dialogTheme.titleLarge.override(
                font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                letterSpacing: 0,
              ),
            ),
            content: Text(
              '$preview${remaining > 0 ? ' and $remaining more' : ''} will be unequipped because that gear belongs to another class. You will still own it.',
              style: dialogTheme.bodyMedium.override(
                font: GoogleFonts.roboto(),
                color: dialogTheme.secondaryText,
                letterSpacing: 0,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep Current Class'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Change Class'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !mounted) return;
    }

    await _chooseArchetype(archetype);
  }

  bool _classLocked(
    QuestwellCosmetic cosmetic,
    String currentArchetype,
  ) {
    return cosmetic.requiredArchetype != null &&
        cosmetic.requiredArchetype != currentArchetype;
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'head':
        return Icons.face_retouching_natural;
      case 'face':
        return Icons.visibility_outlined;
      case 'neck':
        return Icons.style_outlined;
      case 'chest':
      case 'outfit':
        return Icons.checkroom_outlined;
      case 'hands':
        return Icons.pan_tool_alt_outlined;
      case 'legs':
        return Icons.airline_seat_legroom_normal_outlined;
      case 'feet':
        return Icons.hiking_outlined;
      case 'back':
        return Icons.backpack_outlined;
      case 'familiar':
        return Icons.pets_outlined;
      case 'room':
        return Icons.chair_outlined;
      case 'effect':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        top: true,
        child: FutureBuilder<QuestwellCosmeticsSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: QuestwellRetroPanel(
                  padding: const EdgeInsets.all(16),
                  accent: const Color(0xFFE87947),
                  background: const Color(0xFF1A1512),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const QuestwellNavPixelIcon(
                        kind: 'adventurer',
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'CHARACTER SHEET UNAVAILABLE',
                        textAlign: TextAlign.center,
                        style: theme.titleMedium.override(
                          font: GoogleFonts.pressStart2p(
                            fontWeight: FontWeight.w700,
                          ),
                          fontSize: 10,
                          letterSpacing: .3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(_refresh),
                        child: const Text('TRY AGAIN'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 220,
                child: QuestwellRetroPanel(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final selectedBodyType =
              _avatarBodyOverride ?? data.profile.avatarBodyType;
          final equipped = data.cosmetics.where((item) => item.equipped).toList();
          final visibleEquipped =
              _richEquipmentLayersReady ? equipped : <QuestwellCosmetic>[];
          final owned = data.cosmetics.where((item) => item.owned).toList();
          final classCollection = data.cosmetics
              .where(
                (item) =>
                    item.requiredArchetype ==
                        data.profile.adventurerArchetype &&
                    item.unlockMethod == 'shop',
              )
              .toList();
          final masteryRewards = data.cosmetics
              .where(
                (item) =>
                    item.requiredArchetype ==
                        data.profile.adventurerArchetype &&
                    item.unlockMethod == 'class_mastery',
              )
              .toList();
          final ownedClassItems =
              classCollection.where((item) => item.owned).length;
          final collectionComplete = classCollection.isNotEmpty &&
              ownedClassItems == classCollection.length;
          final masteryOwned =
              masteryRewards.any((item) => item.owned);

          return RefreshIndicator(
            onRefresh: () async {
              setState(_refresh);
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
              children: [
                Row(
                  children: [
                    QuestwellTopActionButton(
                      kind: 'back',
                      tooltip: 'Back to the Hearth',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADVENTURER',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFE7A4),
                              shadows: const [
                                Shadow(
                                  color: Color(0xFF5A3419),
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Character • equipment • relics • collection',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB9D8EA),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const QuestwellNavPixelIcon(
                      kind: 'adventurer',
                      size: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const QuestwellPixelDivider(
                  accent: Color(0xFFD6A84B),
                ),
                const SizedBox(height: 14),
                QuestwellRetroPanel(
                  padding: EdgeInsets.zero,
                  accent: const Color(0xFFD6A84B),
                  background: const Color(0xFF0B1320),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 520;
                      final avatar = QuestwellEquippedAvatar(
                        archetype: data.profile.adventurerArchetype,
                        avatarBodyType: selectedBodyType,
                        height: compact ? 286 : 330,
                        artHeightFactor: .96,
                        showRelic: masteryOwned,
                        equippedSlugs: {
                          for (final item in equipped)
                            item.category: item.slug,
                        },
                      );
                      final dossier = Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xE6121822),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF6A4C2C),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'LEVEL ${data.profile.level}',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFFE7A4),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _archetypeLabel(
                                data.profile.adventurerArchetype,
                              ).toUpperCase(),
                              style: GoogleFonts.pressStart2p(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: QuestwellPixelPalette.forClass(
                                  data.profile.adventurerArchetype,
                                ).last,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const QuestwellPixelDivider(
                              accent: Color(0xFF8E6B35),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${data.profile.totalXp} XP',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFD7E2EF),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${data.profile.coinBalance} COINS',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF1C75B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${visibleEquipped.length} / 5 GEAR SLOTS ACTIVE',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5,
                                color: const Color(0xFF9FB4C9),
                              ),
                            ),
                            if (masteryOwned) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  QuestwellRelicPixelArt(
                                    archetype:
                                        data.profile.adventurerArchetype,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'MASTERY RELIC BOUND',
                                      style: GoogleFonts.roboto(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFE6C568),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                      if (compact) {
                        return Column(
                          children: [
                            avatar,
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFF6A4C2C),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: dossier,
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 7, child: avatar),
                          Expanded(flex: 4, child: dossier),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'CHOOSE YOUR ADVENTURER',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.pressStart2p(
                      fontWeight: FontWeight.w700,
                    ),
                    fontSize: 13,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose your body style, shown wearing your current class outfit. Your business suit stays underneath.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.roboto(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth >= 680
                        ? (constraints.maxWidth - 16) / 3
                        : (constraints.maxWidth - 8) / 2;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        for (final value in const ['male', 'female', 'neutral'])
                          SizedBox(
                            width: width,
                            child: _AvatarBodyCard(
                              bodyType: value,
                              archetype: data.profile.adventurerArchetype,
                              selected: selectedBodyType == value,
                              disabled: _savingBodyType,
                              onTap: () => _chooseBodyType(value),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                Text(
                  'YOUR ARCHETYPE',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.pressStart2p(
                      fontWeight: FontWeight.w700,
                    ),
                    fontSize: 13,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cosmetic identity only. Pick the vibe that feels like you.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.roboto(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final width = wide
                        ? (constraints.maxWidth - 16) / 3
                        : constraints.maxWidth >= 520
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        for (final value in const [
                          'scholar',
                          'scout',
                          'alchemist',
                          'guardian',
                          'wanderer',
                        ])
                          SizedBox(
                            width: width,
                            child: _ArchetypeCard(
                              archetype: value,
                              label: _archetypeLabel(value),
                              description: _archetypeDescription(value),
                              selected:
                                  data.profile.adventurerArchetype == value,
                              disabled: _savingArchetype,
                              onTap: () =>
                                  _requestArchetypeChange(value, data),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                QuestwellRetroPanel(
                  padding: const EdgeInsets.all(14),
                  accent: const Color(0xFFD6A84B),
                  background: const Color(0xFF171A20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuestwellRelicPixelArt(
                        archetype: data.profile.adventurerArchetype,
                        size: 58,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_archetypeLabel(data.profile.adventurerArchetype)} Path',
                              style: theme.titleMedium.override(
                                font: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                ),
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _archetypeDescription(
                                data.profile.adventurerArchetype,
                              ),
                              style: theme.bodySmall.override(
                                font: GoogleFonts.roboto(),
                                color: theme.secondaryText,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mastery relic: ${_masteryRelicName(data.profile.adventurerArchetype)}',
                              style: theme.labelMedium.override(
                                font: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: theme.primary,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QuestwellRetroPanel(
                  padding: const EdgeInsets.all(14),
                  accent: const Color(0xFF8E6B35),
                  background: const Color(0xFF17151A),
                  child: Row(
                    children: [
                      Icon(
                        ownedClassItems == classCollection.length &&
                                classCollection.isNotEmpty
                            ? Icons.workspace_premium_outlined
                            : Icons.inventory_2_outlined,
                        color: theme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_archetypeLabel(data.profile.adventurerArchetype)} Collection',
                              style: theme.titleMedium.override(
                                font: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                ),
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              classCollection.isEmpty
                                  ? 'No exclusive gear yet.'
                                  : masteryOwned
                                      ? 'Mastery complete — signature relic claimed.'
                                      : collectionComplete
                                          ? 'Collection complete — your mastery relic is ready.'
                                          : '$ownedClassItems of ${classCollection.length} class-exclusive items unlocked',
                              style: theme.bodySmall.override(
                                font: GoogleFonts.roboto(),
                                color: theme.secondaryText,
                                letterSpacing: 0,
                              ),
                            ),
                            if (collectionComplete && !masteryOwned) ...[
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                onPressed: _claimingMastery
                                    ? null
                                    : _claimMasteryReward,
                                icon: const Icon(
                                  Icons.workspace_premium_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  _claimingMastery
                                      ? 'Claiming...'
                                      : 'Claim Mastery Relic',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'EQUIPPED GEAR',
                        style: theme.titleLarge.override(
                          font: GoogleFonts.pressStart2p(
                            fontWeight: FontWeight.w700,
                          ),
                          fontSize: 12,
                          color: const Color(0xFFF2D9A0),
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                    Text(
                      '${equipped.length} / 5 SLOTS',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD6A84B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 820
                        ? 5
                        : constraints.maxWidth >= 520
                            ? 3
                            : 2;
                    final width =
                        (constraints.maxWidth - ((columns - 1) * 8)) / columns;
                    final slots = <Map<String, String>>[
                      {'label': 'HEAD', 'category': 'head'},
                      {'label': 'FACE', 'category': 'face'},
                      {'label': 'NECK', 'category': 'neck'},
                      {'label': 'CHEST', 'category': 'chest'},
                      {'label': 'HANDS', 'category': 'hands'},
                      {'label': 'LEGS', 'category': 'legs'},
                      {'label': 'FEET', 'category': 'feet'},
                      {'label': 'BACK', 'category': 'back'},
                      {'label': 'FAMILIAR', 'category': 'familiar'},
                      {'label': 'ROOM', 'category': 'room'},
                      {'label': 'EFFECT', 'category': 'effect'},
                    ];
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final slot in slots)
                          SizedBox(
                            width: width,
                            child: _GearSlotCard(
                              label: slot['label']!,
                              cosmetic: equipped
                                  .where(
                                    (item) =>
                                        item.category == slot['category'],
                                  )
                                  .cast<QuestwellCosmetic?>()
                                  .firstWhere(
                                    (item) => item != null,
                                    orElse: () => null,
                                  ),
                              archetype:
                                  data.profile.adventurerArchetype,
                              onUnequip: (item) => _unequip(item),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'BACKPACK',
                        style: theme.titleLarge.override(
                          font: GoogleFonts.pressStart2p(
                            fontWeight: FontWeight.w700,
                          ),
                          fontSize: 12,
                          color: const Color(0xFFF2D9A0),
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141820),
                        border: Border.all(
                          color: const Color(0xFF8E6B35),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${owned.length} ITEMS',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF2D9A0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything you have earned or unlocked lives here.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.roboto(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                if (owned.isEmpty)
                  _EmptyPanel(
                    text:
                        'Your pack is empty. Finish quests, earn coins, and unlock your first cosmetic.',
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 620
                              ? 3
                              : 2;
                      final width =
                          (constraints.maxWidth - ((columns - 1) * 10)) /
                              columns;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final item in owned)
                            SizedBox(
                              width: width,
                              child: _InventoryTile(
                                cosmetic: item,
                                currentArchetype:
                                    data.profile.adventurerArchetype,
                                locked: _classLocked(
                                  item,
                                  data.profile.adventurerArchetype,
                                ),
                                busy: _busyCosmeticId == item.id,
                                onEquip: () => _equip(item),
                                onUnequip: () => _unequip(item),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _ArchetypeCard extends StatelessWidget {
  const _ArchetypeCard({
    required this.archetype,
    required this.label,
    required this.description,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String archetype;
  final String label;
  final String description;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = QuestwellPixelPalette.forClass(archetype);

    return Semantics(
      button: true,
      selected: selected,
      label: '$label archetype',
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF211C19)
                : const Color(0xFF17151A),
            border: Border.all(
              color: selected ? palette.last : const Color(0xFF6A4C2C),
              width: selected ? 3 : 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x77000000),
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestwellClassMiniSprite(
                archetype: archetype,
                size: 62,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? palette.last
                            : const Color(0xFFF2D9A0),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        height: 1.25,
                        color: const Color(0xFFB7C4D4),
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ACTIVE CLASS',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: palette.last,
                          letterSpacing: .7,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarBodyCard extends StatelessWidget {
  const _AvatarBodyCard({
    required this.bodyType,
    required this.archetype,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String bodyType;
  final String archetype;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  String get label => switch (bodyType) {
        'male' => 'MALE',
        'female' => 'FEMALE',
        _ => 'GENDER NEUTRAL',
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: QuestwellRetroPanel(
          padding: const EdgeInsets.all(10),
          accent: selected
              ? const Color(0xFFF1C75B)
              : const Color(0xFF526178),
          background: const Color(0xFF101923),
          child: Column(
            children: [
              SizedBox(
                height: 176,
                child: QuestwellLayeredAdventurerArt(
                  archetype: archetype,
                  avatarBodyType: bodyType,
                  equippedSlugs: const {},
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: bodyType == 'neutral' ? 7 : 8,
                  color: selected
                      ? const Color(0xFFFFD978)
                      : const Color(0xFFF2E7CE),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      const Icon(Icons.check_rounded,
                          size: 12, color: Color(0xFFF1C75B)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      selected ? 'SELECTED' : '${archetype.toUpperCase()} PREVIEW',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? const Color(0xFFF1C75B)
                            : const Color(0xFF9FB4C9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GearSlotCard extends StatelessWidget {
  const _GearSlotCard({
    required this.label,
    required this.cosmetic,
    required this.archetype,
    required this.onUnequip,
  });

  final String label;
  final QuestwellCosmetic? cosmetic;
  final String archetype;
  final ValueChanged<QuestwellCosmetic> onUnequip;

  @override
  Widget build(BuildContext context) {
    final item = cosmetic;
    return QuestwellRetroPanel(
      padding: const EdgeInsets.all(10),
      accent: item == null
          ? const Color(0xFF4B5563)
          : const Color(0xFFD6A84B),
      background: const Color(0xFF101923),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: const Color(0xFFB7C4D4),
            ),
          ),
          const SizedBox(height: 8),
          if (item == null)
            Container(
              width: 66,
              height: 66,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1320),
                border: Border.all(
                  color: const Color(0xFF344054),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF50617A),
                size: 26,
              ),
            )
          else
            QuestwellItemPixelArt(
              slug: item.slug,
              category: item.category,
              archetype: item.requiredArchetype ?? archetype,
              size: 66,
            ),
          const SizedBox(height: 8),
          Text(
            item?.name ?? 'Empty',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: item == null
                  ? const Color(0xFF718096)
                  : const Color(0xFFF2D9A0),
            ),
          ),
          if (item != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onUnequip(item),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(34),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  side: const BorderSide(
                    color: Color(0xFF8E6B35),
                    width: 2,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text('UNEQUIP'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({
    required this.cosmetic,
    required this.currentArchetype,
    required this.locked,
    required this.busy,
    required this.onEquip,
    required this.onUnequip,
  });

  final QuestwellCosmetic cosmetic;
  final String currentArchetype;
  final bool locked;
  final bool busy;
  final VoidCallback onEquip;
  final VoidCallback onUnequip;

  @override
  Widget build(BuildContext context) {
    return QuestwellRetroPanel(
      padding: const EdgeInsets.all(10),
      accent: cosmetic.equipped
          ? const Color(0xFFF1C75B)
          : locked
              ? const Color(0xFF5B3A3A)
              : const Color(0xFF8E6B35),
      background: const Color(0xFF101923),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: QuestwellItemPixelArt(
              slug: cosmetic.slug,
              category: cosmetic.category,
              archetype: cosmetic.requiredArchetype ?? currentArchetype,
              size: 78,
              locked: locked,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cosmetic.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 12,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF2E7CE),
            ),
          ),
          const SizedBox(height: 7),
          Center(
            child: QuestwellRarityPixelBadge(
              rarity: cosmetic.rarity,
              compact: true,
            ),
          ),
          if (cosmetic.requiredArchetype != null) ...[
            const SizedBox(height: 6),
            Text(
              locked ? 'CLASS LOCKED' : 'CLASS GEAR',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: locked
                    ? const Color(0xFFE87947)
                    : const Color(0xFF4AA89A),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: busy || locked
                  ? null
                  : cosmetic.equipped
                      ? onUnequip
                      : onEquip,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(34),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                side: BorderSide(
                  color: cosmetic.equipped
                      ? const Color(0xFFF1C75B)
                      : const Color(0xFF526178),
                  width: 2,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                locked
                    ? 'LOCKED'
                    : cosmetic.equipped
                        ? 'UNEQUIP'
                        : 'EQUIP',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquippedChip extends StatelessWidget {
  const _EquippedChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: theme.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.labelMedium.override(
              font: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: theme.bodyMedium.override(
          font: GoogleFonts.roboto(),
          color: theme.secondaryText,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
