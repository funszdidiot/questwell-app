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
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true), home: Scaffold(backgroundColor: const Color(0xFF111827),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430),
        child: QuestwellAdventurerView(archetype: _class, bodyType: _body,
          level: 3, xp: 295, coins: 49, description: 'Choose a class and body style to preview your look. Sample data only.',
          mastered: false, collectionOwned: 1, collectionTotal: 2, relicName: 'Sample mastery relic',
          canClaim: false, onClaim: () {}, onBack: () {}, onMarket: () {},
          onBody: (v) => setState(() => _body = v), onClass: (v) => setState(() => _class = v),
          onEquip: (_) => setState(() => _glassesEquipped = true),
          onUnequip: (_) => setState(() => _glassesEquipped = false), items: [
            AdventurerInventoryItem(id: 'a', name: 'Round Scholar Glasses', slug: 'round-scholar-glasses', category: 'face',
              description: 'Sample ownership. Try Equip and Unequip here.', owned: true, equipped: _glassesEquipped, classLocked: false, shop: true),
            AdventurerInventoryItem(id: 'b', name: 'Sample lantern', slug: 'lantern', category: 'room',
              description: 'A warm light for your next small win.', owned: false, equipped: false, classLocked: false, shop: true),
          ]),
      ))),
    ));
}
