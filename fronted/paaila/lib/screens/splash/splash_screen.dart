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
      title: 'Conquer Your City',
      description:
          'Run your favorite routes to claim them. Defend your turf before someone else takes it!',
    ),
    SplashPage(
      image: 'lib/images/onboarding-img-01.png',
      title: 'Climb The Leaderboard',
      description:
          'Turn every step into a win. Outrun your friends and claim the top spot!',
    ),
    SplashPage(
      image: 'lib/images/onboarding-img-03.png',
      title: 'Level Up Your Health',
      description:
          'Boost your heart, mind, and spirit. Make fitness the most fun part of your day!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

//  @override
//  void dispose() {
  //  _pageController.dispose();
  //  super.dispose();
  //}

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
      backgroundColor: AppColors.pureWhite,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextButton(
                    onPressed: () {
                      // Navigate to login screen directly
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(
                      'Skip',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextButton(
                    onPressed: _goToNext,
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image - full width with no horizontal padding
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Image.asset(
              page.image,
              width: double.infinity,
              fit: BoxFit.contain,
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
        // Text section with horizontal padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Title
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                page.description,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
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
