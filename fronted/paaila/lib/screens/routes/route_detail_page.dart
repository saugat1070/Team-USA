import 'package:flutter/material.dart';
import '../../models/popular_route.dart';

class RouteDetailPage extends StatelessWidget {
  final PopularRoute route;

  const RouteDetailPage({super.key, required this.route});

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
    final diffColor = _getDifficultyColor(route.difficulty);

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with back button
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
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
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bookmark_border_rounded,
                    color: _textDark,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══════════════════════════════════════════════════════════
                  // HEADER SECTION
                  // ═══════════════════════════════════════════════════════════
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: diffColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          route.difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: diffColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        route.rating.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        ' (${route.reviewCount} reviews)',
                        style: const TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Route Name
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Owner
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: _textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Created by ${route.owner == 'You' ? 'You' : route.owner}',
                        style: TextStyle(
                          fontSize: 13,
                          color: route.owner == 'You'
                              ? _primaryGreen
                              : _textMuted,
                          fontWeight: route.owner == 'You'
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════
                  // QUICK STATS
                  // ═══════════════════════════════════════════════════════════
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.straighten_rounded,
                          'Distance',
                          route.distance,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          Icons.schedule_rounded,
                          'Duration',
                          route.estimatedTime,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          Icons.trending_up_rounded,
                          'Elevation',
                          route.elevation,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════
                  // GALLERY SECTION
                  // ═══════════════════════════════════════════════════════════
                  const Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: route.images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showImageViewer(context, index),
                          child: Container(
                            width: 260,
                            margin: EdgeInsets.only(
                              right: index < route.images.length - 1 ? 12 : 0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _primaryGreenLight,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                route.images[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                          : null,
                                      color: _primaryGreen,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 40,
                                          color: _primaryGreen.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Image ${index + 1}',
                                          style: TextStyle(
                                            color: _primaryGreen.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ═══════════════════════════════════════════════════════════
                  // ABOUT THIS ROUTE
                  // ═══════════════════════════════════════════════════════════
                  const Text(
                    'About This Route',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      route.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textMuted,
                        height: 1.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════
                  // HIGHLIGHTS
                  // ═══════════════════════════════════════════════════════════
                  const Text(
                    'Highlights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: route.highlights
                          .map((h) => _buildHighlightItem(h))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════
                  // ROUTE INFO
                  // ═══════════════════════════════════════════════════════════
                  const Text(
                    'Route Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Terrain', route.terrain),
                        const SizedBox(height: 12),
                        _buildInfoRow('Best Time', route.bestTime),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════
                  // TAGS
                  // ═══════════════════════════════════════════════════════════
                  if (route.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: route.tags
                          .map((tag) => _buildTag(tag))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ═══════════════════════════════════════════════════════════
                  // START ROUTE BUTTON
                  // ═══════════════════════════════════════════════════════════
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to map with this route
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Start This Route',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: _primaryGreen, size: 22),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: _textMuted)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: _bgColor);
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _primaryGreenLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: _primaryGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: _textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryGreenLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _primaryGreen,
        ),
      ),
    );
  }

  void _showImageViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImageViewerPage(
          images: route.images,
          initialIndex: initialIndex,
          routeName: route.name,
        ),
      ),
    );
  }
}

// Full screen image viewer
class _ImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String routeName;

  const _ImageViewerPage({
    required this.images,
    required this.initialIndex,
    required this.routeName,
  });

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
