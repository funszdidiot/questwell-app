import 'package:flutter/material.dart';
import 'questwell_cosmetic_service.dart';
import '../widgets/questwell_first_journey.dart';
import '../widgets/questwell_room_picker.dart';

/// The database awards ownership. This flow only celebrates and optionally places it.
Future<void> showFirstJourneyMilestone(BuildContext context, {
  required int level, required int xpAwarded, required int coinsAwarded,
}) async {
  final place = await showDialog<bool>(context: context,
    builder: (_) => FirstJourneyUnlockDialog(level: level,
      xpAwarded: xpAwarded, coinsAwarded: coinsAwarded));
  if (place != true || !context.mounted) return;
  try {
    final data = await QuestwellCosmeticService.load();
    if (!context.mounted) return;
    final trophy = data.cosmetics.firstWhere((item) => item.slug == QuestwellFirstJourney.slug && item.owned);
    final equipped = data.cosmetics.where((item) => item.equipped);
    final pick = await showRoomPicker(context, name: trophy.name, id: trophy.id,
      slug: trophy.slug, currentSlot: trophy.equipped ? trophy.roomSlot : null,
      archetype: data.profile.adventurerArchetype, bodyType: data.profile.avatarBodyType,
      equippedSlugs: {for (final item in equipped) item.renderKey: item.slug},
      occupants: {for (final item in equipped.where((item) => item.category == 'room'))
        item.roomSlot ?? 'right': RoomOccupant(item.id, item.name)});
    if (pick == null || !context.mounted) return;
    await QuestwellCosmeticService.place(trophy.id, pick.slot, pick.expectedOccupant);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('First Journey placed in your Hearth.')));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Your trophy is safe in inventory. Open Adventurer to try placing it again.')));
  }
}
