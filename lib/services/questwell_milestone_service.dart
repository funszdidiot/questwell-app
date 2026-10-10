import 'package:flutter/material.dart';
import '../widgets/questwell_account_dialog_flow.dart';
import 'questwell_cosmetic_service.dart';
import '../widgets/questwell_milestone_reward.dart';
import '../widgets/questwell_room_picker.dart';

/// The database awards ownership. This flow only celebrates and optionally places it.
Future<bool> showQuestwellMilestones(
  BuildContext context, {
  required int previousLevel,
  required int level,
  required int xpAwarded,
  required int coinsAwarded,
  QuestwellAccountDialogFlow? flow,
  void Function(SnackBar)? showFeedback,
  Future<QuestwellCosmeticsSnapshot> Function() loadAppearance =
      QuestwellCosmeticService.load,
  Future<void> Function(String, String, String?) placeTrophy =
      QuestwellCosmeticService.place,
}) async {
  void feedback(SnackBar snackBar) {
    if (showFeedback != null) {
      showFeedback(snackBar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  bool active() => context.mounted && (flow?.active ?? true);
  if (!active()) return true;
  final rewards = QuestwellMilestoneReward.crossed(previousLevel, level);
  if (rewards.isEmpty) return false;
  final place = await QuestwellAccountDialogFlow.show<bool>(
      context: context,
      flow: flow,
      builder: (_) => QuestwellMilestoneUnlockDialog(
          rewards: rewards,
          level: level,
          xpAwarded: xpAwarded,
          coinsAwarded: coinsAwarded));
  if (place != true || !active()) return true;
  for (final reward in rewards) {
    if (!active()) return true;
    try {
      final data = await loadAppearance();
      if (!active()) return true;
      final trophy = data.cosmetics
          .firstWhere((item) => item.slug == reward.slug && item.owned);
      final equipped = data.cosmetics.where((item) => item.equipped);
      final pick = await showRoomPicker(context,
          flow: flow,
          name: trophy.name,
          id: trophy.id,
          slug: trophy.slug,
          currentSlot: trophy.equipped ? trophy.roomSlot : null,
          archetype: data.profile.adventurerArchetype,
          bodyType: data.profile.avatarBodyType,
          equippedSlugs: {
            for (final item in equipped) item.renderKey: item.slug
          },
          occupants: {
            for (final item
                in equipped.where((item) => item.category == 'room'))
              item.roomSlot ?? 'right': RoomOccupant(item.id, item.name)
          });
      if (!active()) return true;
      if (pick == null) continue;
      await placeTrophy(trophy.id, pick.slot, pick.expectedOccupant);
      if (!active()) return true;
      feedback(
          SnackBar(content: Text('${reward.name} placed in your Hearth.')));
    } catch (_) {
      if (!active()) return true;
      feedback(const SnackBar(
          content: Text(
              'Your trophy is safe in inventory. Open Adventurer to try placing it again.')));
    }
  }
  return true;
}
