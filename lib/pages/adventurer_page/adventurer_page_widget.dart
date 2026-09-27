import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_cosmetic_service.dart';
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
          'Adventurer',
          style: theme.titleLarge.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
            letterSpacing: 0,
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.alternate),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: theme.primaryBackground,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (equipped.any((item) => item.category == 'room'))
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Icon(
                                    Icons.window_outlined,
                                    size: 130,
                                    color: theme.primary.withValues(alpha: 0.10),
                                  ),
                                ),
                              ),
                            Container(
                              width: 88,
                              height: 108,
                              decoration: BoxDecoration(
                                color: theme.secondaryBackground,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Icon(
                                equipped.any((item) => item.category == 'outfit')
                                    ? Icons.person
                                    : Icons.person_outline,
                                size: 76,
                                color: theme.primary,
                              ),
                            ),
                            if (equipped.any((item) => item.slug == 'round-scholar-glasses'))
                              Positioned(
                                top: 57,
                                child: Icon(
                                  Icons.visibility_outlined,
                                  size: 34,
                                  color: theme.primaryText,
                                ),
                              ),
                            if (equipped.any((item) => item.slug == 'tiny-wizard-hat'))
                              Positioned(
                                top: 15,
                                child: Transform.rotate(
                                  angle: -0.15,
                                  child: Icon(
                                    Icons.change_history,
                                    size: 42,
                                    color: theme.primary,
                                  ),
                                ),
                              ),
                            if (equipped.any((item) => item.slug == 'leather-satchel'))
                              Positioned(
                                left: 26,
                                bottom: 28,
                                child: Icon(
                                  Icons.work_outline,
                                  size: 30,
                                  color: theme.secondaryText,
                                ),
                              ),
                            if (equipped.any((item) => item.category == 'familiar'))
                              Positioned(
                                right: 18,
                                bottom: 18,
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: theme.secondaryBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.alternate),
                                  ),
                                  child: Icon(
                                    Icons.pets,
                                    size: 24,
                                    color: theme.primary,
                                  ),
                                ),
                              ),
                            if (equipped.any((item) => item.category == 'effect'))
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 155,
                                    color: theme.primary.withValues(alpha: 0.18),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Level ${data.profile.level} ${_archetypeLabel(data.profile.adventurerArchetype)}',
                        style: theme.titleLarge.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w700,
                          ),
                          letterSpacing: 0,
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
                  'Your Archetype',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: 0,
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
                            : (_) => _chooseArchetype(value),
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
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: theme.primaryBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _iconForCategory(item.category),
                                color: theme.primary,
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
                                  Text(
                                    '${item.rarity} • ${item.category}',
                                    style: theme.bodySmall.override(
                                      font: GoogleFonts.inter(),
                                      color: theme.secondaryText,
                                      letterSpacing: 0,
                                    ),
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
