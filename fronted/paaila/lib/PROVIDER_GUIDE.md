// PROVIDER STATE MANAGEMENT GUIDE FOR PAAILA
//
// This guide shows how to use Riverpod for authentication state management

/\*
═══════════════════════════════════════════════════════════════════════════

1. ARCHITECTURE OVERVIEW
   ═══════════════════════════════════════════════════════════════════════════

AuthService (services/auth_service.dart)
↓
Handles API calls to backend
Returns LoginResponse/SignUpResponse
↓
AuthNotifier (providers/auth_provider.dart)
↓
Manages AuthState
Calls AuthService methods
Updates state based on API responses
↓
Widgets (screens)
↓
Watch authProvider
Display UI based on state
Call notifier methods on user action

═══════════════════════════════════════════════════════════════════════════ 2. STATE MANAGEMENT FLOW
═══════════════════════════════════════════════════════════════════════════

Initial State:
AuthState(
isLoading: false,
isAuthenticated: false,
user: null,
error: null,
successMessage: null,
)

On Login Click:

1. isLoading = true
2. Call AuthService.login()
3. If success:
   - isLoading = false
   - isAuthenticated = true
   - user = User data
   - successMessage = "Login successful"
     If error:
   - isLoading = false
   - error = Error message

═══════════════════════════════════════════════════════════════════════════ 3. BASIC USAGE IN WIDGETS
═══════════════════════════════════════════════════════════════════════════

Example: Using in LoginScreen
\*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider Usage Example:
//
// class LoginScreenExample extends ConsumerStatefulWidget {
// const LoginScreenExample({super.key});
//
// @override
// ConsumerState<LoginScreenExample> createState() => \_LoginScreenExampleState();
// }
//
// class \_LoginScreenExampleState extends ConsumerState<LoginScreenExample> {
// late TextEditingController \_emailController;
// late TextEditingController \_passwordController;
//
// @override
// void initState() {
// super.initState();
// \_emailController = TextEditingController();
// \_passwordController = TextEditingController();
// }
//
// @override
// void dispose() {
// \_emailController.dispose();
// \_passwordController.dispose();
// super.dispose();
// }
//
// void \_handleLogin() async {
// final authNotifier = ref.read(authProvider.notifier);
//  
// final success = await authNotifier.login(
// \_emailController.text,
// \_passwordController.text,
// );
//
// if (success && mounted) {
// // Navigate to home screen
// Navigator.pushReplacementNamed(context, '/home');
// }
// }
//
// @override
// Widget build(BuildContext context) {
// // Watch the auth state
// final authState = ref.watch(authProvider);
// final isLoading = authState.isLoading;
// final error = authState.error;
//
// return Scaffold(
// body: SingleChildScrollView(
// child: Column(
// children: [
// // Email TextField
// TextField(
// controller: _emailController,
// decoration: InputDecoration(
// labelText: 'Email',
// ),
// ),
//
// // Password TextField
// TextField(
// controller: _passwordController,
// decoration: InputDecoration(
// labelText: 'Password',
// ),
// obscureText: true,
// ),
//
// // Error Message
// if (error != null)
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Text(
// error,
// style: const TextStyle(color: Colors.red),
// ),
// ),
//
// // Login Button
// ElevatedButton(
// onPressed: isLoading ? null : _handleLogin,
// child: isLoading
// ? const CircularProgressIndicator()
// : const Text('Login'),
// ),
// ],
// ),
// ),
// );
// }
// }

/\*
═══════════════════════════════════════════════════════════════════════════ 4. PROVIDER USAGE PATTERNS
═══════════════════════════════════════════════════════════════════════════

A. Watch entire auth state:
final authState = ref.watch(authProvider);

B. Watch specific providers:
final isLoading = ref.watch(isLoadingProvider);
final user = ref.watch(userProvider);
final error = ref.watch(authErrorProvider);
final isAuthenticated = ref.watch(isAuthenticatedProvider);

C. Read notifier (for one-time operations):
final authNotifier = ref.read(authProvider.notifier);
await authNotifier.login(email, password);

D. Watch and access notifier:
final authNotifier = ref.watch(authProvider.notifier);
final authState = ref.watch(authProvider);

═══════════════════════════════════════════════════════════════════════════ 5. WIDGET TYPES
═══════════════════════════════════════════════════════════════════════════

Use ConsumerWidget for simple widgets that just read state:
class MyWidget extends ConsumerWidget {
@override
Widget build(BuildContext context, WidgetRef ref) {
final user = ref.watch(userProvider);
return Text(user?.name ?? 'Guest');
}
}

Use ConsumerStatefulWidget for widgets with local state:
class LoginScreen extends ConsumerStatefulWidget {
@override
ConsumerState<LoginScreen> createState() => \_LoginScreenState();
}

class \_LoginScreenState extends ConsumerState<LoginScreen> {
@override
Widget build(BuildContext context) {
final authState = ref.watch(authProvider);
// ...
}
}

═══════════════════════════════════════════════════════════════════════════ 6. NAVIGATION BASED ON AUTH STATE
═══════════════════════════════════════════════════════════════════════════

In main.dart:
class MyApp extends ConsumerWidget {
@override
Widget build(BuildContext context, WidgetRef ref) {
final isAuthenticated = ref.watch(isAuthenticatedProvider);

       return MaterialApp(
         home: isAuthenticated ? const HomeScreen() : const SplashScreen(),
       );
     }

}

═══════════════════════════════════════════════════════════════════════════ 7. ERROR HANDLING
═══════════════════════════════════════════════════════════════════════════

Listen to errors:
ref.listen<AuthState>(authProvider, (previous, next) {
if (next.error != null) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(next.error!)),
);
}
});

Clear error after showing:
ref.read(authProvider.notifier).clearError();

═══════════════════════════════════════════════════════════════════════════ 8. LOGOUT EXAMPLE
═══════════════════════════════════════════════════════════════════════════

ElevatedButton(
onPressed: () async {
await ref.read(authProvider.notifier).logout();
if (mounted) {
Navigator.pushReplacementNamed(context, '/login');
}
},
child: const Text('Logout'),
)

═══════════════════════════════════════════════════════════════════════════ 9. KEY POINTS
═══════════════════════════════════════════════════════════════════════════

- Always use ConsumerWidget or ConsumerStatefulWidget to access providers
- Use ref.watch() to rebuild on state changes
- Use ref.read() for one-time operations (like button clicks)
- AuthState is immutable - always use copyWith() to update
- Clear error/success messages after showing them
- Always check isLoading before making API calls
- Use the convenience providers (userProvider, isLoadingProvider) for simple cases
- Wrap your app with ProviderScope in main.dart

═══════════════════════════════════════════════════════════════════════════
\*/
