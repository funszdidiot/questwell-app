import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_first_journey.dart';
import '../widgets/questwell_starlit_orrery.dart';
import '../widgets/questwell_milestone_reward.dart';
import '../widgets/questwell_home_overview.dart';

/// Account-free fixture matching the founder's fully decorated Guardian Hearth.
class HearthPolishReviewApp extends StatefulWidget {
  const HearthPolishReviewApp({super.key, this.firstJourney = false, this.orrery = false});
  final bool firstJourney, orrery;
  @override
  State<HearthPolishReviewApp> createState() => _HearthPolishReviewAppState();
}
class _HearthPolishReviewAppState extends State<HearthPolishReviewApp> {
  double width = 390;
  String body = 'male';
  bool shelfRight = false;
  bool showAvatar = true;
  bool onMantel = false;
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(), home: Scaffold(backgroundColor: const Color(0xFF111827),
      body: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: 16),
        Text(widget.firstJourney ? 'Level ${widget.orrery ? 10 : 5} milestone · sample profile' : 'Hearth polish · sample profile', style: const TextStyle(fontSize: 20)),
        if (widget.firstJourney) Builder(builder: (ctx) => Wrap(spacing: 16, children: [
          TextButton(onPressed: () => setState(() => onMantel = !onMantel),
            child: Text(onMantel ? 'Trophy: mantel' : 'Trophy: bookcase')),
          TextButton(onPressed: () async {
            await showDialog<bool>(context: ctx, builder: (_) => QuestwellMilestoneUnlockDialog(
              rewards: [QuestwellMilestoneReward.all[widget.orrery ? 1 : 0]],
              level: widget.orrery ? 10 : 5, xpAwarded: 20, coinsAwarded: 10));
          }, child: Text('Preview level ${widget.orrery ? 10 : 5} reward')),
        ])),
        Wrap(spacing: 20, crossAxisAlignment: WrapCrossAlignment.center, children: [
          DropdownButton<double>(value: width, items: [320.0,390.0].map((w) => DropdownMenuItem(value: w, child: Text('${w.toInt()} px'))).toList(),
            onChanged: (w) => setState(() => width = w!)),
          DropdownButton<String>(value: body, items: ['male','female','neutral'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (b) => setState(() => body = b!)),
          TextButton(onPressed: () => setState(() => showAvatar = !showAvatar), child: Text(showAvatar ? 'Hide avatar' : 'Show avatar')),
          TextButton(onPressed: () => setState(() => shelfRight = !shelfRight), child: Text(shelfRight ? 'Bookshelf: right' : 'Bookshelf: left')),
        ]),
        Wrap(spacing: 28, runSpacing: 20, alignment: WrapAlignment.center, children: [
          SizedBox(width: width, child: Column(children: [
            QuestwellHomeHeader(onOpen: (_) {}),
            const SizedBox(height: 10),
            QuestwellHearthPixelScene(height: 342, archetype: 'guardian', avatarBodyType: body, showAvatar: showAvatar,
              equippedSlugs: {
                'room:${shelfRight ? 'right' : 'left'}': 'walnut-bookshelf',
                'room:${shelfRight ? 'front' : 'right'}': 'burgundy-reading-chair',
                'room:${shelfRight ? 'left' : 'front'}': 'hearth-fern',
                if (widget.firstJourney) 'room:${onMantel ? 'mantel' : 'bookshelf_top'}': widget.orrery ? QuestwellStarlitOrrery.slug : QuestwellFirstJourney.slug,
                'room:side': 'walnut-reading-table', 'wall_art': 'moonlit-woodland',
                'wall_art:wall_left': 'fern-study', 'wall_art:wall_right': 'celestial-study',
                'neck': 'emerald-scholar-scarf', 'back': 'leather-satchel',
                'hands': 'brass-lantern', 'accessory': 'moonstone-brooch',
              }),
          ])),
          SizedBox(width: width, child: QuestwellHomeCharacter(archetype: 'guardian', className: 'Guardian',
            level: widget.orrery ? 10 : widget.firstJourney ? 5 : 4, xp: widget.firstJourney ? 0 : 55, coins: 79, mastered: false,
            equippedNames: const ['Brass Lantern', 'Moonstone Brooch', 'Emerald Scholar Scarf', 'Leather Satchel'],
            decorNames: [if (widget.firstJourney) widget.orrery ? 'Starlit Orrery' : 'First Journey', 'Walnut Reading Table', 'Moonlit Woodland', 'Hearth Fern', 'Burgundy Reading Chair', 'Fern Study', 'Celestial Study', 'Walnut Bookshelf'],
            collection: const [], onCustomize: () {}, onMarket: () {})),
        ]),
        const SizedBox(height: 20),
      ]))));
}
