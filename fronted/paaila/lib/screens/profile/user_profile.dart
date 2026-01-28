import 'package:flutter/material.dart';
import '../rewards/rewards_page.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _cardColor = Colors.white;
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _primaryGreenLight = Color(0xFFE8F5E9);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: _textDark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            _buildWeeklyGoalCard(),
            const SizedBox(height: 16),
            _buildAchievementsSection(),
            const SizedBox(height: 16),
            _buildRecentActivitiesCard(),
            const SizedBox(height: 16),
            _buildPersonalBestsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 36,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Anita Sharma',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Runner • Kathmandu',
                      style: TextStyle(fontSize: 13, color: _textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RewardsPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryGreenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paaila Points',
                          style: TextStyle(fontSize: 12, color: _textMuted),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: _primaryGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '1,250',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Redeem',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 90,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF7043),
                      size: 22,
                    ),
                    SizedBox(height: 6),
                    Text(
                      '4',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Day Streak',
                      style: TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildQuickActionItem(
          context,
          icon: Icons.redeem_rounded,
          label: 'Rewards',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RewardsPage()),
          ),
        ),
        const SizedBox(width: 12),
        _buildQuickActionItem(
          context,
          icon: Icons.person_outline_rounded,
          label: 'Edit Profile',
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _buildQuickActionItem(
          context,
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              Icon(icon, color: _primaryGreen, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: _textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyGoalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Weekly Goal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              Text(
                '14.8 / 20 km',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.74,
              minHeight: 10,
              backgroundColor: Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '5.2 km to reach your weekly goal!',
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            Text('2 / 6', style: TextStyle(fontSize: 13, color: _textMuted)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _AchievementCard(
                title: 'First Steps',
                subtitle: 'Complete your first run',
                isCompleted: true,
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Territory Master',
                subtitle: 'Claim 5 territories',
                isCompleted: true,
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Marathon Ready',
                subtitle: 'Run 42 km total',
                isCompleted: false,
                progressText: '38 / 42 km',
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Early Bird',
                subtitle: '10 morning runs',
                isCompleted: false,
                progressText: '6 / 10',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          SizedBox(height: 12),
          _RecentActivityItem(
            title: 'Thamel Circuit',
            subtitle: 'Today',
            distance: '3.2 km',
            duration: '28:15',
          ),
          SizedBox(height: 10),
          _RecentActivityItem(
            title: 'Swayambhu Trail',
            subtitle: 'Yesterday',
            distance: '5.1 km',
            duration: '45:30',
          ),
          SizedBox(height: 10),
          _RecentActivityItem(
            title: 'Boudha Kora',
            subtitle: '2 days ago',
            distance: '2.8 km',
            duration: '24:10',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBestsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryGreenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Bests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPersonalBestItem('Longest Run', '5.5 km')),
              const SizedBox(width: 12),
              Expanded(child: _buildPersonalBestItem('Best Pace', "5'15\"/km")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPersonalBestItem('Most in Week', '22.4 km'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPersonalBestItem('Longest Streak', '9 days'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBestItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: _textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final String? progressText;

  const _AchievementCard({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCompleted
        ? const Color(0xFFFDF7E9)
        : const Color(0xFFF5F5F5);
    final badgeColor = isCompleted
        ? const Color(0xFF00A86B)
        : const Color(0xFFBDBDBD);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: badgeColor,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            maxLines: 2,
          ),
          if (progressText != null) ...[
            const SizedBox(height: 6),
            Text(
              progressText!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String distance;
  final String duration;

  const _RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: Color(0xFF00A86B),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                duration,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
