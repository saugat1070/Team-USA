import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paaila/screens/map/map_page.dart';
import 'screens/splash/animated_splash_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up.dart';
import 'screens/home/home_page.dart';
import 'pages/activity_page.dart';
import 'screens/profile/user_profile.dart';
import 'services/auth_service.dart';
import 'widgets/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service (load stored JWT)
  await AuthService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AnimatedSplashScreen(),

      routes: {
        // Public routes (no auth required)
        '/onboarding': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),

        // Protected routes (auth required)
        '/home': (context) => const AuthGuard(child: HomePage()),
        '/map': (context) => const AuthGuard(child: MapPage()),
        '/activity': (context) => const AuthGuard(child: ActivityPage()),
        '/profile': (context) => const AuthGuard(child: UserProfilePage()),
      },
    );
  }
}
