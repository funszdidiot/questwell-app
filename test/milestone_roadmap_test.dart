import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';
import 'package:project_momentum/widgets/questwell_next_reward.dart';
import 'package:project_momentum/widgets/questwell_home_overview.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/widgets/questwell_adventurer_view.dart';
import 'package:project_momentum/widgets/questwell_chronicle_entry.dart';
import 'package:project_momentum/pages/chronicle_page/chronicle_page_widget.dart';

QuestwellProfile profile({int level=4,int xp=355}) => QuestwellProfile(level:level,totalXp:xp,
  levelXpOffset:45,coinBalance:79,currentEnergyMode:'normal',onboardingCompleted:true,
  adventurerArchetype:'alchemist',avatarBodyType:'male');
QuestwellCosmetic trophy({bool owned=false,String source='level_milestone',int level=5}) => QuestwellCosmetic.fromJson({
  'id':'trophy-$level','slug':'first-journey-trophy','name':'First Journey','category':'room',
  'unlock_method':'level_milestone','milestone_level':level,
},owned:owned,equipped:owned,source:source,unlockedAt:owned?DateTime(2026,9,30):null);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching=false;
  testWidgets('home shows one XP bar and only an unowned next reward at large text',(tester)async{
    await tester.binding.setSurfaceSize(const Size(320,1200));
    addTearDown(()=>tester.binding.setSurfaceSize(null));
    for(final owned in [false,true]) {
      await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:MediaQuery(
        data:const MediaQueryData(textScaler:TextScaler.linear(1.6)),child:Scaffold(body:ListView(children:[
          QuestwellHomeCharacter(archetype:'alchemist',className:'Alchemist',level:4,xp:55,coins:79,
            mastered:false,equippedNames:const ['Lantern'],decorNames:const ['First Journey'],
            collection:const [],onCustomize:(){},onMarket:(){},nextReward:QuestwellNextReward(cosmetics:[trophy(owned:owned)])),
        ])))));
      await tester.pumpAndSettle();
      expect(find.byType(QuestwellPixelMeter),findsOneWidget);
      expect(find.text('90 XP to level 5'),findsOneWidget);
      expect(find.text('First Journey'),owned?findsNothing:findsOneWidget);
      expect(find.text('Next reward · Level 5'),owned?findsNothing:findsOneWidget);
      expect(find.text('YOUR JOURNEY'),findsNothing);
      expect(find.text('Class collection'),findsNothing);
      expect(tester.takeException(),isNull);
    }
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:QuestwellNextReward(cosmetics:[
      trophy(level:10),trophy(owned:true),
    ]))));
    await tester.pumpAndSettle();
    expect(find.text('Next reward · Level 10'),findsOneWidget);
  });
  testWidgets('Adventurer filters class items and trophies without duplicate inventory rows',(tester)async{
    await tester.binding.setSurfaceSize(const Size(390,2000));
    addTearDown(()=>tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:Scaffold(body:QuestwellAdventurerView(
      archetype:'scholar',bodyType:'male',level:4,xp:355,coins:79,description:'Sample',mastered:false,
      collectionOwned:0,collectionTotal:1,relicName:'Relic',canClaim:false,onClaim:(){},onBody:(_){},onClass:(_){},
      onEquip:(_){},onUnequip:(_){},onMarket:(){},onBack:(){},items:[
        AdventurerInventoryItem(id:'trophy',name:'First Journey',slug:'first-journey-trophy',category:'room',
          description:'A milestone trophy',owned:true,equipped:false,classLocked:false,shop:false,
          milestoneLevel:5,source:'founder_testing_grant',unlockedAt:DateTime(2026,9,30)),
        const AdventurerInventoryItem(id:'class',name:'Class item',slug:'sample',category:'neck',
          description:'Class collection',owned:false,equipped:false,classLocked:false,shop:true,archetype:'scholar'),
        const AdventurerInventoryItem(id:'other',name:'Other class',slug:'sample-other',category:'neck',
          description:'Other collection',owned:true,equipped:false,classLocked:true,shop:true,archetype:'scout'),
      ],
    ))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inventory · 2'));await tester.pumpAndSettle();
    await tester.tap(find.text('Trophies'));await tester.pumpAndSettle();
    expect(find.text('First Journey'),findsOneWidget);
    expect(find.text('Added Sep 30, 2026'),findsOneWidget);
    expect(find.text('Class item'),findsNothing);expect(find.text('Other class'),findsNothing);
    await tester.tap(find.text('Class items'));await tester.pumpAndSettle();
    expect(find.text('Class item'),findsOneWidget);expect(find.text('First Journey'),findsNothing);
    expect(find.text('Other class'),findsNothing);
    expect(find.text('View in Market'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  test('Chronicle progress entries do not inflate quest rewards or wins',(){
    final now=DateTime(2026,9,30,18);
    final entries=[
      ChronicleWin(kind:'quest',title:'Quest',completedAt:now,xp:20,coins:10),
      ChronicleWin(kind:'boss',title:'Boss',completedAt:now,xp:100,coins:50),
      ChronicleWin(kind:'level_up',title:'Level 5 reached',completedAt:now,xp:999,coins:999),
      ChronicleWin.fromProgression({'kind':'milestone_reward','title':'First Journey','occurred_at':now.toIso8601String(),
        'level':5,'cosmetic_slug':'first-journey-trophy','source':'level_milestone'}),
    ];
    final result=ChronicleSnapshot.fromWins(entries,now:now);
    expect(result.wins.length,4);expect(result.weekWins,2);expect(result.bossesDefeated,1);
    expect(result.totalXpEarned,120);expect(result.totalCoinsEarned,60);
  });
  testWidgets('Chronicle separates preview copies and earned rewards without zero-XP badges',(tester)async{
    for(final source in ['founder_testing_grant','level_milestone']) {
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:QuestwellChronicleEntry(win:ChronicleWin(
        kind:'milestone_reward',title:'First Journey',completedAt:DateTime(2026,9,30),xp:0,coins:0,
        level:5,cosmeticSlug:'first-journey-trophy',source:source)))));
      await tester.pumpAndSettle();
      expect(find.text(source=='level_milestone'?'MILESTONE REWARD':'ADDED TO COLLECTION'),findsOneWidget);
      expect(find.text('+0 XP'),findsNothing);expect(find.text('+0 coins'),findsNothing);
      expect(tester.takeException(),isNull);
    }
  });
  testWidgets('Chronicle milestone filter includes level-ups and trophies',(tester)async{
    await tester.binding.setSurfaceSize(const Size(390,1800));
    addTearDown(()=>tester.binding.setSurfaceSize(null));
    final now=DateTime(2026,9,30);
    await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:ChroniclePageWidget(previewData:
      ChronicleSnapshot.fromWins([
        ChronicleWin(kind:'quest',title:'A completed quest',completedAt:now,xp:20,coins:10),
        ChronicleWin(kind:'level_up',title:'Level 5 reached',completedAt:now,xp:0,coins:0,level:5),
        ChronicleWin(kind:'milestone_reward',title:'First Journey',completedAt:now,xp:0,coins:0,level:5,source:'level_milestone'),
      ],now:now))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Milestones')); await tester.tap(find.text('Milestones'));await tester.pumpAndSettle();
    expect(find.text('A completed quest'),findsNothing);
    expect(find.text('Level 5 reached'),findsOneWidget);expect(find.text('First Journey'),findsOneWidget);
    await tester.tap(find.text('Bosses'));await tester.pumpAndSettle();
    expect(find.byType(QuestwellChronicleEntry),findsNothing);
    expect(tester.takeException(),isNull);
  });
}
