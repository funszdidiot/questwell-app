import '/services/questwell_chronicle_service.dart';
import '/widgets/questwell_chronicle_entry.dart';
import '/widgets/questwell_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChroniclePageWidget extends StatefulWidget {
  const ChroniclePageWidget({super.key, this.previewData});
  final ChronicleSnapshot? previewData;
  static String routeName = 'ChroniclePage';
  static String routePath = '/chronicle';
  @override
  State<ChroniclePageWidget> createState() => _ChroniclePageWidgetState();
}

class _ChroniclePageWidgetState extends State<ChroniclePageWidget> {
  late Future<ChronicleSnapshot> _future;
  String _filter = 'all';
  int _visibleCount = 30;
  static const _gold = Color(0xFFE4C586);
  static const _muted = Color(0xFFBDB6A6);
  @override
  void initState() { super.initState(); _refresh(); }
  void _refresh() {
    _future = widget.previewData == null
      ? QuestwellChronicleService.load() : Future.value(widget.previewData!);
  }
  TextStyle _text(double size, {Color color = const Color(0xFFF1E7CF), bool bold = false}) =>
    GoogleFonts.roboto(fontSize: size, height: 1.4, color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF111A20),
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 12, 18, 12), child: Row(children: [
          IconButton(tooltip: 'Back to the Hearth', onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: _gold)),
          const SizedBox(width: 6),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CHRONICLE', style: QuestwellTypography.sectionHeading(size: 14)),
            const SizedBox(height: 4),
            Text('Your adventure, one page at a time.', style: _text(13, color: _muted)),
          ])),
        ])),
        Expanded(child: FutureBuilder<ChronicleSnapshot>(future: _future, builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.menu_book_outlined, size: 40, color: _gold),
              const SizedBox(height: 14),
              Text('Your journal could not load.', style: _text(18, bold: true), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Your recorded progress is safe. Try opening it again.', style: _text(14, color: _muted), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => setState(_refresh), child: const Text('Try again')),
            ])));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: _gold));
          final data = snapshot.data!;
          final entries = data.wins.where((win) => _filter == 'all' ||
            (_filter == 'milestones' ? !win.isActivity : win.kind == _filter)).toList();
          final groups = <DateTime, List<ChronicleWin>>{};
          for (final win in entries.take(_visibleCount)) {
            final local = win.completedAt.toLocal();
            final day = DateTime(local.year, local.month, local.day);
            groups.putIfAbsent(day, () => []).add(win);
          }
          final empty = switch (_filter) {
            'quest' => ('Your next small win belongs here.', 'Complete a quest to add it to these pages.'),
            'boss' => ('A victory worth a page.', 'Completed boss battles will appear here.'),
            'milestones' => ('Your milestones are ahead.', 'Level-ups and trophy rewards will appear here.'),
            _ => ('Your first page is waiting.', 'Complete a quest or defeat a boss to begin your story.'),
          };
          return RefreshIndicator(color: _gold, onRefresh: () async {
            setState(_refresh); await _future;
          }, child: ListView(physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
              _JournalSummary(data: data),
              const SizedBox(height: 22),
              Text('YOUR STORY', style: QuestwellTypography.sectionHeading(size: 10)),
              const SizedBox(height: 10),
              Wrap(spacing: 7, runSpacing: 6, children: [
                for (final filter in const {'all':'All', 'quest':'Quests', 'boss':'Bosses', 'milestones':'Milestones'}.entries)
                  ChoiceChip(label: Text(filter.value), selected: _filter == filter.key,
                    showCheckmark: false, selectedColor: _gold,
                    backgroundColor: const Color(0xFF1D282E),
                    side: BorderSide(color: _filter == filter.key ? _gold : const Color(0xFF52605C)),
                    labelStyle: _text(13, bold: _filter == filter.key,
                      color: _filter == filter.key ? const Color(0xFF35291C) : const Color(0xFFE2DFD3)),
                    onSelected: (_) => setState(() { _filter = filter.key; _visibleCount = 30; })),
              ]),
              const SizedBox(height: 14),
              if (entries.isEmpty) _JournalPaper(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(children: [
                  const Icon(Icons.auto_stories_outlined, color: Color(0xFF816548), size: 42),
                  const SizedBox(height: 14),
                  Text(empty.$1, textAlign: TextAlign.center,
                    style: _text(18, bold: true, color: const Color(0xFF3D3026))),
                  const SizedBox(height: 8),
                  Text(empty.$2, textAlign: TextAlign.center, style: _text(14, color: const Color(0xFF695442))),
                ]))),
              for (final group in groups.entries) ...[
                _JournalPaper(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.bookmark_outline, color: Color(0xFF7A4D35), size: 18),
                    const SizedBox(width: 7),
                    Expanded(child: Text(DateFormat('EEEE, MMM d, yyyy').format(group.key),
                      style: _text(13, bold: true, color: const Color(0xFF684A32)))),
                  ]),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFCAB58D)),
                  for (var i = 0; i < group.value.length; i++) ...[
                    QuestwellChronicleEntry(win: group.value[i], embedded: true),
                    if (i < group.value.length - 1) const Divider(height: 1, color: Color(0xFFD5C39D)),
                  ],
                ])),
                const SizedBox(height: 16),
              ],
              if (entries.length > _visibleCount)
                OutlinedButton(onPressed: () => setState(() => _visibleCount += 30),
                  style: OutlinedButton.styleFrom(foregroundColor: _gold, minimumSize: const Size.fromHeight(48)),
                  child: const Text('Show earlier pages')),
              if (entries.isNotEmpty && entries.length <= _visibleCount)
                Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(
                  'There is room for your next chapter.', textAlign: TextAlign.center,
                  style: _text(13, color: _muted))),
            ]));
        })),
      ]),
    ))),
  );
}

class _JournalSummary extends StatelessWidget {
  const _JournalSummary({required this.data});
  final ChronicleSnapshot data;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF3B2D28), Color(0xFF251E1C)]),
      borderRadius: BorderRadius.circular(5), border: Border.all(color: const Color(0xFF8B6B47)),
      boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(0, 4), blurRadius: 10)]),
    padding: const EdgeInsets.all(6),
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), border: Border.all(color: const Color(0xFF64503B))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('THE STORY SO FAR', style: QuestwellTypography.sectionHeading(size: 9)),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 520 ? 4 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
          return Wrap(spacing: 16, runSpacing: 18, children: [
            for (final stat in [
              ('${data.weekWins}', 'wins this week', Icons.check_circle_outline),
              ('${data.bossesDefeated}', 'bosses defeated', Icons.shield_outlined),
              ('${data.totalXpEarned}', 'XP earned', Icons.auto_awesome_outlined),
              ('${data.totalCoinsEarned}', 'coins earned', Icons.toll_outlined),
            ]) SizedBox(width: width, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(stat.$3, size: 18, color: const Color(0xFFCAA367)),
              const SizedBox(height: 4),
              Text(stat.$1, style: GoogleFonts.roboto(fontSize: 25, fontWeight: FontWeight.w700, color: const Color(0xFFF3E4C3))),
              Text(stat.$2, style: GoogleFonts.roboto(fontSize: 12, height: 1.4, color: const Color(0xFFD1C2AA))),
            ])),
          ]);
        }),
      ])),
  );
}

class _JournalPaper extends StatelessWidget {
  const _JournalPaper({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFDFCBA2), Color(0xFFF5E9CC), Color(0xFFEEDFBA)], stops: [0, .14, 1]),
      borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
      border: Border.all(color: const Color(0xFFAA8756)),
      boxShadow: const [BoxShadow(color: Color(0x45000000), offset: Offset(3, 5), blurRadius: 7)]),
    child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(width: 10, decoration: const BoxDecoration(color: Color(0xFF6A4934),
        border: Border(right: BorderSide(color: Color(0xFFB08B56), width: 2)))),
      Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(12, 16, 14, 10), child: child)),
    ])),
  );
}
