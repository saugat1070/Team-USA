import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

/// A widget that protects routes by checking for valid JWT token.
/// If no valid token exists, redirects to login screen.
class AuthGuard extends ConsumerStatefulWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  ConsumerState<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends ConsumerState<AuthGuard> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Check if token exists in memory (already loaded in main.dart)
    if (AuthService.authToken == null) {
      // No token, redirect to login
      _redirectToLogin();
      return;
    }

    // Token exists - trust it for now and show the page immediately
    // The auth state will be verified in the background
    if (mounted) {
      setState(() {
        _isChecking = false;
        _isAuthenticated = true;
      });
    }

    // Verify token validity in background (non-blocking)
    // If invalid, user will be redirected via the ref.listen on authProvider
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated && !authState.isLoading) {
      // Only verify if not already authenticated
      ref.read(authProvider.notifier).checkAuthStatus();
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      // Use addPostFrameCallback to avoid navigation during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes (e.g., logout or token invalidation)
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Redirect to login if:
      // 1. User was authenticated and is now not authenticated (logout)
      // 2. Token verification failed (error state with not authenticated)
      if ((previous?.isAuthenticated == true &&
              next.isAuthenticated == false) ||
          (next.error != null && !next.isAuthenticated && !next.isLoading)) {
        _redirectToLogin();
      }
    });

    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      // Return empty container while redirecting
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
