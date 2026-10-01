import 'package:flutter/material.dart';
import '../widgets/questwell_boss_encounter.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';

class BossReviewApp extends StatefulWidget {
  const BossReviewApp({super.key});
  @override
  State<BossReviewApp> createState() => _BossReviewAppState();
}
class _BossReviewAppState extends State<BossReviewApp> {
  int _replay = 0;
  String _boss = Uri.base.queryParameters['boss'] == 'meeting_mimic' ? 'meeting_mimic' : 'inbox_hydra';
  bool get _mimic => _boss == 'meeting_mimic';
  final _done = <int>{};
  bool _motion = true;
  String _body = 'female';
  List<String> get _steps => _mimic ? ['Name the decision this meeting needs', 'Write a three-point agenda', 'Send the decision and next steps'] : ['Sort the three threads that matter', 'Send one useful reply', 'Archive what no longer needs you'];
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true), home: Builder(builder: (context) =>
      MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: !_motion),
        child: Scaffold(backgroundColor: const Color(0xFF111827), body: SafeArea(
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 470),
            child: ListView(padding: const EdgeInsets.all(18), children: [
              Text('BOSS BATTLES', style: QuestwellTypography.sectionHeading()),
              const SizedBox(height: 8),
              Text(_mimic ? 'One agenda. One decision. Meeting adjourned.' : 'One reply. One thread. One head at a time.'),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                for (final type in ['inbox_hydra', 'meeting_mimic']) ChoiceChip(
                  label: Text(type == 'inbox_hydra' ? 'Inbox Hydra' : 'Meeting Mimic'),
                  selected: _boss == type,
                  onSelected: (_) => setState(() { _boss = type; _done.clear(); _replay++; })),
              ]),
              const SizedBox(height: 14),
              QuestwellBossEncounter(key: ValueKey(_replay), encounterId: 'preview-$_boss-$_replay', bossType: _boss,
                persistEntrance: false, progress: _done.length / 3, defeated: _done.length == 3,
                archetype: 'scholar', body: _body, equipment: const {'neck': 'emerald-scholar-scarf', 'accessory': 'moonstone-brooch'}),
              const SizedBox(height: 16),
              Text(_done.length == 3 ? (_mimic ? 'MEETING ADJOURNED' : 'BACKLOG BANISHED') : 'YOUR ATTACK PLAN', style: QuestwellTypography.sectionHeading()),
              const SizedBox(height: 10),
              for (var i = 0; i < _steps.length; i++) Padding(padding: const EdgeInsets.only(bottom: 8),
                child: QuestwellParchmentPanel(padding: const EdgeInsets.all(10), child: Row(children: [
                  Expanded(child: Text(_steps[i], style: TextStyle(color: const Color(0xFF30261D),
                    decoration: _done.contains(i) ? TextDecoration.lineThrough : null))),
                  TextButton(onPressed: _done.contains(i) ? null : () => setState(() => _done.add(i)),
                    child: Text(_done.contains(i) ? 'Done' : 'ATTACK', style: const TextStyle(color: Color(0xFF56371E)))),
                ]))),
              if (_done.length == 3) const Padding(padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('VICTORY LOOT\n+100 XP  ·  +50 coins\nSample reward — your account is unchanged.',
                  textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFF2D79B), height: 1.6))),
              OutlinedButton(onPressed: () => setState(() { _done.clear(); _replay++; }), child: const Text('Replay entrance')),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Animations'), value: _motion,
                onChanged: (value) => setState(() => _motion = value)),
              Wrap(spacing: 8, children: ['female', 'male', 'neutral'].map((body) => ChoiceChip(
                label: Text(body), selected: body == _body, onSelected: (_) => setState(() => _body = body))).toList()),
              const SizedBox(height: 10),
              const Text('Practice encounter · these attacks do not complete real tasks or award coins.',
                style: TextStyle(fontSize: 12, color: Color(0xFFB7C4D4))),
            ]))))))));
}
