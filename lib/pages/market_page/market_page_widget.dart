import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_pixel_art.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketPageWidget extends StatefulWidget {
  const MarketPageWidget({super.key});

  static String routeName = 'MarketPage';
  static String routePath = '/market';

  @override
  State<MarketPageWidget> createState() => _MarketPageWidgetState();
}

class _MarketPageWidgetState extends State<MarketPageWidget> {
  late Future<QuestwellCosmeticsSnapshot> _future;
  String? _busyCosmeticId;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = QuestwellCosmeticService.load();
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

  Future<void> _purchase(QuestwellCosmetic cosmetic) async {
    if (_busyCosmeticId != null) return;
    setState(() => _busyCosmeticId = cosmetic.id);

    try {
      final remaining = await QuestwellCosmeticService.purchase(cosmetic.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${cosmetic.name} unlocked. $remaining coins remain.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(_refresh);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins yet. Keep questing.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyCosmeticId = null);
    }
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
          final currentClassItems = data.cosmetics
              .where(
                (item) =>
                    item.unlockMethod == 'shop' &&
                    item.requiredArchetype == data.profile.adventurerArchetype,
              )
              .toList();
          final generalItems = data.cosmetics
              .where(
                (item) =>
                    item.unlockMethod == 'shop' &&
                    item.requiredArchetype == null,
              )
              .toList();
          final otherClassItems = data.cosmetics
              .where(
                (item) =>
                    item.unlockMethod == 'shop' &&
                    item.requiredArchetype != null &&
                    item.requiredArchetype != data.profile.adventurerArchetype,
              )
              .toList();

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
                            'THE MARKET',
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
                            'Rare finds, class gear, and questionable fashion choices.',
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
                      kind: 'market',
                      size: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const QuestwellPixelDivider(
                  accent: Color(0xFFD6A84B),
                ),
                const SizedBox(height: 14),
                QuestwellMarketPixelScene(
                  archetype: data.profile.adventurerArchetype,
                  height: 205,
                ),
                const SizedBox(height: 14),
                QuestwellRetroPanel(
                  padding: const EdgeInsets.all(14),
                  accent: const Color(0xFFF1C75B),
                  background: const Color(0xFF17151A),
                  child: Row(
                    children: [
                      const QuestwellCurrencyPixelIcon(
                        kind: 'coin',
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.profile.coinBalance} coins',
                              style: theme.titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Earn coins by finishing real-life quests.',
                              style: theme.bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: theme.secondaryText,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  '${_archetypeLabel(data.profile.adventurerArchetype).toUpperCase()} COLLECTION',
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
                  'Exclusive gear for your current Adventurer class.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final itemWidth = wide
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final cosmetic in currentClassItems)
                          SizedBox(
                            width: itemWidth,
                            child: _MarketCard(
                              cosmetic: cosmetic,
                              currentArchetype:
                                  data.profile.adventurerArchetype,
                              busy: _busyCosmeticId == cosmetic.id,
                              icon: _iconForCategory(cosmetic.category),
                              onPurchase: () => _purchase(cosmetic),
                              onEquip: () => _equip(cosmetic),
                              onUnequip: () => _unequip(cosmetic),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'GUILD GOODS',
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
                  'Available to every class. Cosmetics only — productivity never depends on what you buy.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final itemWidth = wide
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final cosmetic in generalItems)
                          SizedBox(
                            width: itemWidth,
                            child: _MarketCard(
                              cosmetic: cosmetic,
                              currentArchetype:
                                  data.profile.adventurerArchetype,
                              busy: _busyCosmeticId == cosmetic.id,
                              icon: _iconForCategory(cosmetic.category),
                              onPurchase: () => _purchase(cosmetic),
                              onEquip: () => _equip(cosmetic),
                              onUnequip: () => _unequip(cosmetic),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (otherClassItems.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'OTHER CLASS COLLECTIONS',
                    style: theme.titleLarge.override(
                      font: GoogleFonts.pressStart2p(
                        fontWeight: FontWeight.w700,
                      ),
                      fontSize: 12,
                      letterSpacing: .2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You can browse these, but they stay locked unless you change class.',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: theme.secondaryText,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 760;
                      final itemWidth = wide
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final cosmetic in otherClassItems)
                            SizedBox(
                              width: itemWidth,
                              child: _MarketCard(
                                cosmetic: cosmetic,
                                currentArchetype:
                                    data.profile.adventurerArchetype,
                                busy: _busyCosmeticId == cosmetic.id,
                                icon: _iconForCategory(cosmetic.category),
                                onPurchase: () => _purchase(cosmetic),
                                onEquip: () => _equip(cosmetic),
                                onUnequip: () => _unequip(cosmetic),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({
    required this.cosmetic,
    required this.currentArchetype,
    required this.busy,
    required this.icon,
    required this.onPurchase,
    required this.onEquip,
    required this.onUnequip,
  });

  final QuestwellCosmetic cosmetic;
  final String currentArchetype;
  final bool busy;
  final IconData icon;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;
  final VoidCallback onUnequip;

  String archetypeLabel(String value) {
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

  bool get classLocked =>
      cosmetic.requiredArchetype != null &&
      cosmetic.requiredArchetype != currentArchetype;

  String get rarityLabel {
    final value = cosmetic.rarity;
    if (value.isEmpty) return 'Common';
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return QuestwellRetroPanel(
      padding: const EdgeInsets.all(12),
      accent: classLocked
          ? const Color(0xFF5A5B62)
          : cosmetic.equipped
              ? const Color(0xFFF1C75B)
              : const Color(0xFF8E6B35),
      background: const Color(0xFF15141B),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 92,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1824),
              border: Border.all(
                color: classLocked
                    ? const Color(0xFF55565C)
                    : const Color(0xFF6A4C2C),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                QuestwellItemPixelArt(
                  slug: cosmetic.slug,
                  category: cosmetic.category,
                  archetype: cosmetic.requiredArchetype,
                  size: 72,
                  locked: classLocked,
                ),
                const SizedBox(height: 6),
                QuestwellRarityPixelBadge(
                  rarity: cosmetic.rarity,
                  compact: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cosmetic.name.toUpperCase(),
                  style: theme.titleMedium.override(
                    font: GoogleFonts.pressStart2p(
                      fontWeight: FontWeight.w700,
                    ),
                    fontSize: 10,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      cosmetic.category.toUpperCase(),
                      style: theme.labelSmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        color: theme.secondaryText,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
                if (cosmetic.requiredArchetype != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        classLocked ? Icons.lock_outline : Icons.verified_outlined,
                        size: 15,
                        color: classLocked ? theme.secondaryText : theme.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${archetypeLabel(cosmetic.requiredArchetype!)} only',
                        style: theme.labelSmall.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                          color: classLocked ? theme.secondaryText : theme.primary,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ],
                if (cosmetic.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    cosmetic.description,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (cosmetic.owned)
                  OutlinedButton.icon(
                    onPressed: busy || classLocked
                        ? null
                        : cosmetic.equipped
                            ? onUnequip
                            : onEquip,
                    icon: QuestwellNavPixelIcon(
                      kind: cosmetic.equipped ? 'quest' : 'adventurer',
                      size: 18,
                    ),
                    label: Text(
                      classLocked
                          ? 'Class locked'
                          : cosmetic.equipped
                              ? 'Unequip'
                              : 'Equip',
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: busy || classLocked ? null : onPurchase,
                    icon: const QuestwellCurrencyPixelIcon(
                      kind: 'coin',
                      size: 18,
                    ),
                    label: Text(
                      classLocked
                          ? '${archetypeLabel(cosmetic.requiredArchetype!)} only'
                          : busy
                              ? 'Unlocking...'
                              : '${cosmetic.price} coins',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
