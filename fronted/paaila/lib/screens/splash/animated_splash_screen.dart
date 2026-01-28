import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paaila/core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class AnimatedSplashScreen extends ConsumerStatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  ConsumerState<AnimatedSplashScreen> createState() =>
      _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends ConsumerState<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _footstepController;
  late AnimationController _logoController;
  late AnimationController _backgroundController;

  late Animation<double> _leftFootOpacity;
  late Animation<double> _rightFootOpacity;
  late Animation<double> _whiteLogoOpacity;
  late Animation<double> _coloredLogoOpacity;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();

    // Controller for footstep alternating animation (slower)
    _footstepController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    // Controller for logo fade-in
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controller for background color transition
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // Left foot opacity: left -> (disappear) -> left -> (disappear)
    // Appears at positions 1 and 3
    _leftFootOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ), // Fade in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1), // Hold
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 1,
      ), // Fade out
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 1), // Hidden
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ), // Fade in again
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1), // Hold
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 1,
      ), // Fade out
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 1), // Hidden
    ]).animate(_footstepController);

    // Right foot opacity: (hidden) -> right -> (disappear) -> right -> (disappear)
    // Appears at positions 2 and 4
    _rightFootOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 2,
      ), // Hidden during left 1
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ), // Fade in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1), // Hold
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 1,
      ), // Fade out
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 1,
      ), // Hidden during left 2
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ), // Fade in again
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1), // Hold
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 1,
      ), // Fade out
    ]).animate(_footstepController);

    // White logo opacity (fades in, stays, then fades out when bg changes)
    _whiteLogoOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ), // Fade in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 2), // Hold
    ]).animate(_logoController);

    // Colored logo opacity (only appears when background transitions)
    _coloredLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );

    // Background color transition (green to white)
    _backgroundColor =
        ColorTween(begin: AppColors.primaryGreen, end: Colors.white).animate(
          CurvedAnimation(
            parent: _backgroundController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _startAnimationSequence() async {
    // Step 1: Footstep alternating animation (left, right, left, right)
    await _footstepController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 2: Show white logo on green background
    await _logoController.forward();

    // Step 3: Wait and display white logo
    await Future.delayed(const Duration(milliseconds: 1200));

    // Step 4: Simultaneously transition background to white and swap logo to colored
    await _backgroundController.forward();

    // Step 5: Wait before checking auth and navigating
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check if user is already authenticated (has valid JWT)
    if (mounted) {
      final isAuthenticated = await ref
          .read(authProvider.notifier)
          .checkAuthStatus();

      if (isAuthenticated) {
        // User has valid JWT and socket is now connected, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // No valid auth, show onboarding/login
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  //@override
  //void dispose() {
  //  _footstepController.dispose();
  //  _logoController.dispose();
  //  _backgroundController.dispose();
  //  super.dispose();
  //}

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _footstepController,
        _logoController,
        _backgroundController,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColor.value,
          body: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Footsteps (positioned with spacing like a real walking pattern)
                if (_leftFootOpacity.value > 0 || _rightFootOpacity.value > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Left footstep
                      Opacity(
                        opacity: _leftFootOpacity.value,
                        child: SvgPicture.asset(
                          'assets/images/footstep_left.svg',
                          width: 50,
                          height: 70,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.9),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right footstep
                      Opacity(
                        opacity: _rightFootOpacity.value,
                        child: SvgPicture.asset(
                          'assets/images/footstep_right.svg',
                          width: 50,
                          height: 70,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.9),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),

                // White logo on green bg
                if (_whiteLogoOpacity.value > 0 &&
                    _backgroundController.value < 0.3)
                  Opacity(
                    opacity:
                        _whiteLogoOpacity.value *
                        (1.0 - (_backgroundController.value / 0.3)),
                    child: SvgPicture.asset(
                      'assets/images/paila_logo_white.svg',
                      width: MediaQuery.of(context).size.width * 0.6,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                // Colored logo on white bg
                if (_backgroundController.value > 0.3)
                  Opacity(
                    opacity: _coloredLogoOpacity.value,
                    child: SvgPicture.asset(
                      'assets/images/paila_logo_col.svg',
                      width: MediaQuery.of(context).size.width * 0.6,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryGreen,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
