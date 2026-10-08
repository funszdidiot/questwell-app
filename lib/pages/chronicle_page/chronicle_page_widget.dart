import '/widgets/questwell_destination_entrance.dart';
import '../../widgets/questwell_hearth_material.dart';
import '../../widgets/questwell_app_style.dart';
import '/services/questwell_task_service.dart';
import '/widgets/questwell_app_navigation.dart';
import '/services/questwell_chronicle_service.dart';
import '/widgets/questwell_chronicle_entry.dart';
import '/widgets/questwell_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChroniclePageWidget extends StatefulWidget {
  const ChroniclePageWidget(
      {super.key, this.previewData, this.onRepeat, this.onOpenBoard});
  final ChronicleSnapshot? previewData;
  final Future<void> Function(ChronicleWin)? onRepeat;
  final VoidCallback? onOpenBoard;
  static String routeName = 'ChroniclePage';
  static String routePath = '/chronicle';
  @override
  State<ChroniclePageWidget> createState() => _ChroniclePageWidgetState();
}

class _ChroniclePageWidgetState extends State<ChroniclePageWidget> {
  late Future<ChronicleSnapshot> _future;
  String _filter = 'all';
  ChronicleWin? _repeating;
  final _repeated = <ChronicleWin>{};

  Future<void> _repeat(ChronicleWin win) async {
    if (_repeating != null || _repeated.contains(win)) return;
    setState(() => _repeating = win);
    try {
      if (widget.onRepeat != null) {
        await widget.onRepeat!(win);
      } else if (win.kind == 'set_aside') {
        await QuestwellTaskService.restore(win.taskId!);
      } else {
        await QuestwellChronicleService.repeatQuest(win);
      }
      if (!mounted) return;
      setState(() => _repeated.add(win));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(win.kind == 'set_aside'
            ? 'Quest restored to your board.'
            : 'Fresh quest added. Rewards come when you complete it.'),
        action: SnackBarAction(
            label: 'View board',
            onPressed: widget.onOpenBoard ??
                () => QuestwellNavigationScope.open(
                    context, QuestwellDestination.quests)),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(win.kind == 'set_aside'
              ? 'Could not restore this quest. Please try again.'
              : 'Could not copy this quest. Please try again.')));
    } finally {
      if (mounted) setState(() => _repeating = null);
    }
  }

  final _search = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  int _visibleCount = 30;
  static const _gold = Color(0xFFE4C586);
  static const _muted = Color(0xFFBDB6A6);
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = widget.previewData == null
        ? QuestwellChronicleService.load()
        : Future.value(widget.previewData!);
  }

  TextStyle _text(double size,
          {Color color = const Color(0xFFF1E7CF), bool bold = false}) =>
      QuestwellTypography.body(
          fontSize: size,
          height: 1.4,
          color: color,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

  Widget _arrivalState(Widget status) =>
      ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 32), children: [
        const QuestwellDestinationEntrance(
            destination: 'chronicle',
            title: 'CHRONICLE',
            subtitle: 'Your adventure, one page at a time.'),
        status,
      ]);

  @override
  Widget build(BuildContext context) => QuestwellScaffold(
        bottomNavigationBar: const QuestwellAppNavigation(
            current: QuestwellDestination.chronicle),
        backgroundColor: const Color(0xFF111A20),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(children: [
            Expanded(
                child: FutureBuilder<ChronicleSnapshot>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return _arrivalState(Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.menu_book_outlined,
                                      size: 40, color: _gold),
                                  const SizedBox(height: 14),
                                  Text('Your journal could not load.',
                                      style: _text(18, bold: true),
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Your recorded progress is safe. Try opening it again.',
                                      style: _text(14, color: _muted),
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          textStyle:
                                              QuestwellTypography.control()),
                                      onPressed: () => setState(_refresh),
                                      child: const Text('Try again')),
                                ])));
                      if (!snapshot.hasData)
                        return _arrivalState(const Center(
                            child: CircularProgressIndicator(color: _gold)));
                      final data = snapshot.data!;
                      final entries = data.wins
                          .where((win) =>
                              (_filter == 'all' ||
                                  (_filter == 'milestones'
                                      ? !win.isActivity &&
                                          win.kind != 'set_aside'
                                      : win.kind == _filter)) &&
                              !(win.kind == 'set_aside' &&
                                  _repeated.contains(win)) &&
                              win.title.toLowerCase().contains(_query))
                          .toList();
                      final groups = <DateTime, List<ChronicleWin>>{};
                      for (final win in entries.take(_visibleCount)) {
                        final local = win.completedAt.toLocal();
                        final day =
                            DateTime(local.year, local.month, local.day);
                        groups.putIfAbsent(day, () => []).add(win);
                      }
                      final empty = _query.isNotEmpty
                          ? (
                              'No matching entries.',
                              'Try another quest name or choose a different filter.'
                            )
                          : switch (_filter) {
                              'set_aside' => (
                                  'A little room to breathe.',
                                  'Quests you set aside will wait here until you’re ready.'
                                ),
                              'quest' => (
                                  'Your next small win belongs here.',
                                  'Complete a quest to add it to these pages.'
                                ),
                              'boss' => (
                                  'A victory worth a page.',
                                  'Completed boss battles will appear here.'
                                ),
                              'milestones' => (
                                  'Your milestones are ahead.',
                                  'Level-ups and trophy rewards will appear here.'
                                ),
                              _ => (
                                  'Your first page is waiting.',
                                  'Complete a quest or defeat a boss to begin your story.'
                                ),
                            };
                      return RefreshIndicator(
                          color: _gold,
                          onRefresh: () async {
                            setState(_refresh);
                            await _future;
                          },
                          child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                              children: [
                                const QuestwellDestinationEntrance(
                                    destination: 'chronicle',
                                    title: 'CHRONICLE',
                                    subtitle:
                                        'Your adventure, one page at a time.'),
                                _JournalSummary(data: data),
                                const SizedBox(height: 22),
                                Text('YOUR STORY',
                                    style: QuestwellTypography.sectionHeading(
                                        size: 10)),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _search,
                                  style: _text(16),
                                  textInputAction: TextInputAction.search,
                                  onChanged: (value) => setState(() {
                                    _query = value.trim().toLowerCase();
                                    _visibleCount = 30;
                                  }),
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).unfocus(),
                                  decoration: InputDecoration(
                                    labelText: 'Search your Chronicle',
                                    hintText: 'Find a previous quest…',
                                    labelStyle: _text(14, color: _muted),
                                    hintStyle: _text(14, color: _muted),
                                    filled: true,
                                    fillColor: const Color(0xFF1D282E),
                                    prefixIcon:
                                        const Icon(Icons.search, color: _gold),
                                    suffixIcon: _search.text.isEmpty
                                        ? null
                                        : IconButton(
                                            tooltip: 'Clear search',
                                            icon: const Icon(Icons.close,
                                                color: _gold),
                                            onPressed: () => setState(() {
                                              _search.clear();
                                              _query = '';
                                              _visibleCount = 30;
                                            }),
                                          ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF52605C))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: _gold, width: 2)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(spacing: 7, runSpacing: 6, children: [
                                  for (final filter in const {
                                    'all': 'All',
                                    'quest': 'Quests',
                                    'boss': 'Bosses',
                                    'milestones': 'Milestones',
                                    'set_aside': 'Set aside'
                                  }.entries)
                                    ChoiceChip(
                                        label: Text(filter.value),
                                        selected: _filter == filter.key,
                                        showCheckmark: false,
                                        selectedColor: _gold,
                                        backgroundColor:
                                            const Color(0xFF1D282E),
                                        side: BorderSide(
                                            color: _filter == filter.key
                                                ? _gold
                                                : const Color(0xFF52605C)),
                                        labelStyle: _text(14,
                                            bold: _filter == filter.key,
                                            color: _filter == filter.key
                                                ? const Color(0xFF35291C)
                                                : const Color(0xFFE2DFD3)),
                                        onSelected: (_) => setState(() {
                                              _filter = filter.key;
                                              _visibleCount = 30;
                                            })),
                                ]),
                                const SizedBox(height: 14),
                                if (entries.isEmpty)
                                  _JournalPaper(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 24),
                                          child: Column(children: [
                                            const Icon(
                                                Icons.auto_stories_outlined,
                                                color: Color(0xFF816548),
                                                size: 42),
                                            const SizedBox(height: 14),
                                            Text(empty.$1,
                                                textAlign: TextAlign.center,
                                                style: _text(18,
                                                    bold: true,
                                                    color: const Color(
                                                        0xFF3D3026))),
                                            const SizedBox(height: 8),
                                            Text(empty.$2,
                                                textAlign: TextAlign.center,
                                                style: _text(14,
                                                    color: const Color(
                                                        0xFF695442))),
                                          ]))),
                                for (final group in groups.entries) ...[
                                  _JournalPaper(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Row(children: [
                                          const Icon(Icons.bookmark_outline,
                                              color: Color(0xFF7A4D35),
                                              size: 18),
                                          const SizedBox(width: 7),
                                          Expanded(
                                              child: Text(
                                                  DateFormat(
                                                          'EEEE, MMM d, yyyy')
                                                      .format(group.key),
                                                  style: _text(13,
                                                      bold: true,
                                                      color: const Color(
                                                          0xFF684A32)))),
                                        ]),
                                        const SizedBox(height: 10),
                                        const Divider(
                                            height: 1,
                                            color: Color(0xFFCAB58D)),
                                        for (var i = 0;
                                            i < group.value.length;
                                            i++) ...[
                                          QuestwellChronicleEntry(
                                              win: group.value[i],
                                              embedded: true,
                                              repeating: identical(
                                                  _repeating, group.value[i]),
                                              repeated: _repeated
                                                  .contains(group.value[i]),
                                              onRepeat: (group.value[i].kind ==
                                                              'quest' ||
                                                          group.value[i].kind ==
                                                              'set_aside') &&
                                                      (widget.onRepeat !=
                                                              null ||
                                                          (widget.previewData ==
                                                                  null &&
                                                              group.value[i]
                                                                      .taskId !=
                                                                  null))
                                                  ? () =>
                                                      _repeat(group.value[i])
                                                  : null),
                                          if (i < group.value.length - 1)
                                            const Divider(
                                                height: 1,
                                                color: Color(0xFFD5C39D)),
                                        ],
                                      ])),
                                  const SizedBox(height: 16),
                                ],
                                if (entries.length > _visibleCount)
                                  OutlinedButton(
                                      onPressed: () =>
                                          setState(() => _visibleCount += 30),
                                      style: OutlinedButton.styleFrom(
                                          textStyle:
                                              QuestwellTypography.control(),
                                          foregroundColor: _gold,
                                          minimumSize:
                                              const Size.fromHeight(48)),
                                      child: const Text('Show earlier pages')),
                                if (entries.isNotEmpty &&
                                    entries.length <= _visibleCount)
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Text(
                                          'There is room for your next chapter.',
                                          textAlign: TextAlign.center,
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
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B2D28), Color(0xFF251E1C)]),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF8B6B47)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x30000000),
                  offset: Offset(0, 4),
                  blurRadius: 10)
            ]),
        padding: const EdgeInsets.all(6),
        child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF64503B))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('THE STORY SO FAR',
                  style: QuestwellTypography.sectionHeading(size: 9)),
              const SizedBox(height: 16),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth >= 520 ? 4 : 2;
                final width =
                    (constraints.maxWidth - (columns - 1) * 16) / columns;
                return Wrap(spacing: 16, runSpacing: 18, children: [
                  for (final stat in [
                    (
                      '${data.weekWins}',
                      'wins this week',
                      Icons.check_circle_outline
                    ),
                    (
                      '${data.bossesDefeated}',
                      'bosses defeated',
                      Icons.shield_outlined
                    ),
                    (
                      '${data.totalXpEarned}',
                      'XP earned',
                      Icons.auto_awesome_outlined
                    ),
                    (
                      '${data.totalCoinsEarned}',
                      'coins earned',
                      Icons.toll_outlined
                    ),
                  ])
                    SizedBox(
                        width: width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(stat.$3,
                                  size: 18, color: const Color(0xFFCAA367)),
                              const SizedBox(height: 4),
                              Text(stat.$1,
                                  style: QuestwellTypography.body(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFF3E4C3))),
                              Text(stat.$2,
                                  style: QuestwellTypography.body(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: const Color(0xFFD1C2AA))),
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
  Widget build(BuildContext context) => QuestwellHearthFrame(
      parchment: true, padding: const EdgeInsets.all(18), child: child);
}
