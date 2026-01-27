import 'package:flutter/material.dart';
import 'package:paaila/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<SplashPage> splashPages = [
    SplashPage(
      image: 'lib/images/onboarding-img-02.png',
      title: 'Welcome to Paaila',
      description: 'Track your running progress and achieve your goals',
    ),
    SplashPage(
      image: 'lib/images/onboarding-img-01.png',
      title: 'Join the Community',
      description: 'Compete with other runners and climb the leaderboard',
    ),
    SplashPage(
      image: 'lib/images/onboarding-img-03.png',
      title: 'Start Running',
      description: 'Begin your running journey today',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < splashPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite, // Pure white background
      body: Stack(
        children: [
          // PageView for splash pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: splashPages.length,
            itemBuilder: (context, index) {
              return _buildSplashPage(splashPages[index]);
            },
          ),
          // Dots indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip button
                TextButton(
                  onPressed: () {
                    // Navigate to login screen directly
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Page dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    splashPages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppColors.primaryGreen
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                // Next button
                TextButton(
                  onPressed: _goToNext,
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashPage(SplashPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image - fits screen width
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                page.image,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            page.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            page.description,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class SplashPage {
  final String image;
  final String title;
  final String description;

  SplashPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
