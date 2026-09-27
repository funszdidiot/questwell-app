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
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        foregroundColor: theme.primaryText,
        title: Text(
          'Chronicle',
          style: theme.titleLarge.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
            letterSpacing: 0,
          ),
        ),
      ),
      body: FutureBuilder<ChronicleSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 52, color: theme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'The Chronicle could not be opened.',
                      textAlign: TextAlign.center,
                      style: theme.titleMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(_refresh),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(_refresh);
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(
                  'Your wins live here.',
                  style: theme.headlineSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Small wins. Real momentum. No streak pressure required.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 16),
                const QuestwellChroniclePixelScene(height: 135),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatCard(
                      icon: Icons.task_alt_outlined,
                      value: '${data.weekWins}',
                      label: 'wins this week',
                    ),
                    _StatCard(
                      icon: Icons.sports_mma_outlined,
                      value: '${data.bossesDefeated}',
                      label: 'bosses defeated',
                    ),
                    _StatCard(
                      icon: Icons.auto_awesome_outlined,
                      value: '${data.totalXpEarned}',
                      label: 'XP earned',
                    ),
                    _StatCard(
                      icon: Icons.monetization_on_outlined,
                      value: '${data.totalCoinsEarned}',
                      label: 'coins earned',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent Wins',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                if (data.wins.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.alternate),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your first page is waiting.',
                          style: theme.titleMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w700,
                            ),
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Complete a quest or defeat a boss and it will appear here.',
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: theme.secondaryText,
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

    return Container(
      width: 156,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF8E6B35),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55322018),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
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
              font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.labelMedium.override(
              font: GoogleFonts.inter(),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isBoss
              ? const Color(0xFFE87947)
              : const Color(0xFF8E6B35),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55322018),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
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
                    font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    color: theme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  win.title,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM d, yyyy').format(win.completedAt.toLocal()),
                  style: theme.bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
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
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                            color: theme.secondaryText,
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
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                            color: theme.secondaryText,
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
