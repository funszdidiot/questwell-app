import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth_page/auth_page_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_adventurer_view.dart';
import '/pages/market_page/market_page_widget.dart';
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
  bool _savingBodyType = false;
  bool _claimingMastery = false;
  bool _signingOut = false;
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
    if (_busyCosmeticId != null || _savingArchetype || _savingBodyType) return;
    setState(() => _busyCosmeticId = cosmetic.id);

    try {
      await QuestwellCosmeticService.equip(cosmetic);
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

  Future<void> _place(String id, String slot, String? expected) async {
    if (_busyCosmeticId != null) return;
    setState(() => _busyCosmeticId = id);
    try {
      await QuestwellCosmeticService.place(id, slot, expected);
      if (mounted) setState(_refresh);
    } catch (_) {
      if (mounted) {
        setState(_refresh);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not save placement. The spot may have changed. Please try again.')));
      }
    } finally { if (mounted) setState(() => _busyCosmeticId = null); }
  }

  Future<void> _unequip(QuestwellCosmetic cosmetic) async {
    if (_busyCosmeticId != null || _savingArchetype || _savingBodyType) return;
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
      // The selected class border and refreshed avatar confirm success inline.
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

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await authManager.signOut();
      if (!mounted) return;
      GoRouter.of(context).clearRedirectLocation();
      context.goNamed(AuthPageWidget.routeName);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      bottomNavigationBar: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: OutlinedButton(
          onPressed: _signingOut ? null : _signOut,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFF2D9A0),
            side: const BorderSide(color: Color(0xFF9E7546)),
            minimumSize: const Size.fromHeight(48),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          child: Text(_signingOut ? 'Signing out…' : 'Sign out',
            style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      )),
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
            onRefresh: () async { setState(_refresh); await _future; },
            child: QuestwellAdventurerView(
              archetype: data.profile.adventurerArchetype, bodyType: selectedBodyType,
              level: data.profile.level, xp: data.profile.totalXp, coins: data.profile.coinBalance,
              description: _archetypeDescription(data.profile.adventurerArchetype),
              mastered: masteryOwned, collectionOwned: ownedClassItems,
              collectionTotal: classCollection.length,
              relicName: _masteryRelicName(data.profile.adventurerArchetype),
              canClaim: collectionComplete && !masteryOwned,
              claiming: _claimingMastery, onClaim: _claimMasteryReward,
              savingAppearance: _savingBodyType || _savingArchetype,
              busyItem: _busyCosmeticId,
              onPlace: _place,
              onBody: _chooseBodyType,
              onClass: (value) => _requestArchetypeChange(value, data),
              onEquip: (id) => _equip(data.cosmetics.firstWhere((item) => item.id == id)),
              onUnequip: (id) => _unequip(data.cosmetics.firstWhere((item) => item.id == id)),
              onBack: () => context.safePop(),
              onMarket: () async {
                await context.pushNamed(MarketPageWidget.routeName);
                if (mounted) setState(_refresh);
              },
              items: data.cosmetics.map((item) => AdventurerInventoryItem(
                id: item.id, name: item.name, slug: item.slug, category: item.category, roomSlot: item.roomSlot,
                milestoneLevel: item.milestoneLevel, unlockedAt: item.unlockedAt, source: item.source,
                description: item.description, owned: item.owned, equipped: item.equipped,
                archetype: item.requiredArchetype, shop: item.unlockMethod == 'shop',
                classLocked: _classLocked(item, data.profile.adventurerArchetype),
              )).toList(),
            ),
          );
        },
      ),
      ),
    );
  }
}
