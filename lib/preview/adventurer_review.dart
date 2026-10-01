import '../widgets/questwell_app_navigation.dart';
import 'package:flutter/material.dart';
import '../widgets/questwell_adventurer_view.dart';

class AdventurerReviewApp extends StatefulWidget {
  const AdventurerReviewApp({super.key});
  @override
  State<AdventurerReviewApp> createState() => _AdventurerReviewAppState();
}
class _AdventurerReviewAppState extends State<AdventurerReviewApp> {
  String _class = 'alchemist', _body = 'female';
  bool _glassesEquipped = false;
  bool _satchelEquipped = false;
  final Set<String> _otherEquipped = {};
  final Map<String, String> _roomSlots = {};
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true), home: Scaffold(backgroundColor: const Color(0xFF111827),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430),
        child: QuestwellAdventurerView(archetype: _class, bodyType: _body,
          level: 3, xp: 295, coins: 49, description: 'Choose a class and body style to preview your look. Sample data only.',
          mastered: false, collectionOwned: 5, collectionTotal: 6, relicName: 'Sample mastery relic',
          canClaim: false, onClaim: () {}, onBack: () => QuestwellNavigationScope.open(context, QuestwellDestination.hearth), onMarket: () => QuestwellNavigationScope.open(context, QuestwellDestination.market),
          onBody: (v) => setState(() => _body = v), onClass: (v) => setState(() => _class = v),
          onPlace: (id, slot, expected) async { setState(() {
            _roomSlots.removeWhere((key, value) => value == slot || key == id);
            _roomSlots[id] = slot;
          }); },
          onEquip: (id) => setState(() { if (id == 's') { _satchelEquipped = true; } else if (id == 'a') { _glassesEquipped = true; } else { _otherEquipped.add(id); } }),
          onUnequip: (id) => setState(() { _roomSlots.remove(id); if (id == 's') { _satchelEquipped = false; } else if (id == 'a') { _glassesEquipped = false; } else { _otherEquipped.remove(id); } }), items: [
            for (final art in [('fern-art', 'Fern Study', 'fern-study'), ('celestial-art', 'Celestial Study', 'celestial-study')])
              AdventurerInventoryItem(id: art.$1, name: art.$2, slug: art.$3, category: 'wall_art',
                description: 'Sample ownership. Choose the left or right wall.', owned: true,
                equipped: _roomSlots.containsKey(art.$1), roomSlot: _roomSlots[art.$1], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'painting', name: 'Moonlit Woodland', slug: 'moonlit-woodland', category: 'wall_art',
              description: 'Sample ownership. A landscape for the center wall; side paintings and furniture stay in place.', owned: true,
              equipped: _otherEquipped.contains('painting'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'bookshelf', name: 'Walnut Bookshelf', slug: 'walnut-bookshelf', category: 'room',
              description: 'Sample ownership. Warm walnut, worn books, and brass details for your Hearth.', owned: true,
              equipped: _roomSlots.containsKey('bookshelf'), roomSlot: _roomSlots['bookshelf'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'fern', name: 'Hearth Fern', slug: 'hearth-fern', category: 'room',
              description: 'Sample ownership. Green fronds in aged brass.', owned: true,
              equipped: _roomSlots.containsKey('fern'), roomSlot: _roomSlots['fern'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'chair', name: 'Burgundy Reading Chair', slug: 'burgundy-reading-chair', category: 'room',
              description: 'Sample ownership. Burgundy upholstery, walnut legs, and brass studs.', owned: true,
              equipped: _roomSlots.containsKey('chair'), roomSlot: _roomSlots['chair'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'table', name: 'Walnut Reading Table', slug: 'walnut-reading-table', category: 'room',
              description: 'Sample ownership. Worn books and candlelight beside your chair.', owned: true,
              equipped: _roomSlots.containsKey('table'), roomSlot: _roomSlots['table'], classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'm', name: 'Moonstone Brooch', slug: 'moonstone-brooch', category: 'accessory',
              description: 'Sample ownership. A little moonlight for the road ahead.', owned: true,
              equipped: _otherEquipped.contains('m'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'h', name: 'Tiny Wizard Hat', slug: 'tiny-wizard-hat', category: 'head',
              description: 'Sample ownership. Impractical. Essential.', owned: true, equipped: _otherEquipped.contains('h'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'n', name: 'Emerald Scholar Scarf', slug: 'emerald-scholar-scarf', category: 'neck',
              description: 'Sample ownership. Emerald cloth with warm gold trim.', owned: true, equipped: _otherEquipped.contains('n'), classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'a', name: 'Round Scholar Glasses', slug: 'round-scholar-glasses', category: 'face',
              description: 'Sample ownership. Try Equip and Unequip here.', owned: true, equipped: _glassesEquipped, classLocked: false, shop: true),
            AdventurerInventoryItem(id: 's', name: 'Leather Satchel', slug: 'leather-satchel', category: 'back',
              description: 'Sample ownership. Try Equip and Unequip here.', owned: true, equipped: _satchelEquipped, classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'suit', name: 'Business Suit', slug: 'starter-business-suit', category: 'chest',
              description: 'A polished starter look for getting things done.', owned: true, equipped: false, classLocked: false, shop: false),
            AdventurerInventoryItem(id: 'b', name: 'Brass Lantern', slug: 'brass-lantern', category: 'hands',
              description: 'Sample ownership. A warm light for your next small win.', owned: true,
              equipped: _otherEquipped.contains('b'), classLocked: false, shop: true),
          ]),
      ))),
    ));
}
