import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import '../services/questwell_hearth_draft.dart';
import 'questwell_pixel_art.dart';
import 'questwell_hearth_decor.dart';
import 'questwell_hearth_room_plan.dart';
import 'questwell_hearth_material.dart';

/// Kept off until the reviewed atomic-layout RPC is deployed and verified.
const decorateHearthEnabled = bool.fromEnvironment('QUESTWELL_DECORATE_HEARTH');

class QuestwellDecorateHearth extends StatefulWidget {
  const QuestwellDecorateHearth(
      {super.key,
      required this.snapshot,
      required this.layouts,
      required this.onSave});
  final QuestwellCosmeticsSnapshot snapshot;
  final QuestwellHearthLayouts layouts;
  final Future<void> Function(Map<String, String>) onSave;

  @override
  State<QuestwellDecorateHearth> createState() => _DecorateState();
}

class _DecorateState extends State<QuestwellDecorateHearth> {
  late final draft =
      QuestwellHearthDraft(widget.layouts.current, rooms: widget.layouts.rooms);
  String? selectedId;
  bool saving = false;
  bool saved = false;
  bool confirmingClose = false;
  String? error;
  List<QuestwellCosmetic> get owned => widget.snapshot.cosmetics
      .where((i) =>
          i.owned &&
          (i.category == 'room' || i.category == 'wall_art') &&
          i.hearthPlacements.isNotEmpty &&
          (i.requiredArchetype == null ||
              i.requiredArchetype ==
                  widget.snapshot.profile.adventurerArchetype))
      .toList();
  QuestwellCosmetic? get selected =>
      owned.where((i) => i.id == selectedId).firstOrNull;
  String name(String id) =>
      widget.snapshot.cosmetics.where((i) => i.id == id).firstOrNull?.name ??
      'Stored decoration';

  Future<void> place(QuestwellCosmetic item, String slot) async {
    final previous = draft.layout[slot];
    if (previous != null && previous != item.id && slot != 'setting') {
      final replace = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text('Replace ${name(previous)}?'),
                  content: const Text(
                      'It will return to your inventory when you save. You will still own it.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Keep it')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Preview replacement'))
                  ]));
      if (replace != true || !mounted) return;
    }
    setState(() => draft.place(item.id, slot));
  }

  Future<void> close() async {
    if (saving || confirmingClose) return;
    if (!saved && draft.dirty) {
      confirmingClose = true;
      final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: const Text('Discard this preview?'),
                  content: const Text('Your saved room will stay as it was.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Keep decorating')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Discard changes'))
                  ]));
      confirmingClose = false;
      if (discard != true || !mounted) return;
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> save() async {
    if (saving || !draft.dirty) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.onSave(draft.layout);
      if (!mounted) return;
      setState(() => saved = true);
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted)
        setState(() => error =
            'We could not confirm the save. Your preview is still here. Close and reopen Decorate Hearth to check the saved room before trying again.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = {for (final i in widget.snapshot.cosmetics) i.id: i};
    final equipment = <String, String>{
      for (final i in widget.snapshot.cosmetics)
        if (i.equipped && i.category != 'room' && i.category != 'wall_art')
          i.renderKey: i.slug,
      for (final entry in draft.layout.entries)
        if (catalog[entry.value] case final item?)
          (item.category == 'wall_art'
              ? (entry.key == 'wall_center'
                  ? 'wall_art'
                  : 'wall_art:${entry.key}')
              : 'room:${entry.key}'): item.slug
    };
    final problems = draft.problems(widget.snapshot.cosmetics);
    final item = selected;
    final choices =
        item?.hearthPlacements ?? const <QuestwellHearthPlacementOption>[];
    return PopScope<bool>(
        canPop: saved || (!saving && !draft.dirty),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) close();
        },
        child: Dialog(
            insetPadding: const EdgeInsets.all(8),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                      child: SingleChildScrollView(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                          child: Text('Decorate Hearth',
                                              style:
                                                  QuestwellHearthMaterial.serif(
                                                      MediaQuery.sizeOf(context)
                                                                  .width <
                                                              360
                                                          ? 20
                                                          : 24))),
                                      IconButton(
                                          tooltip: 'Close room editor',
                                          onPressed: saving ? null : close,
                                          icon: const Icon(Icons.close))
                                    ]),
                                    const Text(
                                        'Preview a room or decoration. Save when you’re ready.'),
                                    const SizedBox(height: 12),
                                    LayoutBuilder(
                                        builder: (context, constraints) {
                                      final height =
                                          constraints.maxWidth * .68 + 8;
                                      return SizedBox(
                                          height: height,
                                          child: Stack(children: [
                                            QuestwellHearthPixelScene(
                                                height: height,
                                                immersive: true,
                                                archetype: widget
                                                    .snapshot
                                                    .profile
                                                    .adventurerArchetype,
                                                avatarBodyType: widget.snapshot
                                                    .profile.avatarBodyType,
                                                equippedSlugs: equipment,
                                                hearthProfileBySlug: {
                                                  for (final i
                                                      in catalog.values)
                                                    if (i.hearthProfileKey !=
                                                        null)
                                                      i.slug:
                                                          i.hearthProfileKey!
                                                },
                                                hearthRenderBySlug: {
                                                  for (final i
                                                      in catalog.values)
                                                    if (i.hearthRenderSpec !=
                                                        null)
                                                      i.slug:
                                                          i.hearthRenderSpec!
                                                }),
                                            if (item != null)
                                              for (final choice in choices)
                                                if (QuestwellHearthDraft.wallSlots
                                                    .contains(choice.slot))
                                                  Positioned.fromRect(
                                                    rect: _wallBounds(
                                                        choice.slot,
                                                        equipment,
                                                        Size(
                                                            constraints
                                                                .maxWidth,
                                                            height)),
                                                    child: IgnorePointer(
                                                        child: DecoratedBox(
                                                      key: ValueKey(
                                                          'wall-marker-${choice.slot}'),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: const Color(
                                                                  0xFFFFD978),
                                                              width: 2)),
                                                    )),
                                                  )
                                                else if (choice.slot !=
                                                    'setting')
                                                  Align(
                                                      alignment: _marker(
                                                          item,
                                                          choice.slot,
                                                          equipment,
                                                          Size(
                                                              constraints
                                                                  .maxWidth,
                                                              height)),
                                                      child: Semantics(
                                                          label:
                                                              'Preview ${item.name}: ${choice.label}',
                                                          button: true,
                                                          child: SizedBox(
                                                              width: 48,
                                                              height: 48,
                                                              child: FilledButton(
                                                                  style: FilledButton.styleFrom(
                                                                      padding: EdgeInsets
                                                                          .zero,
                                                                      backgroundColor: draft.layout[choice.slot] == item.id
                                                                          ? const Color(
                                                                              0xFF245D4C)
                                                                          : const Color(
                                                                              0xFF47331C)),
                                                                  onPressed: saving
                                                                      ? null
                                                                      : () =>
                                                                          place(item, choice.slot),
                                                                  child: Icon(draft.layout[choice.slot] == item.id ? Icons.check : Icons.add_location_alt)))))
                                          ]));
                                    }),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                        initialValue: selectedId,
                                        isExpanded: true,
                                        isDense: false,
                                        itemHeight: null,
                                        decoration: const InputDecoration(
                                            labelText: 'Your decorations'),
                                        items: [
                                          for (final i in owned)
                                            DropdownMenuItem(
                                                value: i.id,
                                                child: Text(i.name))
                                        ],
                                        onChanged: saving
                                            ? null
                                            : (value) => setState(() {
                                                  selectedId = value;
                                                  final selection = selected;
                                                  if (selection != null &&
                                                      selection.hearthPlacements
                                                          .any((p) =>
                                                              p.slot ==
                                                              'setting')) {
                                                    draft.switchRoom(
                                                        selection.id);
                                                  }
                                                })),
                                    if (owned.isEmpty)
                                      const Text(
                                          'Your owned decorations will appear here.'),
                                    if (item != null) ...[
                                      const SizedBox(height: 8),
                                      for (final choice in choices)
                                        if (choice.slot != 'setting')
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 6),
                                              child: OutlinedButton(
                                                  onPressed: saving
                                                      ? null
                                                      : () => place(
                                                          item, choice.slot),
                                                  child: Text(
                                                      '${choice.label} · ${_spotDetail(item, choice.slot)}')))
                                    ],
                                    const SizedBox(height: 12),
                                    const Text('In this preview',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    for (final entry in draft.layout.entries)
                                      ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(name(entry.value)),
                                          subtitle: Text(
                                              _labels[entry.key] ?? entry.key),
                                          trailing: IconButton(
                                              tooltip: entry.key == 'setting'
                                                  ? 'Use Original Hearth'
                                                  : 'Return to inventory',
                                              onPressed: saving
                                                  ? null
                                                  : () => setState(() {
                                                        draft.remove(entry.key);
                                                        if (entry.key ==
                                                            'setting') {
                                                          selectedId = null;
                                                        }
                                                      }),
                                              icon: const Icon(Icons
                                                  .remove_circle_outline))),
                                    for (final problem in problems)
                                      Text(problem,
                                          style: const TextStyle(
                                              color: Color(0xFFFFCD85))),
                                    if (error != null)
                                      Semantics(
                                          liveRegion: true,
                                          child: Text(error!)),
                                    const Text(
                                        'Wall hangings carry across rooms. Each room remembers its other decorations. Save and close keeps this preview.')
                                  ])))),
                  SafeArea(
                      top: false,
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FilledButton(
                                    onPressed: saving ||
                                            !draft.dirty ||
                                            problems.isNotEmpty ||
                                            error != null
                                        ? null
                                        : save,
                                    child: Text(saving
                                        ? 'Saving room…'
                                        : 'Save and close')),
                                if (!saving && !draft.dirty && error == null)
                                  const Text('This room is already saved.',
                                      textAlign: TextAlign.center),
                                Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 16,
                                    children: [
                                      TextButton(
                                          onPressed: saving || !draft.canUndo
                                              ? null
                                              : () => setState(() {
                                                    final previousRoom =
                                                        draft.room;
                                                    final roomSelected = selected
                                                            ?.hearthPlacements
                                                            .any((p) =>
                                                                p.slot ==
                                                                'setting') ??
                                                        false;
                                                    draft.undo();
                                                    if (roomSelected ||
                                                        draft.room !=
                                                            previousRoom) {
                                                      selectedId = draft
                                                          .layout['setting'];
                                                    }
                                                  }),
                                          child: const Text('Undo change')),
                                      TextButton(
                                          onPressed: saving ? null : close,
                                          child: const Text('Close'))
                                    ])
                              ])))
                ]))));
  }

  static const _labels = {
    'left': 'Back left',
    'right': 'Back right',
    'front': 'Reading corner',
    'side': 'Side table',
    'floor': 'Rug',
    'wall_left': 'Left wall',
    'wall_center': 'Center wall',
    'wall_right': 'Right wall',
    'mantel': 'Mantel',
    'bookshelf_top': 'Bookcase top',
    'window': 'Window',
    'setting': 'Room setting'
  };

  String _spotDetail(QuestwellCosmetic item, String slot) {
    final frontId = draft.layout['front'];
    final front =
        widget.snapshot.cosmetics.where((i) => i.id == frontId).firstOrNull;
    if (slot == 'left' &&
        item.hearthProfileKey == 'large_furniture' &&
        front?.hearthProfileKey == 'seating') {
      return 'Needs space beside the chair';
    }
    final previous = draft.layout[slot];
    return previous == null
        ? 'Available'
        : previous == item.id
            ? 'Placed here'
            : 'Replaces ${name(previous)}';
  }

  static Alignment _spot(String slot) => switch (slot) {
        'left' => const Alignment(-.65, .1),
        'right' => const Alignment(.65, .1),
        'front' => const Alignment(-.4, .6),
        'side' => const Alignment(-.8, .7),
        'wall_left' => const Alignment(-.45, -.7),
        'wall_center' => const Alignment(0, -.7),
        'wall_right' => const Alignment(.45, -.7),
        'window' => const Alignment(.75, -.4),
        'bookshelf_top' => const Alignment(-.65, -.25),
        'mantel' => const Alignment(-.2, -.35),
        _ => const Alignment(0, .8)
      };

  // Wall spots are outlined in the scene. Their full-size labeled buttons
  // below the preview remain separate even on the narrow chimney layout.
  Rect _wallBounds(String slot, Map<String, String> equipment, Size scene) =>
      QuestwellHearthDecor.wallArtBounds(scene, slot,
          hallowed:
              QuestwellHearthSetting.fromSlug(equipment['room:setting']) ==
                  QuestwellHearthSetting.hallowedHearth);

  Alignment _marker(QuestwellCosmetic item, String slot,
      Map<String, String> equipment, Size scene) {
    if (slot == 'bookshelf_top') {
      final shelfSlot =
          equipment['room:right'] == 'walnut-bookshelf' ? 'right' : 'left';
      final rect = QuestwellHearthDecor.bounds(
          slug: 'walnut-bookshelf',
          slot: shelfSlot,
          scene: scene,
          equipment: equipment,
          profileKey: 'large_furniture');
      return QuestwellHearthRoomPlan.marker(
          Rect.fromCenter(center: rect.topCenter, width: 1, height: 1), scene);
    }
    if (item.hearthProfileKey case final profile?) {
      if ([
        'large_furniture',
        'seating',
        'side_table',
        'plant',
        'pedestal_light'
      ].contains(profile)) {
        final rect = QuestwellHearthDecor.bounds(
            slug: item.slug,
            slot: slot,
            scene: scene,
            equipment: equipment,
            profileKey: profile,
            renderSpec: item.hearthRenderSpec);
        if (rect != Rect.zero)
          return QuestwellHearthRoomPlan.marker(rect, scene);
      }
    }
    return _spot(slot);
  }
}
