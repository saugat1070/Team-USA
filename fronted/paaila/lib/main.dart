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
      // home: const HomePage(),
      home: const AnimatedSplashScreen(),

      routes: {
        '/onboarding': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomePage(),
        '/map': (context) => const MapPage(),
        '/activity': (context) => const ActivityPage(),
        '/profile': (context) => const UserProfilePage(),
      },
    );
  }
}
