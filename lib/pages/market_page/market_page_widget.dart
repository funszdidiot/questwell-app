import '/widgets/questwell_app_navigation.dart';
import '/widgets/questwell_equipment_swap.dart';
import 'package:go_router/go_router.dart';
import '/pages/home_page/home_page_widget.dart';
import '/widgets/questwell_market_home_button.dart';
import '../../widgets/questwell_wall_art.dart';
import '/widgets/questwell_room_picker.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_market_view.dart';
import 'package:flutter/material.dart';

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

  Future<void> _purchase(QuestwellCosmetic cosmetic) async {
    if (_busyCosmeticId != null) return;
    setState(() => _busyCosmeticId = cosmetic.id);

    try {
      final remaining = await QuestwellCosmeticService.purchase(cosmetic.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${cosmetic.name} added to inventory. $remaining coins remain.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(_refresh);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().contains('not enough coins')
            ? 'Your coin balance changed. Refresh and try again.'
            : 'We could not confirm this purchase. Reconnect and refresh the shop to check your inventory. Buying the same item again will not charge you twice.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(_refresh);
    } finally {
      if (mounted) setState(() => _busyCosmeticId = null);
    }
  }

  Future<void> _equip(QuestwellCosmetic cosmetic) async {
    if (_busyCosmeticId != null) return;
    setState(() => _busyCosmeticId = cosmetic.id);

    try {
      if (cosmetic.category == 'room' || cosmetic.category == 'wall_art') {
        final data = await QuestwellCosmeticService.load();
        if (!mounted) return;
        final equipped = data.cosmetics.where((i) => i.equipped).toList();
        final pick = await showRoomPicker(context, name: cosmetic.name, id: cosmetic.id,
          slug: cosmetic.slug, currentSlot: cosmetic.equipped ? cosmetic.roomSlot ?? 'right' : null,
          archetype: data.profile.adventurerArchetype, bodyType: data.profile.avatarBodyType,
          equippedSlugs: {for (final i in equipped) i.renderKey: i.slug},
          occupants: {for (final i in equipped.where((i) => i.category == cosmetic.category))
            i.roomSlot ?? 'right': RoomOccupant(i.id, i.name),
            ...data.hearthOccupants},
          placementChoices: cosmetic.hearthPlacements.isEmpty
              ? null
              : {for (final option in cosmetic.hearthPlacements)
                  option.slot: option.label},
          hearthProfileKey: cosmetic.hearthProfileKey,
          hearthProfilesBySlug: {
            for (final item in data.cosmetics)
              if (item.hearthProfileKey != null)
                item.slug: item.hearthProfileKey!,
          },
          hearthRenderSpec: cosmetic.hearthRenderSpec,
          hearthRenderBySlug: {
            for (final item in data.cosmetics)
              if (item.hearthRenderSpec != null)
                item.slug: item.hearthRenderSpec!,
          });
        if (pick == null) return;
        await QuestwellCosmeticService.place(cosmetic.id, pick.slot, pick.expectedOccupant);
      } else {
        final current = await QuestwellCosmeticService.load();
      if (!mounted) return;
      final conflict = cloakConflict(cosmetic,current.cosmetics);
      if (conflict != null && !await confirmCloakSwap(context,cosmetic,conflict)) return;
      if (!mounted) return;
      await QuestwellCosmeticService.equip(cosmetic,expectedConflict:conflict?.id);
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
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: const QuestwellAppNavigation(current: QuestwellDestination.market),
    backgroundColor: const Color(0xFF101C21),
    appBar: AppBar(
      backgroundColor: const Color(0xFF101C21),
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 116,
      leading: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: QuestwellMarketHomeButton(
          onHome: () => context.goNamed(HomePageWidget.routeName))),
    ),
    body: SafeArea(top: false, child: FutureBuilder<QuestwellCosmeticsSnapshot>(
      future: _future, builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('The shop could not refresh.'),
          TextButton(onPressed:()=>setState(_refresh),child:const Text('Try again'))]));
        if (!snapshot.hasData) return const Center(child:CircularProgressIndicator());
        return QuestwellMarketView(data:snapshot.data!,busyId:_busyCosmeticId,
          onPurchase:_purchase,onEquip:_equip,onUnequip:_unequip,
          onRefresh:() async {setState(_refresh);await _future;});
      })));
}
