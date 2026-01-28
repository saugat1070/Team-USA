import 'package:flutter/material.dart';
import 'package:paaila/services/ranking_service.dart';
import '../widgets/app_header.dart';
export 'package:paaila/services/ranking_service.dart' show Runner;

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _cardColor = Colors.white;
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _primaryGreenLight = Color(0xFFE8F5E9);
  static const Color _fireOrange = Color(0xFFFF7043);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _goldColor = Color(0xFFFFD700);
  static const Color _silverColor = Color(0xFFB8C5D0);
  static const Color _bronzeColor = Color(0xFFCD7F32);

  late Future<List<Runner>> _rankingsFuture;
  final String _roomId = '6978b3eb48c5b7d8b56577fb';

  @override
  void initState() {
    super.initState();
    _rankingsFuture = _fetchRankings();
  }

  Future<List<Runner>> _fetchRankings() {
    return RankingService.fetchRankings(roomId: _roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top Section (Icon + Title)
                    const SizedBox(height: 20),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _fireOrange.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: _fireOrange,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Compete with runners across Kaski',
                      style: TextStyle(fontSize: 13, color: _textMuted),
                    ),
                    const SizedBox(height: 28),

                    // Dynamic Content
                    FutureBuilder<List<Runner>>(
                      future: _rankingsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _primaryGreen,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Failed to load rankings',
                                  style: TextStyle(
                                    color: _textDark,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    snapshot.error.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: _textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _rankingsFuture = _fetchRankings();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final runners = snapshot.data ?? [];
                        if (runners.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 48,
                                  color: _textMuted.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No rankings available',
                                  style: TextStyle(
                                    color: _textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Podium
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Rank 2
                                  if (runners.length > 1)
                                    _PodiumItem(
                                      runner: runners[1],
                                      height: 100,
                                      color: _silverColor,
                                    ),
                                  if (runners.length > 1)
                                    const SizedBox(width: 12),
                                  // Rank 1
                                  _PodiumItem(
                                    runner: runners[0],
                                    height: 130,
                                    color: _goldColor,
                                    isFirst: true,
                                  ),
                                  if (runners.length > 2)
                                    const SizedBox(width: 12),
                                  // Rank 3
                                  if (runners.length > 2)
                                    _PodiumItem(
                                      runner: runners[2],
                                      height: 80,
                                      color: _bronzeColor,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // List Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'All Runners',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark,
                                    ),
                                  ),
                                  Text(
                                    '${runners.length} participants',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // List View
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: runners.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              itemBuilder: (context, index) {
                                return _RankingListItem(runner: runners[index]);
                              },
                            ),
                            const SizedBox(height: 40), // Bottom padding
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets & Models
// -----------------------------------------------------------------------------

class _PodiumItem extends StatelessWidget {
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  final Runner runner;
  final double height;
  final Color color;
  final bool isFirst;

  const _PodiumItem({
    required this.runner,
    required this.height,
    required this.color,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Simple trophy icon (no emoji)
        Icon(
          Icons.emoji_events_outlined,
          color: color.withOpacity(0.9),
          size: isFirst ? 28 : 22,
        ),
        const SizedBox(height: 8),

        // Avatar
        Container(
          width: isFirst ? 64 : 52,
          height: isFirst ? 64 : 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: isFirst ? 3 : 2),
          ),
          child: Center(
            child: Icon(
              runner.name == 'You'
                  ? Icons.person_rounded
                  : Icons.directions_run_rounded,
              color: _primaryGreen,
              size: isFirst ? 30 : 24,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Name
        SizedBox(
          width: 80,
          child: Text(
            runner.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isFirst ? 14 : 12,
              color: _textDark,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          runner.distance,
          style: const TextStyle(color: _textMuted, fontSize: 11),
        ),
        const SizedBox(height: 10),

        // Podium Block
        Container(
          width: isFirst ? 90 : 75,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${runner.rank}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isFirst ? 22 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankingListItem extends StatelessWidget {
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _primaryGreenLight = Color(0xFFE8F5E9);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _goldColor = Color(0xFFFFD700);
  static const Color _silverColor = Color(0xFFB8C5D0);
  static const Color _bronzeColor = Color(0xFFCD7F32);

  final Runner runner;

  const _RankingListItem({required this.runner});

  @override
  Widget build(BuildContext context) {
    final isTop3 = runner.rank <= 3;
    Color badgeColor;

    if (runner.rank == 1) {
      badgeColor = _goldColor;
    } else if (runner.rank == 2) {
      badgeColor = _silverColor;
    } else if (runner.rank == 3) {
      badgeColor = _bronzeColor;
    } else {
      badgeColor = const Color(0xFFE5E7EB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isTop3
            ? Border.all(color: badgeColor.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isTop3
                  ? badgeColor.withOpacity(0.15)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${runner.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isTop3 ? badgeColor : _textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryGreenLight,
              border: isTop3 ? Border.all(color: badgeColor, width: 2) : null,
            ),
            child: Icon(
              Icons.directions_run_rounded,
              size: 20,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  runner.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 12, color: _primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      '${runner.territories} territories',
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.straighten_rounded, size: 12, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      runner.distance,
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rank Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTop3 ? badgeColor : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isTop3 ? 'Top ${runner.rank}' : '#${runner.rank}',
              style: TextStyle(
                color: isTop3 ? Colors.white : _textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
