import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/rewards/rewards_page.dart';

/// Shared header widget for all main navigation pages.
/// Displays logo on the left and streak badge on the right.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _fireOrange = Color(0xFFFF7043);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          SvgPicture.asset(
            'assets/images/paila_logo_col.svg',
            height: 40,
            colorFilter: const ColorFilter.mode(_primaryGreen, BlendMode.srcIn),
          ),
          // Streak badge - tappable to open rewards
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
}
