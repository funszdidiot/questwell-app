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
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        foregroundColor: theme.primaryText,
        title: Text(
          'ADVENTURER',
          style: theme.titleLarge.override(
            font: GoogleFonts.pressStart2p(
              fontWeight: FontWeight.w700,
            ),
            fontSize: 14,
            letterSpacing: .4,
          ),
        ),
      ),
      body: FutureBuilder<QuestwellCosmeticsSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 48, color: theme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Could not refresh this page.',
                      textAlign: TextAlign.center,
                      style: theme.titleMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(_refresh),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in const [
                      'scholar',
                      'scout',
                      'alchemist',
                      'guardian',
                      'wanderer',
                    ])
                      ChoiceChip(
                        selected:
                            data.profile.adventurerArchetype == value,
                        onSelected: _savingArchetype
                            ? null
                            : (_) => _requestArchetypeChange(value, data),
                        avatar: Icon(
                          _archetypeIcon(value),
                          size: 17,
                          color: data.profile.adventurerArchetype == value
                              ? theme.primary
                              : theme.secondaryText,
                        ),
                        label: Text(_archetypeLabel(value)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.alternate),
                  ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.alternate),
                  ),
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
                  'Equipped',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: 0,
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
                  'Inventory',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: 0,
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
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.alternate),
                        ),
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
                                        fontWeight: FontWeight.w700,
                                      ),
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
                                          color: theme.secondaryText,
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
