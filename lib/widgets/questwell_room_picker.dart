import 'package:flutter/material.dart';
import 'questwell_account_dialog_flow.dart';
import 'questwell_pixel_art.dart';
import 'questwell_hearth_decor.dart';
import 'questwell_wall_art.dart';
import 'questwell_milestone_reward.dart';
import 'questwell_mastery_relic.dart';
import '../services/questwell_cosmetic_models.dart';

export '../services/questwell_cosmetic_models.dart' show RoomOccupant;

class RoomPlacement {
  const RoomPlacement(this.slot, this.expectedOccupant);
  final String slot;
  final String? expectedOccupant;
}

Future<RoomPlacement?> showRoomPicker(
  BuildContext context, {
  required String name,
  required String id,
  required String slug,
  required String archetype,
  required String bodyType,
  required Map<String, String> equippedSlugs,
  required Map<String, RoomOccupant> occupants,
  Map<String, String>? placementChoices,
  Map<String, String> hearthProfilesBySlug = const {},
  Map<String, QuestwellHearthRenderSpec> hearthRenderBySlug = const {},
  String? hearthProfileKey,
  QuestwellHearthRenderSpec? hearthRenderSpec,
  String? currentSlot,
  QuestwellAccountDialogFlow? flow,
}) =>
    QuestwellAccountDialogFlow.show<RoomPlacement>(
      context: context,
      flow: flow,
      builder: (_) => _RoomPicker(
        name: name,
        id: id,
        slug: slug,
        archetype: archetype,
        bodyType: bodyType,
        equippedSlugs: equippedSlugs,
        occupants: occupants,
        placementChoices: placementChoices,
        hearthProfilesBySlug: hearthProfilesBySlug,
        hearthRenderBySlug: hearthRenderBySlug,
        hearthProfileKey: hearthProfileKey,
        hearthRenderSpec: hearthRenderSpec,
        currentSlot: currentSlot,
      ),
    );

class _RoomPicker extends StatefulWidget {
  const _RoomPicker({
    required this.name,
    required this.id,
    required this.slug,
    required this.archetype,
    required this.bodyType,
    required this.equippedSlugs,
    required this.occupants,
    required this.hearthProfilesBySlug,
    required this.hearthRenderBySlug,
    this.placementChoices,
    this.hearthProfileKey,
    this.hearthRenderSpec,
    this.currentSlot,
  });

  final String name, id, slug, archetype, bodyType;
  final Map<String, String> equippedSlugs;
  final Map<String, RoomOccupant> occupants;
  final Map<String, String>? placementChoices;
  final Map<String, String> hearthProfilesBySlug;
  final Map<String, QuestwellHearthRenderSpec> hearthRenderBySlug;
  final String? hearthProfileKey;
  final QuestwellHearthRenderSpec? hearthRenderSpec;
  final String? currentSlot;

  @override
  State<_RoomPicker> createState() => _RoomPickerState();
}

class _RoomPickerState extends State<_RoomPicker> {
  late final labels = Map<String, String>.from(
      widget.placementChoices?.isNotEmpty == true
          ? widget.placementChoices!
          : QuestwellHearthDecor.choices(widget.slug))
    ..removeWhere((slot, _) =>
        slot == 'bookshelf_top' &&
        widget.equippedSlugs['room:left'] != 'walnut-bookshelf' &&
        widget.equippedSlugs['room:right'] != 'walnut-bookshelf');
  late String _slot = labels.containsKey(widget.currentSlot)
      ? widget.currentSlot!
      : !QuestwellMasteryRelic.supports(widget.slug) &&
              labels.containsKey('right') &&
              !widget.occupants.containsKey('right')
          ? 'right'
          : labels.keys.firstWhere(
              (slot) => !widget.occupants.containsKey(slot),
              orElse: () => labels.keys.first);
  bool get _legacyPlacement =>
      widget.currentSlot != null && !labels.containsKey(widget.currentSlot);
  bool get _active =>
      mounted && (QuestwellAccountDialogFlow.of(context)?.active ?? true);

  Future<void> _save() async {
    if (!_active) return;
    final occupant = widget.occupants[_slot];
    if (occupant != null && occupant.id != widget.id) {
      final confirmed = await QuestwellAccountDialogFlow.show<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF19232D),
                  title: Text('Replace ${occupant.name}?'),
                  content: Text(
                      '${occupant.name} will return to your inventory. You will still own it.'),
                  actions: [
                    TextButton(
                        onPressed: () =>
                            QuestwellAccountDialogFlow.pop(ctx, false),
                        child: const Text('Keep current item')),
                    FilledButton(
                        onPressed: () =>
                            QuestwellAccountDialogFlow.pop(ctx, true),
                        child: const Text('Replace item'))
                  ]));
      if (confirmed != true || !_active) return;
    }
    if (_active)
      QuestwellAccountDialogFlow.pop(
          context, RoomPlacement(_slot, occupant?.id));
  }

  @override
  Widget build(BuildContext context) {
    final wallArt = widget.hearthRenderSpec?.renderKind == 'wall_art_sprite' ||
        widget.hearthProfileKey == 'wall_art_side' ||
        widget.hearthProfileKey == 'wall_art_center' ||
        QuestwellWallArt.isSide(widget.slug) ||
        widget.slug == 'moonlit-woodland';
    final prefix = wallArt ? 'wall_art' : 'room';
    final blockedByShelf = wallArt &&
        widget.equippedSlugs[
                'room:${_slot == 'wall_left' ? 'left' : 'right'}'] ==
            'walnut-bookshelf';
    final preview = Map<String, String>.from(widget.equippedSlugs)
      ..removeWhere((key, value) =>
          (key == prefix || key.startsWith('$prefix:')) && value == widget.slug)
      ..[wallArt && _slot == 'wall_center' ? 'wall_art' : '$prefix:$_slot'] =
          widget.slug;
    return Dialog(
        backgroundColor: const Color(0xFF111827),
        insetPadding: const EdgeInsets.all(12),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                  child: SingleChildScrollView(
                      key: const ValueKey('room-picker-scroll'),
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    '${wallArt ? 'Hang' : 'Place'} ${widget.name}',
                                    style: const TextStyle(
                                        fontSize: 21,
                                        color: Color(0xFFF0E5CC))),
                                const SizedBox(height: 8),
                                Text(QuestwellHearthSetting.supports(
                                        widget.slug)
                                    ? 'Preview your setting, then save. Your furniture stays in place.'
                                    : 'Choose a spot below. Preview first, then save.'),
                                if (QuestwellMasteryRelic.supports(widget.slug))
                                  const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                          'Display the relic on a surface, or choose one of three pedestal spots.')),
                                if (QuestwellMasteryRelic.supports(
                                        widget.slug) &&
                                    !labels.containsKey('bookshelf_top'))
                                  const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                          'Place a bookcase to unlock its top.')),
                                if (QuestwellMilestoneReward.isTrophy(
                                    widget.slug))
                                  const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                          'The mantel is always available. Place a bookcase in the Hearth to use its top; the collectible follows it when moved.')),
                                if (blockedByShelf)
                                  const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                          'The wall art keeps its balanced arrangement. Preview how it sits above the bookshelf.')),
                                if (_legacyPlacement)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                        'This item now has updated placement choices. Choose a new spot and save to move it.'),
                                  ),
                                const SizedBox(height: 12),
                                QuestwellHearthPixelScene(
                                  height: QuestwellMasteryRelic.supports(
                                          widget.slug)
                                      ? 260
                                      : 310,
                                  archetype: widget.archetype,
                                  avatarBodyType: widget.bodyType,
                                  equippedSlugs: preview,
                                  hearthProfileBySlug: {
                                    ...widget.hearthProfilesBySlug,
                                    if (widget.hearthProfileKey != null)
                                      widget.slug: widget.hearthProfileKey!,
                                  },
                                  hearthRenderBySlug: {
                                    ...widget.hearthRenderBySlug,
                                    if (widget.hearthRenderSpec != null)
                                      widget.slug: widget.hearthRenderSpec!,
                                  },
                                ),
                                const SizedBox(height: 12),
                                for (final entry in labels.entries)
                                  RadioListTile<String>(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8),
                                      activeColor: const Color(0xFFE4C586),
                                      selected: _slot == entry.key,
                                      selectedTileColor:
                                          const Color(0xFF243448),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          side: BorderSide(
                                              color: _slot == entry.key
                                                  ? const Color(0xFFE4C586)
                                                  : const Color(0xFF465568))),
                                      title: Text(entry.value),
                                      subtitle: Text(widget
                                                  .occupants[entry.key] ==
                                              null
                                          ? 'Available'
                                          : widget.occupants[entry.key]!.id ==
                                                  widget.id
                                              ? 'Placed here'
                                              : 'Replaces ${widget.occupants[entry.key]!.name}'),
                                      value: entry.key,
                                      groupValue: _slot,
                                      onChanged: (value) =>
                                          setState(() => _slot = value!)),
                              ])))),
              DecoratedBox(
                key: const ValueKey('room-picker-actions'),
                decoration: const BoxDecoration(
                    color: Color(0xFF111827),
                    border: Border(top: BorderSide(color: Color(0xFF465568)))),
                child: SafeArea(
                    top: false,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FilledButton(
                                  onPressed: _save,
                                  child: const Text('Save placement')),
                              TextButton(
                                  onPressed: () =>
                                      QuestwellAccountDialogFlow.pop(context),
                                  child: const Text('Cancel')),
                            ]))),
              ),
            ])));
  }
}
