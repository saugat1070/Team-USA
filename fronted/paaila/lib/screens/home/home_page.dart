import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paaila/pages/activity_page.dart';
import 'package:paaila/pages/profile_page.dart';
import 'package:paaila/pages/ranking_page.dart';
import 'package:paaila/screens/map/map_page.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bottom_nav_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../screens/profile/user_profile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> _pages = [
      _buildHomePage(context, ref),
      MapPage(),
      ActivityPage(),
      RankingPage(),
      UserProfilePage(),
    ];

    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _buildHomePage(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section with Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
              ),
            ),
            padding: const EdgeInsets.only(
              top: 20,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Paaila Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Paaila',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Claim your territory, one step at a time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Good Morning Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Good Morning',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ready to Run?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Quote Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"The only bad workout is the one that didn\'t happen."',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '- Unknown',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Challenge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Flexible(
                      child: Text(
                        'Today\'s Challenge',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Chip(
                      label: Text('4 Day Streak!'),
                      backgroundColor: Color(0xFFFF6B6B),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Weekly Goal Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.location_on, color: Color(0xFF1ABC9C)),
                          SizedBox(width: 8),
                          Text(
                            'Weekly Goal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '14.8 / 20 km',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.74,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1ABC9C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '5.2 km to go!',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Section
                Row(
                  children: [
                    _buildStatCard('3', 'Routes', Icons.location_on),
                    const SizedBox(width: 12),
                    _buildStatCard('38.1', 'Total km', Icons.show_chart),
                    const SizedBox(width: 12),
                    _buildStatCard('24', 'Activities', Icons.calendar_today),
                  ],
                ),
                const SizedBox(height: 24),
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Start Run',
                        'Begin tracking',
                        Icons.play_arrow,
                        const Color(0xFF1ABC9C),
                        () {
                          // Switch bottom nav to Activity tab
                          ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'View Map',
                        'Explore routes',
                        Icons.map,
                        const Color(0xFF2196F3),
                        () {
                          // Switch bottom nav to Map tab
                          ref.read(bottomNavIndexProvider.notifier).setIndex(1);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Top Runners This Week
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Top Runners This Week',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1ABC9C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRunnerCard('Anjali B.', '18.5 km this week', 1),
                const SizedBox(height: 8),
                _buildRunnerCard('Rajesh K.', '16.2 km this week', 2),
                const SizedBox(height: 8),
                _buildRunnerCard('You', '14.8 km this week', 3),
                const SizedBox(height: 24),
                // Popular Routes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Popular Routes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1ABC9C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRouteCard('Thamel Circuit', '2.5 km', 'Easy', 'You'),
                const SizedBox(height: 8),
                _buildRouteCard(
                  'Swayambhu Trail',
                  '4.1 km',
                  'Medium',
                  'Priya S.',
                ),
                const SizedBox(height: 8),
                _buildRouteCard(
                  'Balaju Park Path',
                  '1.9 km',
                  'Easy',
                  'Sanjay M.',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1ABC9C), size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunnerCard(String name, String distance, int rank) {
    final medals = ['🥇', '🥈', '🥉'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(medals[rank - 1], style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: const Color(0xFF1ABC9C).withOpacity(0.2),
            child: const Icon(Icons.person, color: Color(0xFF1ABC9C)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                distance,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (name == 'You')
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1ABC9C),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    String routeName,
    String distance,
    String difficulty,
    String owner,
  ) {
    final difficultyColor = difficulty == 'Easy'
        ? const Color(0xFF4CAF50)
        : difficulty == 'Medium'
        ? const Color(0xFFFFC107)
        : const Color(0xFFFF6B6B);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, color: Color(0xFF1ABC9C)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$distance • $difficulty',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: 10,
                    color: difficultyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Owned by $owner',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherPages(int currentIndex) {
    return Center(child: Text('Page ${currentIndex + 1}'));
  }
}
