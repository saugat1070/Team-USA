import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paaila/screens/map/map_page.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up.dart';
import 'screens/home/home_page.dart';
import 'pages/activity_page.dart';
import 'screens/profile/user_profile.dart';


void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      // home: const SplashScreen(),

      routes: {
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
