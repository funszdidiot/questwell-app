import 'package:flutter/material.dart';
import 'questwell_pixel_art.dart';
import 'questwell_hearth_decor.dart';
import 'questwell_wall_art.dart';
import 'questwell_milestone_reward.dart';

class RoomOccupant {
  const RoomOccupant(this.id, this.name);
  final String id, name;
}
class RoomPlacement {
  const RoomPlacement(this.slot, this.expectedOccupant);
  final String slot;
  final String? expectedOccupant;
}
Future<RoomPlacement?> showRoomPicker(BuildContext context, {
  required String name, required String id, required String slug,
  required String archetype, required String bodyType,
  required Map<String, String> equippedSlugs,
  required Map<String, RoomOccupant> occupants, String? currentSlot,
}) => showDialog<RoomPlacement>(context: context, builder: (_) => _RoomPicker(
  name: name, id: id, slug: slug, archetype: archetype, bodyType: bodyType,
  equippedSlugs: equippedSlugs, occupants: occupants, currentSlot: currentSlot));

class _RoomPicker extends StatefulWidget {
  const _RoomPicker({required this.name, required this.id, required this.slug,
    required this.archetype, required this.bodyType, required this.equippedSlugs,
    required this.occupants, this.currentSlot});
  final String name, id, slug, archetype, bodyType;
  final Map<String, String> equippedSlugs;
  final Map<String, RoomOccupant> occupants;
  final String? currentSlot;
  @override
  State<_RoomPicker> createState() => _RoomPickerState();
}
class _RoomPickerState extends State<_RoomPicker> {
  late final labels = Map<String, String>.from(QuestwellHearthDecor.choices(widget.slug))
    ..removeWhere((slot, _) => slot == 'bookshelf_top' &&
      widget.equippedSlugs['room:left'] != 'walnut-bookshelf' &&
      widget.equippedSlugs['room:right'] != 'walnut-bookshelf');
  late String _slot = labels.containsKey(widget.currentSlot)
    ? widget.currentSlot!
    : widget.currentSlot == null && labels.containsKey('right')
      ? 'right'
      : labels.keys.firstWhere((slot) => !widget.occupants.containsKey(slot),
          orElse: () => labels.keys.first);
  bool get _legacyPlacement => widget.currentSlot != null && !labels.containsKey(widget.currentSlot);
  Future<void> _save() async {
    final occupant = widget.occupants[_slot];
    if (occupant != null && occupant.id != widget.id) {
      final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF19232D),
        title: Text('Replace ${occupant.name}?'),
        content: Text('${occupant.name} will return to your inventory. You will still own it.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep current item')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Replace item'))]));
      if (confirmed != true || !mounted) return;
    }
    if (mounted) Navigator.pop(context, RoomPlacement(_slot, occupant?.id));
  }
  @override
  Widget build(BuildContext context) {
    final wallArt = QuestwellWallArt.isSide(widget.slug);
    final prefix = wallArt ? 'wall_art' : 'room';
    final blockedByShelf = wallArt && widget.equippedSlugs['room:${_slot == 'wall_left' ? 'left' : 'right'}'] == 'walnut-bookshelf';
    final preview = Map<String, String>.from(widget.equippedSlugs)
      ..removeWhere((key, value) => (key == prefix || key.startsWith('$prefix:')) && value == widget.slug)
      ..['$prefix:$_slot'] = widget.slug;
    return Dialog(backgroundColor: const Color(0xFF111827), insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${wallArt ? 'Hang' : 'Place'} ${widget.name}', style: const TextStyle(fontSize: 21, color: Color(0xFFF0E5CC))),
            const SizedBox(height: 8),
            const Text('Choose a spot below. Preview first, then save.'),
            if (QuestwellMilestoneReward.isTrophy(widget.slug)) const Padding(padding: EdgeInsets.only(top: 8),
              child: Text('The mantel is always available. Place a bookcase in the Hearth to use its top; the trophy follows it when moved.')),
            if (blockedByShelf) const Padding(padding: EdgeInsets.only(top: 8),
              child: Text('The wall art keeps its balanced arrangement. Preview how it sits above the bookshelf.')),
            if (_legacyPlacement) const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('This item now has updated placement choices. Choose a new spot and save to move it.'),
            ),
            const SizedBox(height: 12),
            QuestwellHearthPixelScene(height: 310, archetype: widget.archetype,
              avatarBodyType: widget.bodyType, equippedSlugs: preview),
            const SizedBox(height: 12),
            for (final entry in labels.entries)
              RadioListTile<String>(contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                activeColor: const Color(0xFFE4C586),
                selected: _slot == entry.key, selectedTileColor: const Color(0xFF243448),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: _slot == entry.key ? const Color(0xFFE4C586) : const Color(0xFF465568))),
                title: Text('${entry.value} · ${widget.occupants[entry.key]?.name ?? "Empty"}'),
                value: entry.key, groupValue: _slot, onChanged: (value) => setState(() => _slot = value!)),
            const SizedBox(height: 8),
            FilledButton(onPressed: _save, child: const Text('Save placement')),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ])))));
  }
}
