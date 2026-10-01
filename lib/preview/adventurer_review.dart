import '../widgets/questwell_app_navigation.dart';
import 'package:flutter/material.dart';
import 'review_loadout.dart';
import '../widgets/questwell_mastery_relic.dart';
import '../widgets/questwell_adventurer_view.dart';

class AdventurerReviewApp extends StatefulWidget {
  const AdventurerReviewApp({super.key, this.loadout, this.masteryPreview = false});
  final QuestwellReviewLoadout? loadout;
  final bool masteryPreview;
  @override
  State<AdventurerReviewApp> createState() => _AdventurerReviewAppState();
}
class _AdventurerReviewAppState extends State<AdventurerReviewApp> {
  late final _loadout = widget.loadout ?? QuestwellReviewLoadout();
  String get _class => _loadout.archetype;
  String get _body => _loadout.body;
  @override
  void initState() {
    super.initState();
    if (widget.masteryPreview && !_loadout.masterySeeded) {
      _loadout.mastered.add(_class); _loadout.masterySeeded = true;
    }
  }
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true), home: Scaffold(backgroundColor: const Color(0xFF111827),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430),
        child: QuestwellAdventurerView(archetype: _class, bodyType: _body,
          level: 3, xp: 295, coins: 49, description: 'Choose a class and body style to preview your look. Sample data only.',
          mastered: _loadout.mastered.contains(_class), collectionOwned: widget.masteryPreview ? 6 : 5, collectionTotal: 6, relicName: QuestwellMasteryRelic.names[_class]!,
          canClaim: widget.masteryPreview && !_loadout.mastered.contains(_class), onClaim: () => setState(() => _loadout.mastered.add(_class)), onBack: () => QuestwellNavigationScope.open(context, QuestwellDestination.hearth), onMarket: () => QuestwellNavigationScope.open(context, QuestwellDestination.market),
          onBody: (v) => setState(() => _loadout.body = v), onClass: (v) => setState(() {
            _loadout.archetype = v;
            _loadout.roomSlots.removeWhere((key, _) => QuestwellMasteryRelic.supports(key) && QuestwellMasteryRelic.classFor(key) != v);
          }),
          onPlace: (id, slot, expected) async { setState(() {
            _loadout.roomSlots.removeWhere((key, value) => value == slot || key == id);
            _loadout.roomSlots[id] = slot;
          }); },
          onEquip: (id) => setState(() { if (id == 's') { _loadout.satchel = true; } else if (id == 'a') { _loadout.glasses = true; } else { _loadout.otherEquipped.add(id); } }),
          onUnequip: (id) => setState(() { _loadout.roomSlots.remove(id); if (id == 's') { _loadout.satchel = false; } else if (id == 'a') { _loadout.glasses = false; } else { _loadout.otherEquipped.remove(id); } }), items: [
            for (final entry in QuestwellMasteryRelic.slugs.entries)
              AdventurerInventoryItem(id: entry.value, name: QuestwellMasteryRelic.names[entry.key]!,
                slug: entry.value, category: 'room', archetype: entry.key,
                description: 'A keepsake of class mastery. Display it on the mantel, bookcase, or a walnut pedestal.',
                owned: _loadout.mastered.contains(entry.key), equipped: _loadout.roomSlots.containsKey(entry.value),
                roomSlot: _loadout.roomSlots[entry.value], classLocked: entry.key != _class, shop: false),
            for (final art in [('fern-art', 'Fern Study', 'fern-study'), ('celestial-art', 'Celestial Study', 'celestial-study')])
              AdventurerInventoryItem(id: art.$1, name: art.$2, slug: art.$3, category: 'wall_art',
                description: 'Sample ownership. Choose the left or right wall.', owned: true,
                equipped: _loadout.roomSlots.containsKey(art.$1), roomSlot: _loadout.roomSlots[art.$1], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'painting', name: 'Moonlit Woodland', slug: 'moonlit-woodland', category: 'wall_art',
              description: 'Sample ownership. A landscape for the center wall; side paintings and furniture stay in place.', owned: true,
              equipped: _loadout.otherEquipped.contains('painting'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'bookshelf', name: 'Walnut Bookshelf', slug: 'walnut-bookshelf', category: 'room',
              description: 'Sample ownership. Warm walnut, worn books, and brass details for your Hearth.', owned: true,
              equipped: _loadout.roomSlots.containsKey('bookshelf'), roomSlot: _loadout.roomSlots['bookshelf'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'fern', name: 'Hearth Fern', slug: 'hearth-fern', category: 'room',
              description: 'Sample ownership. Green fronds in aged brass.', owned: true,
              equipped: _loadout.roomSlots.containsKey('fern'), roomSlot: _loadout.roomSlots['fern'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'chair', name: 'Burgundy Reading Chair', slug: 'burgundy-reading-chair', category: 'room',
              description: 'Sample ownership. Burgundy upholstery, walnut legs, and brass studs.', owned: true,
              equipped: _loadout.roomSlots.containsKey('chair'), roomSlot: _loadout.roomSlots['chair'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'table', name: 'Walnut Reading Table', slug: 'walnut-reading-table', category: 'room',
              description: 'Sample ownership. Worn books and candlelight beside your chair.', owned: true,
              equipped: _loadout.roomSlots.containsKey('table'), roomSlot: _loadout.roomSlots['table'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'm', name: 'Moonstone Brooch', slug: 'moonstone-brooch', category: 'accessory',
              description: 'Sample ownership. A little moonlight for the road ahead.', owned: true,
              equipped: _loadout.otherEquipped.contains('m'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'h', name: 'Tiny Wizard Hat', slug: 'tiny-wizard-hat', category: 'head',
              description: 'Sample ownership. Impractical. Essential.', owned: true, equipped: _loadout.otherEquipped.contains('h'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'n', name: 'Emerald Scholar Scarf', slug: 'emerald-scholar-scarf', category: 'neck',
              description: 'Sample ownership. Emerald cloth with warm gold trim.', owned: true, equipped: _loadout.otherEquipped.contains('n'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'a', name: 'Round Scholar Glasses', slug: 'round-scholar-glasses', category: 'face',
              description: 'Sample ownership. Try Equip and Unequip here.', owned: true, equipped: _loadout.glasses, classLocked: false, shop: true),
            AdventurerInventoryItem(id: 's', name: 'Leather Satchel', slug: 'leather-satchel', category: 'back',
              description: 'Sample ownership. Try Equip and Unequip here.', owned: true, equipped: _loadout.satchel, classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'suit', name: 'Business Suit', slug: 'starter-business-suit', category: 'chest',
              description: 'A polished starter look for getting things done.', owned: true, equipped: false, classLocked: false, shop: false),
            AdventurerInventoryItem(id: 'b', name: 'Brass Lantern', slug: 'brass-lantern', category: 'hands',
              description: 'Sample ownership. A warm light for your next small win.', owned: true,
              equipped: _loadout.otherEquipped.contains('b'), classLocked: false, shop: true),
          ]),
      ))),
    ));
}

