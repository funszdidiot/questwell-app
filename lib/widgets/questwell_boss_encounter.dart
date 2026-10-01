import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'questwell_pixel_art.dart';

/// Detailed boss encounters. This layer never writes progress or awards rewards.
class QuestwellBossEncounter extends StatefulWidget {
  const QuestwellBossEncounter({super.key, required this.encounterId,
    this.bossType = 'inbox_hydra', this.progress = 0, this.defeated = false, this.persistEntrance = true,
    this.archetype = 'wanderer', this.body = 'neutral', this.equipment = const {}});
  final String encounterId;
  final String bossType;
  final double progress;
  final bool defeated;
  final bool persistEntrance;
  final String archetype;
  final String body;
  final Map<String, String> equipment;
  @override
  State<QuestwellBossEncounter> createState() => _QuestwellBossEncounterState();
}

class _QuestwellBossEncounterState extends State<QuestwellBossEncounter>
    with SingleTickerProviderStateMixin {
  bool get _troll => widget.bossType == 'ticket_troll';
  bool get _swarm => widget.bossType == 'notification_swarm';
  bool get _printer => widget.bossType == 'printer_poltergeist';
  bool get _kraken => widget.bossType == 'calendar_kraken';
  bool get _slime => widget.bossType == 'spreadsheet_slime';
  bool get _mimic => widget.bossType == 'meeting_mimic';
  String get _name => _troll ? 'TICKET TROLL' : _swarm ? 'NOTIFICATION SWARM' : _printer ? 'PRINTER POLTERGEIST' : _kraken ? 'CALENDAR KRAKEN' : _slime ? 'SPREADSHEET SLIME' : _mimic ? 'MEETING MIMIC' : 'INBOX HYDRA';
  String get taunt => _troll ? 'Have you tried opening another ticket?' : _swarm ? 'Just one more ping.' : _printer ? 'Paper jam. Naturally.' : _kraken ? 'I found a gap in your calendar.' : _slime ? 'It worked in the other tab.' : _mimic ? 'This could have been an email.' : 'You said you’d do it tomorrow.';
  static final _seen = <String>{};
  late final AnimationController _intro = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 3200))
    ..addStatusListener((status) { if (status == AnimationStatus.completed) _remember(); });
  bool _started = false;
  bool _ready = false;
  bool _reduced = false;
  bool _active = true;
  String get _storageKey => 'questwell.boss.intro.v1.${widget.encounterId}';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    _active = TickerMode.of(context);
    if (!_started) { _started = true; _begin(); }
    else if (_ready) {
      if (_reduced) { _intro.value = 1; }
      else if (!_active) { _intro.stop(); }
      else if (_intro.value < 1) { _intro.forward(); }
    }
  }
  Future<void> _begin() async {
    var seen = widget.progress > 0 || widget.defeated || _seen.contains(_storageKey);
    if (widget.persistEntrance && !seen) {
      try { seen = (await SharedPreferences.getInstance()).getBool(_storageKey) ?? false; }
      catch (_) { /* Entrance still works when local storage is unavailable. */ }
    }
    if (!mounted) return;
    setState(() => _ready = true);
    if (seen || _reduced) { _intro.value = 1; }
    else if (_active) { _intro.forward(); }
  }
  Future<void> _remember() async {
    if (!widget.persistEntrance) return;
    _seen.add(_storageKey);
    try { await (await SharedPreferences.getInstance()).setBool(_storageKey, true); }
    catch (_) { /* Session-level suppression remains available. */ }
  }
  void _skip() { _intro.value = 1; }
  @override
  void dispose() { _intro.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final sprite = RepaintBoundary(child: Image.asset(_troll ? 'assets/images/questwell_ticket_troll_v2.webp' : _swarm ? 'assets/images/questwell_notification_swarm_v2.webp' : _printer ? 'assets/images/questwell_printer_poltergeist_v1.webp' : _kraken ? 'assets/images/questwell_calendar_kraken_v1.webp' : _slime ? 'assets/images/questwell_spreadsheet_slime_v1.webp' : _mimic ? 'assets/images/questwell_meeting_mimic_v1.webp' : 'assets/images/questwell_inbox_hydra_v1.webp',
      fit: BoxFit.contain, semanticLabel: _troll ? 'Ticket Troll, a grumpy mossy stone clerk holding a stamp and a stack of requests' : _swarm ? 'Notification Swarm, mischievous winged bells and sealed messages' : _printer ? 'Printer Poltergeist, a haunted brass and wood printer trailing ghostly paper' : _kraken ? 'Calendar Kraken, a violet tentacled creature clutching appointment scrolls and a brass watch' : _slime ? 'Spreadsheet Slime, an emerald jelly creature tangled in parchment grids' : _mimic
        ? 'Meeting Mimic, an enchanted burgundy conference chair with a toothy grin'
        : 'Inbox Hydra, a three-headed serpent guarding a pile of letters'));
    final avatar = RepaintBoundary(child: QuestwellLayeredAdventurerArt(
      archetype: widget.archetype, avatarBodyType: widget.body, equippedSlugs: widget.equipment));
    return AnimatedBuilder(animation: _intro, builder: (context, _) {
      final t = _ready ? _intro.value : 0.0;
      final arriving = t < 1;
      final slide = Curves.easeOutCubic.transform(((t - .15) / .28).clamp(0.0, 1.0));
      final land = ((t - .43) / .13).clamp(0.0, 1.0);
      final lift = _reduced ? 0.0 : _troll
        ? -math.sin(slide * math.pi * 2).abs() * (1 - slide) * 18 - math.sin(land * math.pi) * 4
        : -math.sin(land * math.pi) * (_mimic ? 25 : 9);
      final wobble = _reduced ? 0.0 : _troll
        ? math.sin(land * math.pi * 4) * (1 - land) * .04 : _swarm
        ? math.sin(slide * math.pi * 4) * (1 - slide) * .12 + math.sin(land * math.pi * 4) * (1 - land) * .055 : _printer
        ? math.sin(land * math.pi * 6) * (1 - land) * .045 : _kraken
        ? (1 - slide) * .18 + math.sin(land * math.pi * 2) * (1 - land) * .09
        : _mimic ? math.sin(land * math.pi * 3) * (1 - land) * .07 : 0.0;
      final squash = _reduced || !_slime ? 0.0 : math.sin(land * math.pi * 2) * (1 - land) * .22;
      final letters = (((t - .53) / .30).clamp(0.0, 1.0) * taunt.length).floor();
      final hp = widget.defeated ? 0.0 : (1 - widget.progress).clamp(0.0, 1.0);
      final fill = ((t - .82) / .16).clamp(0.0, 1.0);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
          color: const Color(0xFF1E2029), border: Border.all(color: const Color(0xFFB99855), width: 2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(widget.defeated ? '$_name · DEFEATED' : _name,
              style: GoogleFonts.pressStart2p(fontSize: 11, height: 1.5, color: const Color(0xFFF1D79B))),
            const SizedBox(height: 9),
            Semantics(label: 'Boss health ${(hp * 100).round()} percent',
              child: QuestwellPixelMeter(value: hp * fill, kind: 'hp', height: 14, segments: 12)),
          ])),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Semantics(label: arriving ? 'Boss entrance. Tap to skip.' : 'Boss encounter',
            child: GestureDetector(onTap: arriving ? _skip : null,
              child: Container(height: 350, clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFB99855), width: 2),
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF10222A), Color(0xFF242133), Color(0xFF392A28)])),
                child: Stack(children: [
                  Positioned.fill(child: CustomPaint(painter: _ArenaPainter(dust: land))),
                  Positioned(left: width * .03, bottom: 24, width: width * .42, height: 190, child: avatar),
                  Positioned(right: width * .01, bottom: 23, width: width * .59, height: 230,
                    child: Transform.translate(offset: Offset((1 - slide) * (_kraken ? 65 : width + 40),
                      lift + (_swarm ? -math.sin(slide * math.pi * 2) * 35 : _printer ? -(1 - slide) * 80 : _kraken ? (1 - slide) * 290 : 0)),
                      child: AnimatedOpacity(duration: Duration(milliseconds: _reduced ? 0 : 650),
                        opacity: widget.defeated ? .15 : 1, child: Transform.rotate(angle: wobble, child: Transform.scale(
                          scaleX: 1 + squash, scaleY: 1 - squash, alignment: Alignment.bottomCenter, child: sprite))))),
                  if (t >= .53 && !widget.defeated)
                    Positioned(top: 19, left: 14, right: 14, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFF1E5C6),
                            border: Border.all(color: const Color(0xFF9E7B46), width: 3)),
                          child: Semantics(label: taunt, child: ExcludeSemantics(child: Text(taunt.substring(0, letters),
                            style: const TextStyle(color: Color(0xFF30271E), fontSize: 16, height: 1.3, fontWeight: FontWeight.w700))))),
                        Padding(padding: const EdgeInsets.only(right: 52), child: CustomPaint(size: const Size(18, 12), painter: _BubbleTail())),
                      ])),
                  if (t < .32 && !widget.defeated)
                    Positioned.fill(child: ColoredBox(color: const Color(0x88101922), child: Center(
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
                        width: double.infinity, color: const Color(0xEE211A24), child: Text('BOSS APPROACHING',
                          textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(fontSize: 12, height: 1.6,
                            color: const Color(0xFFF2D594))))))),
                  Positioned(bottom: 6, left: 0, right: 0, child: Text(widget.defeated ? 'VICTORY' : arriving ? 'Tap to skip' : 'YOUR MOVE',
                    textAlign: TextAlign.center, style: arriving
                      ? const TextStyle(fontSize: 12, color: Color(0xFFD9D2BE))
                      : GoogleFonts.pressStart2p(fontSize: 10, color: const Color(0xFFF3D998)))),
                  if (arriving) Positioned(top: 0, right: 0, child: TextButton(
                    key: const ValueKey('skip-boss-entrance'), onPressed: _skip, child: const Text('Skip'))),
                ]))));
        }),
      ]);
    });
  }
}

class _BubbleTail extends CustomPainter {
  @override
  void paint(Canvas c, Size s) { c.drawPath(Path()..moveTo(0, 0)..lineTo(s.width, 0)..lineTo(s.width * .65, s.height)..close(), Paint()..color = const Color(0xFFF1E5C6)); }
  @override
  bool shouldRepaint(covariant _BubbleTail oldDelegate) => false;
}
class _ArenaPainter extends CustomPainter {
  const _ArenaPainter({required this.dust});
  final double dust;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = const Color(0x334F6670)..strokeWidth = 1;
    for (var i = 0; i < 7; i++) { c.drawLine(Offset(0, 120.0 + i * 35), Offset(s.width, 120.0 + i * 35), p); }
    p.color = const Color(0x883B3030);
    c.drawOval(Rect.fromLTWH(s.width * .1, s.height - 44, s.width * .84, 19), p);
    if (dust > 0 && dust < 1) {
      p.color = Color.fromRGBO(222, 185, 118, (1 - dust) * .8);
      for (var i = 0; i < 14; i++) {
        final x = s.width * .73 + (i - 7) * (2 + dust * 6);
        final y = s.height - 29 - math.sin(dust * math.pi) * (7 + i % 4 * 4);
        c.drawRect(Rect.fromLTWH(x, y, 3, 3), p);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _ArenaPainter oldDelegate) => oldDelegate.dust != dust;
}
