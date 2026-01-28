import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../rewards/rewards_page.dart';
import '../auth/login_screen.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _cardColor = Colors.white;
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _primaryGreenLight = Color(0xFFE8F5E9);
  static const Color _fireOrange = Color(0xFFFF7043);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = AuthService.authToken;
      if (token == null) {
        setState(() {
          _error = 'Not authenticated';
          _isLoading = false;
        });
        return;
      }

      final response = await http
          .get(
            Uri.parse('${AuthService.baseUrl}/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _profileData = jsonResponse['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  String get _userName {
    if (_profileData != null) {
      // Handle nested fullName structure: { fullName: { firstName: "..." } }
      final fullName = _profileData!['fullName'];
      if (fullName is Map) {
        final firstName = fullName['firstName'] ?? '';
        final lastName = fullName['lastName'] ?? '';
        return '$firstName $lastName'.trim();
      }
      // Fallback to direct fields
      final firstName = _profileData!['firstName'] ?? '';
      final lastName = _profileData!['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'User';
  }

  String get _userEmail {
    return _profileData?['email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primaryGreen),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: _textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(color: _textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildUserCard(context),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/images/paila_logo_col.svg',
            height: 40,
            colorFilter: const ColorFilter.mode(_primaryGreen, BlendMode.srcIn),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardsPage()),
              );
            },
            child: Row(
              children: [
                const Text(
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
                  child: const Icon(
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
    );
  }

  Widget _buildUserCard(BuildContext context) {
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
                  children: [
                    Text(
                      _userName.isNotEmpty ? _userName : 'Loading...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail.isNotEmpty ? _userEmail : 'Runner • Kathmandu',
                      style: const TextStyle(fontSize: 13, color: _textMuted),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout();
                  }
                },
                icon: const Icon(Icons.more_vert_rounded, color: _textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
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
                child: const Column(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: _fireOrange,
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _AchievementCard(
                title: 'First Steps',
                subtitle: 'Complete your first run',
                icon: Icons.directions_walk_rounded,
                isCompleted: true,
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Territory Master',
                subtitle: 'Claim 5 territories',
                icon: Icons.flag_rounded,
                isCompleted: true,
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Marathon Ready',
                subtitle: 'Run 42 km total',
                icon: Icons.emoji_events_rounded,
                isCompleted: false,
                progressText: '38 / 42 km',
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Early Bird',
                subtitle: '10 morning runs',
                icon: Icons.wb_sunny_rounded,
                isCompleted: false,
                progressText: '6 / 10',
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Night Owl',
                subtitle: '5 evening runs',
                icon: Icons.nights_stay_rounded,
                isCompleted: false,
                progressText: '2 / 5',
              ),
              SizedBox(width: 12),
              _AchievementCard(
                title: 'Speed Demon',
                subtitle: 'Run 5km under 25min',
                icon: Icons.speed_rounded,
                isCompleted: false,
                progressText: '28:45',
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
  final IconData icon;
  final bool isCompleted;
  final String? progressText;

  const _AchievementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    // Fire orange accent for completed achievements
    const fireOrange = Color(0xFFFF7043);
    final bgColor = isCompleted
        ? fireOrange.withOpacity(0.1)
        : const Color(0xFFF5F5F5);
    final badgeColor = isCompleted ? fireOrange : const Color(0xFFBDBDBD);
    final iconBgColor = isCompleted
        ? fireOrange.withOpacity(0.2)
        : const Color(0xFFE5E7EB);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: badgeColor),
              ),
              Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: badgeColor,
              ),
            ],
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
