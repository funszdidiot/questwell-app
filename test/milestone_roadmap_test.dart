import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';
import 'package:project_momentum/widgets/questwell_milestone_roadmap.dart';
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
  test('milestone XP honors legacy progress and never becomes negative',(){
    expect(QuestwellMilestoneRoadmap.xpRemaining(profile(),5),90);
    expect(QuestwellMilestoneRoadmap.xpRemaining(profile(level:5,xp:445),5),0);
    expect(QuestwellMilestoneRoadmap.xpRemaining(profile(level:10,xp:1500),5),0);
    expect(QuestwellMilestoneRoadmap.xpRemaining(profile(),10),1040);
  });
  testWidgets('roadmap handles locked, early copy, earned and next catalog milestone at large text',(tester)async{
    await tester.binding.setSurfaceSize(const Size(320,1400));
    addTearDown(()=>tester.binding.setSurfaceSize(null));
    for(final state in ['locked','preview','earned','future']) {
      bool opened=false;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:MediaQuery(
        data:const MediaQueryData(textScaler:TextScaler.linear(1.6)),child:Scaffold(body:ListView(children:[
          QuestwellMilestoneRoadmap(profile:state=='earned'||state=='future'?profile(level:5,xp:445):profile(),
            cosmetics:[trophy(owned:state!='locked',source:'founder_testing_grant'),if(state=='future')trophy(level:10)],
            onOpenCollection:()=>opened=true),
        ])))));
      await tester.pumpAndSettle();
      expect(find.text('90 XP to level 5'),state=='locked'||state=='preview'?findsOneWidget:findsNothing);
      if(state=='future') expect(find.text('950 XP to level 10'),findsOneWidget);
      if(state=='earned') expect(find.text('You’ve reached every released milestone.'),findsOneWidget);
      expect(find.text('${state=='earned'||state=='future'?1:0} earned through milestones'),findsOneWidget);
      final collection=find.text('Trophy collection · ${state=='locked'?0:1}');
      await tester.ensureVisible(collection); await tester.tap(collection);await tester.pumpAndSettle();
      if(state=='preview') expect(find.text('Preview copy'),findsOneWidget);
      if(state!='locked') {
        expect(find.text('Added Sep 30, 2026'),findsOneWidget);
        await tester.ensureVisible(find.text('Manage in Adventurer'));
        await tester.tap(find.text('Manage in Adventurer'));
        expect(opened,true);
      }
      expect(tester.takeException(),isNull);
    }
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
