import 'package:flutter/material.dart';
import 'package:paaila/services/ranking_service.dart';
export 'package:paaila/services/ranking_service.dart' show Runner;

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  // 0: This Week, 1: All Time
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

  void _onPeriodChanged(int index) {
    setState(() {
      _rankingsFuture = _fetchRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: 16,
        automaticallyImplyLeading: false, // Ensure no back button on main tab
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paaila',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Claim your territory, one step at a time',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Icon + Title)
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Rankings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1617),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Compete with runners across Nepal',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Period Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 32),

            // Dynamic Content
            FutureBuilder<List<Runner>>(
              future: _rankingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00A86B),
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
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load rankings',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _rankingsFuture = _fetchRankings();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A86B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final runners = snapshot.data ?? [];
                if (runners.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No rankings available'),
                  );
                }

                return Column(
                  children: [
                    // Podium
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Rank 2
                          if (runners.length > 1)
                            _PodiumItem(
                              runner: runners[1],
                              height: 140,
                              color: const Color(0xFFCFD8DC),
                            ),
                          if (runners.length > 1) const SizedBox(width: 8),
                          // Rank 1
                          _PodiumItem(
                            runner: runners[0],
                            height: 170,
                            color: const Color(0xFFFFC107),
                            isFirst: true,
                          ),
                          if (runners.length > 2) const SizedBox(width: 8),
                          // Rank 3
                          if (runners.length > 2)
                            _PodiumItem(
                              runner: runners[2],
                              height: 120,
                              color: const Color(0xFFCD7F32).withOpacity(0.8),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // List Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'All Rankings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D1617),
                          ),
                        ),
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
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets & Models
// -----------------------------------------------------------------------------

class _PeriodTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF9C27B0) : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF9C27B0) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
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
        // Avatar stack (Avatar + Crown/Rank Badge)
        SizedBox(
          height: isFirst ? 70 : 60,
          width: isFirst ? 70 : 60,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // User Avatar Placeholder or Image
              // For simplicity using a colored icon or asset would be best.
              // Replicating the 'person running' illustration is hard without assets.
              // Will use simple Icons for now.
              runner.name == 'You'
                  ? const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF4A148C), // Purple for 'You'
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    )
                  : const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.directions_run,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),

              // Crown for #1
              if (isFirst)
                Positioned(
                  top: -24,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                ),

              // Rank Badge
              Positioned(
                bottom: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? const Color(0xFFFFC107)
                        : const Color(0xFF90A4AE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFirst ? '♛ #${runner.rank}' : '#${runner.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Name & Stat
        Text(
          runner.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          runner.distance,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(height: 8),

        // Podium Block
        Container(
          width: isFirst ? 100 : 85,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.emoji_events_outlined, // Trophy/Medal icon on the block
              color: Colors.black.withOpacity(0.15),
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingListItem extends StatelessWidget {
  final Runner runner;

  const _RankingListItem({required this.runner});

  @override
  Widget build(BuildContext context) {
    // Define a special style for top 3
    final isTop3 = runner.rank <= 3;
    Color? badgeColor;
    if (runner.rank == 1) badgeColor = const Color(0xFFFFC107);
    if (runner.rank == 2) badgeColor = const Color(0xFFCFD8DC);
    if (runner.rank == 3) badgeColor = const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Icon/Number
          SizedBox(
            width: 32,
            child: isTop3
                ? Icon(Icons.emoji_events, color: badgeColor, size: 28)
                : Icon(
                    Icons.military_tech_outlined,
                    color: Colors.grey.shade400,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 8),

          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isTop3
                  ? Border.all(color: badgeColor!, width: 2)
                  : Border.all(color: Colors.transparent),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade100,
              child: Icon(
                Icons.directions_run,
                size: 20,
                color: isTop3 ? Colors.orange : Colors.grey,
              ),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1D1617),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${runner.territories} territories',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stat Badge
          if (isTop3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Top ${runner.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Top ${runner.rank}', // Or just 'Top 10' logic
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
