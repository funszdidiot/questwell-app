import '/flutter_flow/flutter_flow_theme.dart';
import '/services/questwell_chronicle_service.dart';
import '/widgets/questwell_pixel_art.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChroniclePageWidget extends StatefulWidget {
  const ChroniclePageWidget({super.key});

  static String routeName = 'ChroniclePage';
  static String routePath = '/chronicle';

  @override
  State<ChroniclePageWidget> createState() => _ChroniclePageWidgetState();
}

class _ChroniclePageWidgetState extends State<ChroniclePageWidget> {
  late Future<ChronicleSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = QuestwellChronicleService.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        top: true,
        child: FutureBuilder<ChronicleSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: QuestwellRetroPanel(
                  padding: const EdgeInsets.all(16),
                  accent: const Color(0xFFE87947),
                  background: const Color(0xFF1A1512),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const QuestwellNavPixelIcon(
                        kind: 'chronicle',
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'CHRONICLE UNAVAILABLE',
                        textAlign: TextAlign.center,
                        style: theme.titleMedium.override(
                          font: GoogleFonts.pressStart2p(
                            fontWeight: FontWeight.w700,
                          ),
                          fontSize: 10,
                          letterSpacing: .3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(_refresh),
                        child: const Text('TRY AGAIN'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 220,
                child: QuestwellRetroPanel(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(_refresh);
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              children: [
                Row(
                  children: [
                    QuestwellTopActionButton(
                      kind: 'back',
                      tooltip: 'Back to the Hearth',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHRONICLE',
                            style: theme.headlineMedium.override(
                              font: GoogleFonts.pressStart2p(
                                fontWeight: FontWeight.w700,
                              ),
                              fontSize: 21,
                              color: const Color(0xFFF2D9A0),
                              letterSpacing: .5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Every quest leaves a page behind.',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.roboto(
                                fontWeight: FontWeight.w600,
                              ),
                              color: const Color(0xFFB7C4D4),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const QuestwellNavPixelIcon(
                      kind: 'chronicle',
                      size: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const QuestwellPixelDivider(
                  accent: Color(0xFFD6A84B),
                ),
                const SizedBox(height: 14),
                const QuestwellChroniclePixelScene(height: 205),
                const SizedBox(height: 16),
                QuestwellRetroPanel(
                  padding: const EdgeInsets.all(14),
                  accent: const Color(0xFF7654D8),
                  background: const Color(0xFF17151A),
                  child: Row(
                    children: [
                      const QuestwellStatusPixelBadge(
                        kind: 'momentum',
                        size: 54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR WINS LIVE HERE',
                              style: theme.titleMedium.override(
                                font: GoogleFonts.pressStart2p(
                                  fontWeight: FontWeight.w700,
                                ),
                                fontSize: 10,
                                color: const Color(0xFFF2D9A0),
                                letterSpacing: .3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Small wins. Real momentum. No streak pressure required.',
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.roboto(),
                                color: const Color(0xFFB7C4D4),
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final width = wide
                        ? (constraints.maxWidth - 30) / 4
                        : (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.task_alt_outlined,
                            value: '${data.weekWins}',
                            label: 'wins this week',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.sports_mma_outlined,
                            value: '${data.bossesDefeated}',
                            label: 'bosses defeated',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.auto_awesome_outlined,
                            value: '${data.totalXpEarned}',
                            label: 'XP earned',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _StatCard(
                            icon: Icons.monetization_on_outlined,
                            value: '${data.totalCoinsEarned}',
                            label: 'coins earned',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const QuestwellNavPixelIcon(
                      kind: 'chronicle',
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'RECENT WINS',
                        style: theme.titleLarge.override(
                          font: GoogleFonts.pressStart2p(
                            fontWeight: FontWeight.w700,
                          ),
                          fontSize: 12,
                          color: const Color(0xFFF2D9A0),
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (data.wins.isEmpty)
                  QuestwellRetroPanel(
                    padding: const EdgeInsets.all(18),
                    accent: const Color(0xFF8E6B35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your first page is waiting.',
                          style: theme.titleMedium.override(
                            font: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                            ),
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Complete a quest or defeat a boss and it will appear here.',
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.roboto(),
                            color: const Color(0xFF67543E),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final win in data.wins.take(30)) ...[
                    _WinCard(win: win),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return QuestwellRetroPanel(
        padding: const EdgeInsets.all(12),
        accent: const Color(0xFF8E6B35),
        background: const Color(0xFF171A20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon == Icons.monetization_on_outlined
              ? const QuestwellCurrencyPixelIcon(kind: 'coin', size: 22)
              : icon == Icons.auto_awesome_outlined
                  ? const QuestwellCurrencyPixelIcon(kind: 'xp', size: 22)
                  : icon == Icons.sports_mma_outlined
                      ? const QuestwellNavPixelIcon(kind: 'boss', size: 22)
                      : const QuestwellNavPixelIcon(kind: 'quest', size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.headlineSmall.override(
              font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.labelMedium.override(
              font: GoogleFonts.roboto(),
              color: theme.secondaryText,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinCard extends StatelessWidget {
  const _WinCard({required this.win});

  final ChronicleWin win;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isBoss = win.kind == 'boss';

    return QuestwellParchmentPanel(
      padding: const EdgeInsets.all(14),
      selected: isBoss,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestwellNavPixelIcon(
            kind: isBoss ? 'boss' : 'quest',
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBoss ? 'BOSS DEFEATED' : 'QUEST COMPLETE',
                  style: theme.labelSmall.override(
                    font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                    color: const Color(0xFF6E3B2C),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  win.title,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM d, yyyy').format(win.completedAt.toLocal()),
                  style: theme.bodySmall.override(
                    font: GoogleFonts.roboto(),
                    color: const Color(0xFF67543E),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const QuestwellCurrencyPixelIcon(
                          kind: 'xp',
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '+${win.xp} XP',
                          style: theme.labelMedium.override(
                            font: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                            ),
                            color: const Color(0xFF67543E),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const QuestwellCurrencyPixelIcon(
                          kind: 'coin',
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '+${win.coins} coins',
                          style: theme.labelMedium.override(
                            font: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                            ),
                            color: const Color(0xFF67543E),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
