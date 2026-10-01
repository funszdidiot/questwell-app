import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'questwell_typography.dart';

enum QuestwellDestination {
  hearth('Hearth', 'HomePage', Icons.home_outlined),
  quests('Quests', 'QuestBoardPage', Icons.assignment_outlined),
  bosses('Boss Battles', 'BossBattlesPage', Icons.shield_outlined),
  expedition('Expedition', 'ExpeditionPage', Icons.explore_outlined),
  market('Market', 'MarketPage', Icons.storefront_outlined),
  adventurer('Adventurer', 'AdventurerPage', Icons.person_outline),
  chronicle('Chronicle', 'ChroniclePage', Icons.menu_book_outlined);

  const QuestwellDestination(this.label, this.routeName, this.icon);
  final String label, routeName;
  final IconData icon;
}

/// The preview supplies local navigation; production uses the same named routes.
class QuestwellNavigationScope extends InheritedWidget {
  const QuestwellNavigationScope({super.key, required this.onSelect, required super.child});
  final ValueChanged<QuestwellDestination> onSelect;
  static void open(BuildContext context, QuestwellDestination destination) {
    final scope = context.dependOnInheritedWidgetOfExactType<QuestwellNavigationScope>();
    if (scope != null) {
      scope.onSelect(destination);
    } else {
      GoRouter.of(context).goNamed(destination.routeName);
    }
  }
  @override
  bool updateShouldNotify(QuestwellNavigationScope oldWidget) => onSelect != oldWidget.onSelect;
}

/// Shared, always-visible primary navigation, including loading and error states.
class QuestwellAppNavigation extends StatelessWidget {
  const QuestwellAppNavigation({super.key, required this.current, this.onSelect, this.allowCurrentSelection = false});
  final QuestwellDestination current;
  final bool allowCurrentSelection;
  final ValueChanged<QuestwellDestination>? onSelect;
  void _open(BuildContext context, QuestwellDestination destination) {
    if (destination == current && !allowCurrentSelection) return;
    if (onSelect != null) { onSelect!(destination); }
    else { QuestwellNavigationScope.open(context, destination); }
  }

  Future<void> _explore(BuildContext context) async {
    final destination = await showModalBottomSheet<QuestwellDestination>(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: const Color(0xFF152332),
      builder: (sheetContext) => SafeArea(top: false, child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * .8),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Text('Explore Questwell', style: QuestwellTypography.body(
                fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFFF0E5CC)))),
              IconButton(tooltip: 'Close Explore', onPressed: () => Navigator.pop(sheetContext),
                icon: const Icon(Icons.close, color: Color(0xFFE4C586))),
            ]),
            for (final item in QuestwellDestination.values)
              Semantics(selected: current == item, child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Icon(item.icon, color: const Color(0xFFE4C586)),
                title: Text(item.label, style: QuestwellTypography.control(color: const Color(0xFFF0E5CC))),
                subtitle: current == item ? Text('You are here', style: QuestwellTypography.body(
                  fontSize: 12, color: const Color(0xFFB9C7D7))) : null,
                trailing: current == item ? const Icon(Icons.check, color: Color(0xFFE4C586)) : null,
                onTap: () => Navigator.pop(sheetContext, item),
              )),
          ])),
      )),
    );
    if (context.mounted && destination != null) _open(context, destination);
  }

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF101C29),
    child: SafeArea(top: false, child: Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF665538)))),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _tab('Hearth', Icons.home_outlined, current == QuestwellDestination.hearth,
          () => _open(context, QuestwellDestination.hearth)),
        _tab('Quests', Icons.assignment_outlined, current == QuestwellDestination.quests,
          () => _open(context, QuestwellDestination.quests)),
        _tab('Explore', Icons.explore_outlined,
          ![QuestwellDestination.hearth, QuestwellDestination.quests].contains(current),
          () => _explore(context)),
      ]),
    )),
  );

  Widget _tab(String label, IconData icon, bool selected, VoidCallback onTap) => Expanded(
    child: Semantics(selected: selected, child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        foregroundColor: selected ? const Color(0xFFE4C586) : const Color(0xFFB9C7D7),
        backgroundColor: selected ? const Color(0xFF243343) : Colors.transparent),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 22), const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
          style: QuestwellTypography.body(fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    )),
  );
}
