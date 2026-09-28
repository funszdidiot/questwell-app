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
  late Future<QuestwellCosmeticsSnapshot> _future;
  String? _busyCosmeticId;
  bool _savingArchetype = false;
  bool _claimingMastery = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = QuestwellCosmeticService.load();
  }

  Future<void> _equip(QuestwellCosmetic cosmetic) async {
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
                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                letterSpacing: 0,
              ),
            ),
            content: Text(
              '$preview${remaining > 0 ? ' and $remaining more' : ''} will be unequipped because that gear belongs to another class. You will still own it.',
              style: dialogTheme.bodyMedium.override(
                font: GoogleFonts.inter(),
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
      case 'familiar':
        return Icons.pets_outlined;
      case 'room':
        return Icons.chair_outlined;
      case 'effect':
        return Icons.auto_awesome_outlined;
      case 'outfit':
        return Icons.checkroom_outlined;
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
          final equipped = data.cosmetics.where((item) => item.equipped).toList();
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
                            style: theme.headlineMedium.override(
                              font: GoogleFonts.pressStart2p(
                                fontWeight: FontWeight.w700,
                              ),
                              fontSize: 21,
                              color: const Color(0xFFF2D9A0),
                              letterSpacing: .5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your class, gear, relics, and hard-earned collection.',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: const Color(0xFFB7C4D4),
                              letterSpacing: 0,
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
                  padding: const EdgeInsets.all(16),
                  accent: const Color(0xFF8E6B35),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            QuestwellClassPixelPortrait(
                              archetype: data.profile.adventurerArchetype,
                              height: 190,
                              showRelic: masteryOwned,
                            ),
                            if (equipped.isNotEmpty)
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  color: const Color(0xDD17151A),
                                  child: Text(
                                    '${equipped.length} equipped',
                                    style: theme.labelSmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: const Color(0xFFF1C75B),
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LEVEL ${data.profile.level} • ${_archetypeLabel(data.profile.adventurerArchetype).toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: theme.titleLarge.override(
                          font: GoogleFonts.pressStart2p(
                            fontWeight: FontWeight.w700,
                          ),
                          fontSize: 12,
                          letterSpacing: .3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${data.profile.totalXp} XP • ${data.profile.coinBalance} coins',
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: theme.secondaryText,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
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
                    font: GoogleFonts.inter(),
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
                                font: GoogleFonts.interTight(
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
                                font: GoogleFonts.inter(),
                                color: theme.secondaryText,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mastery relic: ${_masteryRelicName(data.profile.adventurerArchetype)}',
                              style: theme.labelMedium.override(
                                font: GoogleFonts.inter(
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
                                font: GoogleFonts.interTight(
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
                                font: GoogleFonts.inter(),
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
                Text(
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
                const SizedBox(height: 10),
                if (equipped.isEmpty)
                  _EmptyPanel(
                    text: 'Nothing equipped yet. Visit The Market and claim your first look.',
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: equipped
                        .map(
                          (item) => _EquippedChip(
                            icon: _iconForCategory(item.category),
                            label: item.name,
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 24),
                Text(
                  'INVENTORY',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.pressStart2p(
                      fontWeight: FontWeight.w700,
                    ),
                    fontSize: 12,
                    color: const Color(0xFFF2D9A0),
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything you have earned or unlocked lives here.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                if (owned.isEmpty)
                  _EmptyPanel(
                    text: 'Your pack is empty. Finish quests, earn coins, and unlock your first cosmetic.',
                  )
                else
                  ...owned.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: QuestwellParchmentPanel(
                        padding: const EdgeInsets.all(14),
                        selected: item.equipped,
                        child: Row(
                          children: [
                            QuestwellItemPixelArt(
                              slug: item.slug,
                              category: item.category,
                              archetype: item.requiredArchetype,
                              size: 54,
                              locked: _classLocked(
                                item,
                                data.profile.adventurerArchetype,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.titleSmall.override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w800,
                                      ),
                                      color: const Color(0xFF30261D),
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      QuestwellRarityPixelBadge(
                                        rarity: item.rarity,
                                        compact: true,
                                      ),
                                      Text(
                                        item.category.toUpperCase(),
                                        style: theme.labelSmall.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: const Color(0xFF67543E),
                                          letterSpacing: .7,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.requiredArchetype != null) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      '${_archetypeLabel(item.requiredArchetype!)} only',
                                      style: theme.labelSmall.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color: _classLocked(
                                          item,
                                          data.profile.adventurerArchetype,
                                        )
                                            ? theme.secondaryText
                                            : theme.primary,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: _busyCosmeticId == item.id ||
                                      _classLocked(
                                        item,
                                        data.profile.adventurerArchetype,
                                      )
                                  ? null
                                  : item.equipped
                                      ? () => _unequip(item)
                                      : () => _equip(item),
                              child: Text(
                                _classLocked(
                                  item,
                                  data.profile.adventurerArchetype,
                                )
                                    ? 'Class locked'
                                    : item.equipped
                                        ? 'Unequip'
                                        : 'Equip',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.25,
                        color: const Color(0xFFB7C4D4),
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ACTIVE CLASS',
                        style: GoogleFonts.inter(
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
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
          font: GoogleFonts.inter(),
          color: theme.secondaryText,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
