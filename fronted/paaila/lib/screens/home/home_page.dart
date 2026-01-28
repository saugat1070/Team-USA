import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paaila/pages/activity_page.dart';
import 'package:paaila/pages/ranking_page.dart';
import 'package:paaila/screens/map/trail_map_page.dart';
import '../../providers/bottom_nav_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../screens/profile/user_profile.dart';
import '../../models/popular_route.dart';
import '../routes/all_routes_page.dart';
import '../routes/route_detail_page.dart';
import '../rewards/rewards_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Theme colors - Neutral light theme
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _cardColor = Colors.white;
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _primaryGreenLight = Color(0xFFE8F5E9);
  static const Color _fireOrange = Color(0xFFFF7043);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _textLight = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> _pages = [
      _buildHomePage(context, ref),
      TrailMapPage(),
      ActivityPage(),
      RankingPage(),
      UserProfilePage(),
    ];

    return Scaffold(
      backgroundColor: _bgColor,
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _buildHomePage(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // TOP BAR - Logo left, Streak right
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo (combined wordmark + brandmark)
                  SvgPicture.asset(
                    'assets/images/paila_logo_col.svg',
                    height: 40,
                    colorFilter: ColorFilter.mode(
                      _primaryGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                  // Streak badge - tappable to open rewards page
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RewardsPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          '4',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _fireOrange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _fireOrange.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_fire_department_rounded,
                            size: 24,
                            color: _fireOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════════
            // HERO SECTION - Central circular progress with flanking stats
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left stat
                  _buildSideStat(
                    icon: Icons.route_rounded,
                    value: '14.8',
                    unit: 'km',
                    label: 'Distance',
                  ),
                  // Center - Circular progress
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: 0.74,
                          strokeWidth: 12,
                          backgroundColor: _primaryGreen.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _primaryGreen,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_run_rounded,
                            size: 32,
                            color: _primaryGreen,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '74%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            'Weekly Goal',
                            style: TextStyle(fontSize: 12, color: _textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Right stat
                  _buildSideStat(
                    icon: Icons.stars_rounded,
                    value: '1,250',
                    unit: 'pts',
                    label: 'Paaila Points',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Goal subtitle
            Center(
              child: Text(
                '5.2 km to reach your weekly goal',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
            ),

            const SizedBox(height: 28),

            // ═══════════════════════════════════════════════════════════════
            // SERVICES / STATS - Horizontal scrollable cards
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Impact',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildServiceCard(
                    icon: Icons.public_rounded,
                    value: '12',
                    label: 'Territory\nConquered',
                  ),
                  _buildServiceCard(
                    icon: Icons.straighten_rounded,
                    value: '38.1 km',
                    label: 'Distance\nWalked',
                  ),
                  _buildServiceCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '2,450',
                    label: 'Calories\nBurned',
                  ),
                  _buildServiceCard(
                    icon: Icons.directions_walk_rounded,
                    value: '48.2k',
                    label: 'Footsteps\nWalked',
                  ),
                  _buildServiceCard(
                    icon: Icons.eco_rounded,
                    value: '5.2 kg',
                    label: 'CO2\nSaved',
                  ),
                  _buildServiceCard(
                    icon: Icons.emoji_events_rounded,
                    value: '8',
                    label: 'Challenges\nCompleted',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ═══════════════════════════════════════════════════════════════
            // TODAY'S PLAN - Quick Actions Card
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Plan",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '3 activities',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Activity chips row
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildActivityChip('Morning Walk', true),
                        _buildActivityChip('5km Run', false),
                        _buildActivityChip('Evening Stroll', false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // CTA Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(bottomNavIndexProvider.notifier)
                                  .setIndex(2);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Start Activity',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(bottomNavIndexProvider.notifier)
                                .setIndex(1);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _primaryGreenLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.map_rounded,
                              color: _primaryGreen,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ═══════════════════════════════════════════════════════════════
            // POPULAR ROUTES
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Routes',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllRoutesPage(),
                        ),
                      );
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Horizontal scrollable route cards
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: PopularRoute.sampleRoutes.length > 5
                    ? 5
                    : PopularRoute.sampleRoutes.length,
                itemBuilder: (context, index) {
                  final route = PopularRoute.sampleRoutes[index];
                  return _buildRouteCardCompact(context, route);
                },
              ),
            ),

            const SizedBox(height: 28),

            // ═══════════════════════════════════════════════════════════════
            // RECENT ACTIVITY
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildActivityRow(
                      'Morning Run',
                      '3.2 km',
                      '28 min',
                      'Today, 7:30 AM',
                    ),
                    Divider(height: 24, color: _bgColor),
                    _buildActivityRow(
                      'Evening Walk',
                      '1.8 km',
                      '22 min',
                      'Yesterday, 6:15 PM',
                    ),
                    Divider(height: 24, color: _bgColor),
                    _buildActivityRow(
                      'Trail Run',
                      '5.1 km',
                      '45 min',
                      '2 days ago',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSideStat({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primaryGreenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryGreen, size: 22),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: _textLight)),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip(String label, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? _primaryGreenLight : _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted
            ? Border.all(color: _primaryGreen.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: _primaryGreen,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
              color: isCompleted ? _primaryGreen : _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCardCompact(BuildContext context, PopularRoute route) {
    Color diffColor;
    switch (route.difficulty.toLowerCase()) {
      case 'easy':
        diffColor = Color(0xFF43A047);
        break;
      case 'medium':
        diffColor = Color(0xFFFB8C00);
        break;
      case 'hard':
        diffColor = Color(0xFFE53935);
        break;
      default:
        diffColor = _textLight;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDetailPage(route: route),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryGreenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: _primaryGreen,
                    size: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: diffColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    route.difficulty,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: diffColor,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              route.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  route.distance,
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _textLight,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    route.owner == 'You' ? 'Yours' : route.owner,
                    style: TextStyle(
                      fontSize: 12,
                      color: route.owner == 'You' ? _primaryGreen : _textMuted,
                      fontWeight: route.owner == 'You'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(
    String title,
    String distance,
    String duration,
    String time,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primaryGreenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.directions_run_rounded,
            color: _primaryGreen,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$distance · $duration',
                style: TextStyle(fontSize: 12, color: _textMuted),
              ),
            ],
          ),
        ),
        Text(time, style: TextStyle(fontSize: 11, color: _textLight)),
      ],
    );
  }
}
