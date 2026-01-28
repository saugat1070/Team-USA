import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bottom_nav_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(ref, 0, Icons.home_rounded, currentIndex),
          _buildNavItem(ref, 1, Icons.map_rounded, currentIndex),
          _buildNavItem(ref, 2, Icons.directions_run_rounded, currentIndex),
          _buildNavItem(ref, 3, Icons.emoji_events_rounded, currentIndex),
          _buildNavItem(ref, 4, Icons.person_rounded, currentIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    WidgetRef ref,
    int index,
    IconData icon,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(bottomNavIndexProvider.notifier).setIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 70,
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: isSelected
                ? const Color(0xFF00A86B)
                : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
