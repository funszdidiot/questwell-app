import '/widgets/questwell_room_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_cosmetic_service.dart';
import '/services/questwell_equipment_policy.dart';
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
      if (cosmetic.category == 'room') {
        final data = await QuestwellCosmeticService.load();
        if (!mounted) return;
        final equipped = data.cosmetics.where((i) => i.equipped).toList();
        final pick = await showRoomPicker(context, name: cosmetic.name, id: cosmetic.id,
          slug: cosmetic.slug, currentSlot: cosmetic.equipped ? cosmetic.roomSlot ?? 'right' : null,
          archetype: data.profile.adventurerArchetype, bodyType: data.profile.avatarBodyType,
          equippedSlugs: {for (final i in equipped) i.renderKey: i.slug},
          occupants: {for (final i in equipped.where((i) => i.category == 'room'))
            i.roomSlot ?? 'right': RoomOccupant(i.id, i.name)});
        if (pick == null) return;
        await QuestwellCosmeticService.place(cosmetic.id, pick.slot, pick.expectedOccupant);
      } else {
        await QuestwellCosmeticService.equip(cosmetic);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cosmetic.category == 'room' ? '${cosmetic.name} placed in your Hearth.' : cosmetic.category == 'wall_art' ? '${cosmetic.name} hung in your Hearth.' : '${cosmetic.name} equipped.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(_refresh);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not save your equipment. Refresh and try again.'),
        behavior: SnackBarBehavior.floating,
      ));
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
          content: Text((cosmetic.category == 'room' || cosmetic.category == 'wall_art') ? '${cosmetic.name} removed from your Hearth.' : '${cosmetic.name} unequipped.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(_refresh);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not save your equipment. Refresh and try again.'),
        behavior: SnackBarBehavior.floating,
      ));
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
                        font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
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
                              font: GoogleFonts.roboto(
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
                  height:
                      MediaQuery.sizeOf(context).width < 430 ? 250 : 285,
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
                                font: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                ),
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Earn coins by finishing real-life quests.',
                              style: theme.bodySmall.override(
                                font: GoogleFonts.roboto(),
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
                    font: GoogleFonts.roboto(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 980
                        ? 4
                        : constraints.maxWidth >= 680
                            ? 3
                            : constraints.maxWidth >= 460
                                ? 2
                                : 1;
                    final itemWidth =
                        (constraints.maxWidth - ((columns - 1) * 10)) /
                            columns;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final cosmetic in currentClassItems)
                          SizedBox(
                            width: itemWidth,
                            height: 310,
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
                    font: GoogleFonts.roboto(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 980
                        ? 4
                        : constraints.maxWidth >= 680
                            ? 3
                            : constraints.maxWidth >= 460
                                ? 2
                                : 1;
                    final itemWidth =
                        (constraints.maxWidth - ((columns - 1) * 10)) /
                            columns;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final cosmetic in generalItems)
                          SizedBox(
                            width: itemWidth,
                            height: 310,
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
                      font: GoogleFonts.roboto(),
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
      padding: const EdgeInsets.all(10),
      accent: classLocked
          ? const Color(0xFF5A5B62)
          : cosmetic.equipped
              ? const Color(0xFFF1C75B)
              : const Color(0xFF8E6B35),
      background: const Color(0xFF101923),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 132,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF18283A),
                  Color(0xFF0B1320),
                  Color(0xFF17110E),
                ],
              ),
              border: Border.all(
                color: classLocked
                    ? const Color(0xFF55565C)
                    : const Color(0xFF6A4C2C),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: QuestwellItemPixelArt(
                    slug: cosmetic.slug,
                    category: cosmetic.category,
                    archetype: cosmetic.requiredArchetype,
                    size: 104,
                    locked: classLocked,
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 4,
                  child: QuestwellRarityPixelBadge(
                    rarity: cosmetic.rarity,
                    compact: true,
                  ),
                ),
                if (cosmetic.equipped)
                  const Positioned(
                    right: 4,
                    top: 4,
                    child: QuestwellStatusPixelBadge(
                      kind: 'momentum',
                      size: 26,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cosmetic.name.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.titleMedium.override(
              font: GoogleFonts.roboto(
                fontWeight: FontWeight.w800,
              ),
              fontSize: 14,
              color: const Color(0xFFF2D9A0),
              letterSpacing: .15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            cosmetic.category.replaceAll('_', ' ').toUpperCase(),
            style: theme.labelSmall.override(
              font: GoogleFonts.roboto(fontWeight: FontWeight.w800),
              color: const Color(0xFF9EACBE),
              letterSpacing: .8,
            ),
          ),
          if (cosmetic.requiredArchetype != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  classLocked ? Icons.lock_outline : Icons.verified_outlined,
                  size: 14,
                  color: classLocked
                      ? const Color(0xFF8893A3)
                      : const Color(0xFF7654D8),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${archetypeLabel(cosmetic.requiredArchetype!)} only',
                    overflow: TextOverflow.ellipsis,
                    style: theme.labelSmall.override(
                      font: GoogleFonts.roboto(
                        fontWeight: FontWeight.w800,
                      ),
                      color: classLocked
                          ? const Color(0xFF8893A3)
                          : const Color(0xFF8D6DFF),
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (cosmetic.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cosmetic.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.bodySmall.override(
                font: GoogleFonts.roboto(),
                color: const Color(0xFFB7C4D4),
                letterSpacing: 0,
              ),
            ),
          ],
          const Spacer(),
          const SizedBox(height: 10),
          if (cosmetic.owned)
            OutlinedButton.icon(
              onPressed: busy ? null : cosmetic.equipped ? onUnequip
                  : classLocked || !QuestwellEquipmentPolicy.isReady(cosmetic.slug, cosmetic.category)
                      ? null : onEquip,
              icon: QuestwellNavPixelIcon(
                kind: cosmetic.equipped ? 'quest' : 'adventurer',
                size: 17,
              ),
              label: Text(
                cosmetic.equipped ? ((cosmetic.category == 'room' || cosmetic.category == 'wall_art') ? 'REMOVE' : 'UNEQUIP') : classLocked ? 'LOCKED'
                    : QuestwellEquipmentPolicy.isReady(cosmetic.slug, cosmetic.category)
                        ? (cosmetic.category == 'room' ? 'PLACE IN HEARTH' : cosmetic.category == 'wall_art' ? 'HANG IN HEARTH' : 'EQUIP') : 'COMING SOON',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(38),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                side: const BorderSide(
                  color: Color(0xFF8E6B35),
                  width: 2,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: busy || classLocked ? null : onPurchase,
              icon: const QuestwellCurrencyPixelIcon(
                kind: 'coin',
                size: 17,
              ),
              label: Text(
                classLocked
                    ? 'LOCKED'
                    : busy
                        ? '...'
                        : '${cosmetic.price}',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(38),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                backgroundColor: const Color(0xFF205AD4),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
        ],
      ),
    );  }
}
