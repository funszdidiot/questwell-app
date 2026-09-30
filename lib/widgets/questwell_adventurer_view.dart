import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';
import '../services/questwell_equipment_policy.dart';

class AdventurerInventoryItem {
  const AdventurerInventoryItem({required this.id, required this.name, required this.slug,
    required this.category, required this.description, required this.owned,
    required this.equipped, required this.classLocked, required this.shop,
    this.archetype});
  final String id, name, slug, category, description;
  final String? archetype;
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
    this.busyItem});
  final String archetype, bodyType, description, relicName;
  final int level, xp, coins, collectionOwned, collectionTotal;
  final List<AdventurerInventoryItem> items;
  final bool mastered, canClaim, savingAppearance, claiming;
  final String? busyItem;
  final ValueChanged<String> onBody, onClass, onEquip, onUnequip;
  final VoidCallback onClaim, onMarket, onBack;
  @override
  State<QuestwellAdventurerView> createState() => _QuestwellAdventurerViewState();
}

class _QuestwellAdventurerViewState extends State<QuestwellAdventurerView> {
  bool _inventory = false;
  String _ownership = 'Owned';
  String _category = 'All categories';
  static const _gold = Color(0xFFE4C586);
  static const _muted = Color(0xFFB9C7D7);
  TextStyle _text(double size, {bool bold = false, Color color = const Color(0xFFF0E5CC)}) =>
    GoogleFonts.roboto(fontSize: size, height: 1.4, color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
  String _label(String value) => value.isEmpty ? 'Other' : value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  Widget _heading(String title) => Text(title, style: QuestwellTypography.sectionHeading(size: 12));
  Widget _panel(Widget child) => Material(color: const Color(0xFF19232D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3),
      side: const BorderSide(color: Color(0xFF65563D))),
    child: Padding(padding: const EdgeInsets.all(16), child: child));

  @override
  Widget build(BuildContext context) {
    final owned = widget.items.where((item) => item.owned).length;
    final equipped = widget.items.where((item) => item.equipped).toList();
    final categories = widget.items.map((item) => item.category).toSet().toList()..sort();
    final category = categories.contains(_category) ? _category : 'All categories';
    final visible = widget.items.where((item) =>
      (_ownership == 'All items' || (_ownership == 'Equipped' ? item.equipped : item.owned)) &&
      (category == 'All categories' || item.category == category)).toList();
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
            equippedSlugs: {for (final item in equipped) item.category: item.slug}),
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
          ChoiceChip(labelStyle: GoogleFonts.roboto(fontSize: 14), label: const Text('Appearance'), selected: !_inventory,
            onSelected: (_) => setState(() => _inventory = false)),
          ChoiceChip(labelStyle: GoogleFonts.roboto(fontSize: 14), label: Text('Inventory · $owned'), selected: _inventory,
            onSelected: (_) => setState(() => _inventory = true)),
        ]),
        const SizedBox(height: 18),
        if (!_inventory) ...[
          _heading('BODY STYLE'),
          const SizedBox(height: 8),
          Text('Choose the look that feels like you.', style: _text(14, color: _muted)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final value in const ['male', 'female', 'neutral'])
              ChoiceChip(labelStyle: GoogleFonts.roboto(fontSize: 14), label: Text(value == 'neutral' ? 'Gender neutral' : _label(value)),
                selected: widget.bodyType == value,
                onSelected: widget.savingAppearance ? null : (_) => widget.onBody(value)),
          ]),
          const SizedBox(height: 22),
          _heading('YOUR CLASS'),
          const SizedBox(height: 8),
          Text('A style choice. Every class earns the same rewards.', style: _text(14, color: _muted)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final value in const ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer'])
              ChoiceChip(labelStyle: GoogleFonts.roboto(fontSize: 14), label: Text(_label(value)),
                avatar: QuestwellRelicPixelArt(archetype: value, size: 22),
                selected: widget.archetype == value,
                onSelected: widget.savingAppearance ? null : (_) => widget.onClass(value)),
          ]),
          const SizedBox(height: 12),
          Text(widget.savingAppearance ? 'Saving your appearance…' : widget.description,
            style: _text(14, color: _muted)),
        ] else ...[
          _heading('YOUR COLLECTION'),
          const SizedBox(height: 8),
          Text('${equipped.length} equipped · $owned owned', style: _text(14, color: _muted)),
          if (widget.items.any((item) => !QuestwellEquipmentPolicy.isReady(item.slug, item.category))) ...[
            const SizedBox(height: 8),
            Text('Round Scholar Glasses are ready to wear. More accessories are on the way.', style: _text(14, color: _gold)),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final value in const ['Owned', 'Equipped', 'All items'])
              ChoiceChip(labelStyle: GoogleFonts.roboto(fontSize: 14), label: Text(value), selected: _ownership == value,
                onSelected: (_) => setState(() => _ownership = value)),
          ]),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: category, key: ValueKey(category),
            isExpanded: true, decoration: InputDecoration(labelText: 'Category', labelStyle: GoogleFonts.roboto(fontSize: 14),
              border: OutlineInputBorder()),
            items: [DropdownMenuItem(value: 'All categories', child: Text('All categories', style: _text(14))),
              for (final value in categories) DropdownMenuItem(value: value, child: Text(_label(value), style: _text(14)))],
            onChanged: (value) => setState(() => _category = value ?? 'All categories')),
          const SizedBox(height: 14),
          if (visible.isEmpty) _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_ownership == 'Equipped' ? 'Nothing equipped here yet.' : 'No items in this view.',
              style: QuestwellTypography.sectionHeading(size: 11)),
            const SizedBox(height: 6),
            Text('Try another filter, or visit the Market to explore cosmetics.', style: _text(14, color: _muted)),
          ])),
          for (final item in visible) Padding(padding: const EdgeInsets.only(bottom: 12), child: _item(item)),
          OutlinedButton(onPressed: widget.onMarket,
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: _gold,
              textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w700)),
            child: const Text('Browse Market')),
        ],
        const SizedBox(height: 22),
        _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('CLASS MASTERY'),
          const SizedBox(height: 10),
          Text(widget.relicName, style: _text(16, bold: true)),
          const SizedBox(height: 6),
          Text(widget.mastered ? 'Mastery relic claimed.'
            : '${widget.collectionOwned} of ${widget.collectionTotal} class items collected.',
            style: _text(14, color: _muted)),
          if (widget.canClaim) Padding(padding: const EdgeInsets.only(top: 10),
            child: FilledButton(style: FilledButton.styleFrom(textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w700)), onPressed: widget.claiming ? null : widget.onClaim,
              child: Text(widget.claiming ? 'Claiming…' : 'Claim mastery relic'))),
        ])),
      ]);
  }

  Widget _item(AdventurerInventoryItem item) {
    final busy = widget.busyItem != null || widget.savingAppearance;
    final ready = QuestwellEquipmentPolicy.isReady(item.slug, item.category);
    final status = item.equipped ? 'Equipped' : item.owned ? 'Owned' : 'Locked';
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
      if (item.classLocked) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text('Requires ${_label(item.archetype ?? '')} class.', style: _text(13, color: _gold))),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: busy ? null : item.equipped ? () => widget.onUnequip(item.id)
          : !item.owned && item.shop ? widget.onMarket
          : item.owned && !item.classLocked && ready ? () => widget.onEquip(item.id) : null,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: _gold,
              textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w700)),
        child: Text(widget.busyItem == item.id ? 'Saving…' : item.equipped ? 'Unequip'
          : !item.owned ? (item.shop ? 'View in Market' : 'Earn through progression')
          : item.classLocked ? 'Class restricted' : !ready ? 'Equip unavailable' : 'Equip')),
    ]));
  }
}
