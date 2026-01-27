import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_models.dart';
import '../services/auth_service.dart';

// Auth State - holds current auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final String? successMessage;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.successMessage,
  });

  // Copy with method for immutability
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      successMessage: successMessage,
    );
  }
}

// Auth Notifier - manages authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final loginRequest = LoginRequest(email: email, password: password);

      final response = await AuthService.login(loginRequest);

      if (response.success && response.user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          successMessage: response.message,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } on ApiError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  // Sign up method
  Future<bool> signUp(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final signUpRequest = SignUpRequest(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      // Validation happens inside SignUpRequest
      final validationError = signUpRequest.validate();
      if (validationError != null) {
        state = state.copyWith(isLoading: false, error: validationError);
        return false;
      }

      final response = await AuthService.signUp(signUpRequest);

      if (response.success && response.user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          successMessage: response.message,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } on ApiError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await AuthService.logout();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      );
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  // Check if user is logged in
  bool get isLoggedIn => state.isAuthenticated && state.user != null;
}

// Create the auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers for accessing specific auth state
final userProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final authSuccessMessageProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).successMessage;
});
