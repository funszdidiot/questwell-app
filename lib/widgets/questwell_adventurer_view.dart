import 'package:flutter/material.dart';
import 'questwell_class_emblem.dart';
import 'questwell_mastery_relic.dart';
import 'questwell_room_picker.dart';
import 'questwell_wall_art.dart';
import 'package:intl/intl.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';
import '../services/questwell_equipment_policy.dart';
import '../services/questwell_loadout_model.dart';
import 'questwell_body_fit_labels.dart';

class AdventurerInventoryItem {
  const AdventurerInventoryItem({required this.id, required this.name, required this.slug,
    required this.category, required this.description, required this.owned,
    required this.equipped, required this.classLocked, required this.shop,
    this.archetype, this.roomSlot, this.milestoneLevel, this.unlockedAt, this.source,
    this.collectionKey, this.editionType = 'standard'});
  final String id, name, slug, category, description;
  final String? archetype, roomSlot;
  final int? milestoneLevel;
  final DateTime? unlockedAt;
  final String? source, collectionKey;
  final String editionType;
  String get renderKey => QuestwellLoadoutModel.renderKey(
    category: category,
    roomSlot: roomSlot,
  );
  final bool owned, equipped, classLocked, shop;
}

class QuestwellAdventurerView extends StatefulWidget {
  const QuestwellAdventurerView({super.key, required this.archetype, required this.bodyType,
    required this.level, required this.xp, required this.coins, required this.description,
    required this.items, required this.mastered, required this.collectionOwned,
    required this.collectionTotal, required this.relicName, required this.canClaim,
    required this.onClaim, required this.onBody, required this.onClass,
    required this.onEquip, required this.onUnequip, required this.onMarket,
    required this.onBack, this.savingAppearance = false, this.claiming = false,
    this.busyItem, this.onPlace});
  final String archetype, bodyType, description, relicName;
  final int level, xp, coins, collectionOwned, collectionTotal;
  final List<AdventurerInventoryItem> items;
  final bool mastered, canClaim, savingAppearance, claiming;
  final String? busyItem;
  final Future<void> Function(String id, String slot, String? expectedOccupant)? onPlace;
  final ValueChanged<String> onBody, onClass, onEquip, onUnequip;
  final VoidCallback onClaim, onMarket, onBack;
  @override
  State<QuestwellAdventurerView> createState() => _QuestwellAdventurerViewState();
}

class _QuestwellAdventurerViewState extends State<QuestwellAdventurerView> {
  String _section = 'Equipped';
  String _ownership = 'Owned';
  String _query = '';
  final _searchController = TextEditingController();
  String _category = 'All categories';
  String _collection = 'All collections';
  static const _gold = Color(0xFFE4C586);
  static const _muted = Color(0xFFB9C7D7);
  TextStyle _text(double size, {bool bold = false, Color color = const Color(0xFFF0E5CC)}) =>
    QuestwellTypography.body(fontSize: size, height: 1.4, color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
  String _label(String value) => value == 'room' ? 'Hearth décor' : value.isEmpty ? 'Other' : value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  Widget _heading(String title) => Text(title, style: QuestwellTypography.sectionHeading(size: 12));
  Widget _panel(Widget child) => Material(color: const Color(0xFF19232D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3),
      side: const BorderSide(color: Color(0xFF65563D))),
    child: Padding(padding: const EdgeInsets.all(16), child: child));

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  String _group(AdventurerInventoryItem item) =>
      QuestwellLoadoutModel.inventoryGroup(item.category);

  @override
  Widget build(BuildContext context) {
    final availableItems = widget.items.where((item) =>
        !QuestwellEquipmentPolicy.isRetired(item.slug)).toList();
    final masteryItem = availableItems.where((item) => item.owned &&
      item.slug == QuestwellMasteryRelic.slugs[widget.archetype]).firstOrNull;
    final owned = availableItems.where((item) => item.owned).length;
    final equipped = availableItems.where((item) => item.equipped).toList();
    const categories = ['All categories','Outfits','Gear','Familiars','Effects','Hearth'];
    final category = categories.contains(_category) ? _category : 'All categories';
    final visible = availableItems.where((item) =>
      (_section != 'Collections' || item.collectionKey != null) &&
      (_collection == 'All collections' || item.collectionKey == _collection ||
        (_collection == 'Trophies' && (item.milestoneLevel != null || QuestwellMasteryRelic.supports(item.slug)))) &&
      (_ownership == 'All items' || (_ownership == 'Equipped' ? item.equipped : item.owned)) &&
      (category == 'All categories' || _group(item) == category) &&
      ('${item.name} ${item.description} ${item.collectionKey ?? ''}'.toLowerCase()
        .contains(_query.toLowerCase().trim()))).toList();
    return ListView(physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28), children: [
        Row(children: [
          IconButton(tooltip: 'Back to the Hearth', onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: _gold)),
          const SizedBox(width: 8),
          Expanded(child: Text('ADVENTURER', style: QuestwellTypography.sectionHeading(size: 12))),
        ]),
        const SizedBox(height: 6),
        Text('Make yourself at home.', style: _text(15, color: _muted)),
        const SizedBox(height: 16),
        _panel(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Existing approved avatar renderer and assets remain the single source of truth.
          QuestwellEquippedAvatar(archetype: widget.archetype, avatarBodyType: widget.bodyType,
            height: 250, artHeightFactor: .96, showRelic: widget.mastered,
            equippedSlugs: {for (final item in equipped) item.renderKey: item.slug}),
          if (_section == 'Inventory' && category == 'Hearth' && availableItems.any((item) => (item.category == 'room' || item.category == 'wall_art') && item.owned)) ...[
            const SizedBox(height: 16),
            _heading('YOUR HEARTH'),
            const SizedBox(height: 8),
            QuestwellHearthPixelScene(height: 260, archetype: widget.archetype,
              avatarBodyType: widget.bodyType, showRelic: widget.mastered,
              equippedSlugs: {for (final item in equipped) item.renderKey: item.slug}),
          ],
          const SizedBox(height: 10),
          _heading(_label(widget.archetype)),
          const SizedBox(height: 6),
          Wrap(spacing: 14, runSpacing: 6, children: [
            Text('Level ${widget.level}', style: _text(14, bold: true)),
            Text('${widget.xp} XP', style: _text(14, color: _muted)),
            Text('${widget.coins} coins', style: _text(14, color: _gold)),
          ]),
        ])),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final value in const ['Equipped','Inventory','Collections'])
            ChoiceChip(labelStyle: QuestwellTypography.body(fontSize: 14),
              label: Text(value == 'Inventory' ? 'Inventory · $owned' : value),
              selected: _section == value,
              onSelected: (_) => setState(() {
                _section = value;
                _ownership = value == 'Equipped' ? 'Equipped' : 'Owned';
                _collection = 'All collections';
                _category = 'All categories';
              })),
          OutlinedButton.icon(onPressed: () => _editAppearance(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Adventurer')),
        ]),
        const SizedBox(height: 18),
        if (_section == 'Equipped') ...[
          _heading('EQUIPPED NOW'),
          const SizedBox(height: 8),
          Text('Your active loadout. Open Inventory to swap gear or place Hearth items.',
            style: _text(14, color: _muted)),
          const SizedBox(height: 12),
          if (equipped.isEmpty) _panel(Text('Nothing equipped yet.', style: _text(14, color: _muted))),
          for (final item in equipped)
            Padding(key: ValueKey('equipped-${item.id}'), padding: const EdgeInsets.only(bottom: 12), child: _item(item)),
        ] else ...[
          _heading(_section == 'Collections' ? 'COLLECTIONS' : 'INVENTORY'),
          const SizedBox(height: 8),
          Text(_section == 'Collections'
            ? 'Complete sets and keep seasonal finds in your collection.'
            : '$owned owned · ${equipped.length} equipped',
            style: _text(14, color: _muted)),
          const SizedBox(height: 10),
          TextField(controller: _searchController, onChanged: (v) => setState(() => _query = v),
            style: _text(14), decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search your items',
              border: OutlineInputBorder())),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            for (final value in categories) Padding(padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(label: Text(value), selected: category == value,
                onSelected: (_) => setState(() => _category = value))),
          ])),
          if (_section == 'Collections') ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(value: _collection,
              decoration: const InputDecoration(labelText: 'Collection', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: 'All collections', child: Text('All collections')),
                for (final key in (availableItems.map((i) => i.collectionKey).whereType<String>().toSet().toList()..sort()))
                  DropdownMenuItem(value: key, child: Text(_label(key.replaceAll('-', ' ')))),
              ],
              onChanged: (v) => setState(() => _collection = v ?? 'All collections')),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final value in const ['Owned','Equipped','All items'])
              ChoiceChip(label: Text(value), selected: _ownership == value,
                onSelected: (_) => setState(() => _ownership = value)),
          ]),
          const SizedBox(height: 14),
          if (visible.isEmpty) _panel(Text('No items match this view.', style: _text(14, color: _muted))),
          for (final item in visible)
            Padding(key: ValueKey('inventory-${item.id}'), padding: const EdgeInsets.only(bottom: 12), child: _item(item)),
          OutlinedButton(onPressed: widget.onMarket,
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: _gold,
              textStyle: QuestwellTypography.body(fontSize: 14, fontWeight: FontWeight.w700)),
            child: const Text('Browse Market')),
        ],
        const SizedBox(height: 22),
        _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('CLASS MASTERY'),
          const SizedBox(height: 10),
          Center(child: QuestwellMasteryRelic(archetype: widget.archetype, size: 112)),
          const SizedBox(height: 8),
          Text(QuestwellMasteryRelic.names[widget.archetype] ?? widget.relicName,
            style: _text(16, bold: true)),
          const SizedBox(height: 6),
          Text(widget.mastered ? 'A keepsake of your class mastery. Yours to display.'
            : '${widget.collectionOwned} of ${widget.collectionTotal} class items collected.',
            style: _text(14, color: _muted)),
          if (masteryItem != null && masteryItem.category == 'room' && widget.onPlace != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: widget.busyItem != null || widget.savingAppearance ? null : () => _place(masteryItem),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48),
                foregroundColor: _gold, textStyle: QuestwellTypography.control()),
              child: Text(masteryItem.equipped ? 'Move relic in Hearth' : 'Place relic in Hearth')),
            if (masteryItem.equipped) TextButton(
              onPressed: widget.busyItem != null || widget.savingAppearance ? null : () => widget.onUnequip(masteryItem.id),
              child: const Text('Return relic to inventory')),
          ],
          if (widget.canClaim) Padding(padding: const EdgeInsets.only(top: 10),
            child: FilledButton(style: FilledButton.styleFrom(textStyle: QuestwellTypography.body(fontSize: 14, fontWeight: FontWeight.w700)), onPressed: widget.claiming ? null : widget.onClaim,
              child: Text(widget.claiming ? 'Claiming…' : 'Claim mastery relic'))),
        ])),
      ]);
  }

  Future<void> _editAppearance(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF19232D),
      builder: (ctx) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _heading('EDIT ADVENTURER'),
          const SizedBox(height: 14),
          Text('Body style', style: _text(14, color: _muted)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final value in const ['male','female','neutral'])
              ChoiceChip(label: Text(value == 'neutral' ? 'Gender neutral' : _label(value)),
                selected: widget.bodyType == value,
                onSelected: widget.savingAppearance ? null : (_) => widget.onBody(value)),
          ]),
          const SizedBox(height: 18),
          Text('Class', style: _text(14, color: _muted)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final value in const ['scholar','scout','alchemist','guardian','wanderer'])
              ChoiceChip(label: Text(_label(value)), selected: widget.archetype == value,
                avatar: QuestwellClassEmblem(archetype: value),
                onSelected: widget.savingAppearance ? null : (_) => widget.onClass(value)),
          ]),
          const SizedBox(height: 14),
          Text(widget.savingAppearance ? 'Saving your adventurer…' : widget.description,
            style: _text(13, color: _muted)),
          const SizedBox(height: 16),
          FilledButton(onPressed: widget.savingAppearance ? null : () => Navigator.pop(ctx),
            child: const Text('Done')),
        ]))));
  }

  Future<void> _place(AdventurerInventoryItem item) async {
    final pick = await showRoomPicker(context, name: item.name, id: item.id,
      slug: item.slug, currentSlot: item.equipped ? item.roomSlot ?? 'right' : null,
      archetype: widget.archetype, bodyType: widget.bodyType,
      equippedSlugs: {for (final i in widget.items.where((i) => i.equipped)) i.renderKey: i.slug},
      occupants: {for (final i in widget.items.where((i) => i.category == item.category && i.equipped))
        i.roomSlot ?? 'right': RoomOccupant(i.id, i.name)});
    if (pick != null && mounted) await widget.onPlace?.call(item.id, pick.slot, pick.expectedOccupant);
  }

  Widget _item(AdventurerInventoryItem item) {
    final busy = widget.busyItem != null || widget.savingAppearance;
    final ready = QuestwellEquipmentPolicy.isReady(item.slug, item.category);
    final bodyLocked = !QuestwellEquipmentPolicy.supportsBody(item.slug, widget.bodyType);
    final room = item.category == 'room';
    final wallArt = item.category == 'wall_art';
    final outfit = item.category == 'chest';
    final movable = room || QuestwellWallArt.isSide(item.slug);
    final status = item.equipped ? (room ? 'Placed' : wallArt ? 'Hung' : 'Equipped') : item.owned ? 'Owned' : 'Locked';
    return _panel(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        QuestwellItemPixelArt(slug: item.slug, category: item.category, archetype: item.archetype, size: 48),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: _text(17, bold: true)),
          const SizedBox(height: 4),
          Text('$status · ${_label(item.category)}', style: _text(13,
            color: item.equipped ? const Color(0xFF90D7BC) : _gold)),
        ])),
      ]),
      if (item.description.isNotEmpty) ...[
        const SizedBox(height: 10), Text(item.description, style: _text(14, color: _muted)),
      ],
      if (outfit && item.equipped) ...[
        const SizedBox(height: 8),
        Text('Return to your default ${_label(widget.archetype)} outfit. ${item.name} stays in your inventory.',
          style: _text(14, color: _muted)),
      ],
      if (item.milestoneLevel != null && item.owned) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(item.unlockedAt == null ? 'Level ${item.milestoneLevel} trophy'
          : '${item.source == 'level_milestone' ? 'Earned' : 'Added'} ${DateFormat('MMM d, yyyy').format(item.unlockedAt!.toLocal())}',
          style: _text(13, color: _muted))),
      if (bodyLocked) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(QuestwellBodyFitLabels.availability(item.slug), style: _text(13, color: _gold))),
      if (item.classLocked) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text('Requires ${_label(item.archetype ?? '')} class.', style: _text(13, color: _gold))),
      const SizedBox(height: 12),
      if (movable && item.owned && ready && widget.onPlace != null)
        OutlinedButton(onPressed: busy || item.classLocked ? null : () => _place(item),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: _gold, textStyle: QuestwellTypography.body(fontSize: 14, fontWeight: FontWeight.w700)),
          child: Text(item.equipped ? 'Move in Hearth' : wallArt ? 'Hang in Hearth' : 'Place in Hearth')),
      if (!(movable && item.owned && !item.equipped && ready && widget.onPlace != null))
      OutlinedButton(
        onPressed: busy ? null : item.equipped ? () => widget.onUnequip(item.id)
          : !item.owned && item.shop ? widget.onMarket
          : item.owned && !item.classLocked && !bodyLocked && ready ? () => widget.onEquip(item.id) : null,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: _gold,
              textStyle: QuestwellTypography.body(fontSize: 14, fontWeight: FontWeight.w700)),
        child: Text(widget.busyItem == item.id ? 'Saving…' : item.equipped ? (room || wallArt ? 'Remove from Hearth' : outfit ? 'Wear ${_label(widget.archetype)} outfit' : 'Unequip')
          : !item.owned ? (item.shop ? 'View in Market' : item.milestoneLevel != null ? 'Unlocks at level ${item.milestoneLevel}' : item.slug == 'first-journey-trophy' ? 'Unlocks at level 5' : 'Earn through progression')
          : bodyLocked ? 'Fit unavailable' : item.classLocked ? 'Class restricted' : !ready ? (room ? 'Coming soon' : 'Equip unavailable') : (room ? 'Place in Hearth' : wallArt ? 'Hang in Hearth' : 'Equip'))),
    ]));
  }
}
