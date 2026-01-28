import 'package:flutter/material.dart';

import '../screens/map/map_for_running.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../widgets/app_header.dart';

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _primaryGreen = Color(0xFF00A86B);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Start Your Run',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Claim territory with every step',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: _textMuted),
                    ),
                    const SizedBox(height: 24),

                    /// Big circular play button
                    Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _onStartActivity,
                            child: Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryGreen,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Ready to claim new territory? Start your activity and conquer routes around Kathmandu!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: _textMuted),
                    ),

                    const SizedBox(height: 32),

                    /// Suggested Routes card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Suggested Routes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _routeTile(
                            iconColor: _primaryGreen,
                            title: 'Thamel Circuit',
                            distance: '2.5 km',
                          ),
                          const SizedBox(height: 8),
                          _routeTile(
                            iconColor: const Color(0xFFFFA726),
                            title: 'Balaju Park Path',
                            distance: '1.9 km',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// Bottom Start Activity button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _onStartActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 4,
                          shadowColor: _primaryGreen.withOpacity(0.4),
                        ),
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          ref.watch(locationProvider).isTracking
                              ? 'Stop Activity'
                              : 'Start Activity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _routeTile({
    required Color iconColor,
    required String title,
    required String distance,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on_rounded, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          distance,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  void _onStartActivity() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MapForRunningPage()));
  }
}
