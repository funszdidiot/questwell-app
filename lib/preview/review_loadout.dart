/// Shared, account-free state across the mobile preview's screens.
class QuestwellReviewLoadout {
  String archetype = 'alchemist', body = 'female';
  bool masterySeeded = false;
  bool glasses = false, satchel = false;
  final otherEquipped = <String>{};
  final roomSlots = <String, String>{};
  final mastered = <String>{};
}
