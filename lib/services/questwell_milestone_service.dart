import 'package:flutter/material.dart';
import 'questwell_cosmetic_service.dart';
import '../widgets/questwell_milestone_reward.dart';
import '../widgets/questwell_room_picker.dart';

/// The database awards ownership. This flow only celebrates and optionally places it.
Future<bool> showQuestwellMilestones(BuildContext context, {
  required int previousLevel, required int level, required int xpAwarded, required int coinsAwarded,
}) async {
  final rewards = QuestwellMilestoneReward.crossed(previousLevel, level);
  if (rewards.isEmpty) return false;
  final place = await showDialog<bool>(context: context,
    builder: (_) => QuestwellMilestoneUnlockDialog(rewards: rewards, level: level,
      xpAwarded: xpAwarded, coinsAwarded: coinsAwarded));
  if (place != true || !context.mounted) return true;
  for (final reward in rewards) {
    try {
      final data = await QuestwellCosmeticService.load();
      if (!context.mounted) return true;
      final trophy = data.cosmetics.firstWhere((item) => item.slug == reward.slug && item.owned);
      final equipped = data.cosmetics.where((item) => item.equipped);
      final pick = await showRoomPicker(context, name: trophy.name, id: trophy.id,
        slug: trophy.slug, currentSlot: trophy.equipped ? trophy.roomSlot : null,
        archetype: data.profile.adventurerArchetype, bodyType: data.profile.avatarBodyType,
        equippedSlugs: {for (final item in equipped) item.renderKey: item.slug},
        occupants: {for (final item in equipped.where((item) => item.category == 'room'))
          item.roomSlot ?? 'right': RoomOccupant(item.id, item.name)});
      if (!context.mounted) return true;
      if (pick == null) continue;
      await QuestwellCosmeticService.place(trophy.id, pick.slot, pick.expectedOccupant);
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${reward.name} placed in your Hearth.')));
    } catch (_) {
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your trophy is safe in inventory. Open Adventurer to try placing it again.')));
    }
  }
  return true;
}
