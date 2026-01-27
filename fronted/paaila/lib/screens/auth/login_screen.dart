import 'package:flutter/material.dart';
import 'sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        size: 50,
                        color: Color(0xFF1ABC9C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Paaila',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    const Text(
                      'Your journey to wellness begins here',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tab buttons - Sign Up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1ABC9C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Email field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: 'your@email.com',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.grey.shade500,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Password field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey.shade500,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  obscureText: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle login
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Login functionality coming soon',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1ABC9C),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  // Handle forgot password
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(0xFF1ABC9C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Bottom text
                    const Text(
                      '"Every journey begins with a single step"',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join the movement. Transform Nepal,\none run at a time.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
