import '../../widgets/questwell_wall_art.dart';
import '/widgets/questwell_room_picker.dart';
import '/services/questwell_cosmetic_service.dart';
import '/widgets/questwell_market_view.dart';
import '/widgets/questwell_typography.dart';
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
            '${cosmetic.name} unlocked. $remaining coins remain.',
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
            : 'The purchase could not be confirmed. Please refresh before trying again.'),
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
      if (cosmetic.category == 'room' || QuestwellWallArt.isSide(cosmetic.slug)) {
        final data = await QuestwellCosmeticService.load();
        if (!mounted) return;
        final equipped = data.cosmetics.where((i) => i.equipped).toList();
        final pick = await showRoomPicker(context, name: cosmetic.name, id: cosmetic.id,
          slug: cosmetic.slug, currentSlot: cosmetic.equipped ? cosmetic.roomSlot ?? 'right' : null,
          archetype: data.profile.adventurerArchetype, bodyType: data.profile.avatarBodyType,
          equippedSlugs: {for (final i in equipped) i.renderKey: i.slug},
          occupants: {for (final i in equipped.where((i) => i.category == cosmetic.category))
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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101C21),
    appBar: AppBar(backgroundColor: const Color(0xFF101C21), title: Text('MARKET',style:QuestwellTypography.sectionHeading(size:14))),
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
