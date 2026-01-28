import 'package:flutter/material.dart';
import '../../models/popular_route.dart';
import 'route_detail_page.dart';

class AllRoutesPage extends StatelessWidget {
  const AllRoutesPage({super.key});

  // Theme colors
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _cardColor = Colors.white;
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _primaryGreenLight = Color(0xFFE8F5E9);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _textLight = Color(0xFF9CA3AF);

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF43A047);
      case 'medium':
        return const Color(0xFFFB8C00);
      case 'hard':
        return const Color(0xFFE53935);
      default:
        return _textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = PopularRoute.sampleRoutes;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _textDark,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Routes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            return _buildRouteCard(context, routes[index]);
          },
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, PopularRoute route) {
    final diffColor = _getDifficultyColor(route.difficulty);

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row - icon and difficulty badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: _primaryGreen,
                    size: 20,
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

            // Route name
            Text(
              route.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Distance and owner
            Row(
              children: [
                Text(
                  route.distance,
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
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
            const SizedBox(height: 8),

            // Rating
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  route.rating.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${route.reviewCount})',
                  style: const TextStyle(fontSize: 10, color: _textLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
