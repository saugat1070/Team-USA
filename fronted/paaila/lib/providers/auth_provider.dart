import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_models.dart';
import '../services/location_service.dart';
import '../providers/socket_provider.dart';
import '../services/socket_service.dart';
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
  final SocketService socketService;

  AuthNotifier(this.socketService) : super(AuthState());

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final loginRequest = LoginRequest(email: email, password: password);

      final response = await AuthService.login(loginRequest);

      // Login response only returns token and message, fetch user separately
      final currentUser = await AuthService.getCurrentUser();

      // Connect socket with token
      if (response.token != null) {
        socketService.connect(response.token!);
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: currentUser,
        successMessage: response.message,
      );
      return true;
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
    String firstName,
    String secondName,
    String email,
    String password,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final signUpRequest = SignUpRequest(
        firstName: firstName,
        secondName: secondName,
        email: email,
        password: password,
      );

      // Validation happens inside SignUpRequest
      final validationError = signUpRequest.validate();
      if (validationError != null) {
        state = state.copyWith(isLoading: false, error: validationError);
        return false;
      }

      final response = await AuthService.signUp(signUpRequest);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        successMessage: response.message,
      );
      return true;
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
      state = state.copyWith(isLoading: true, error: null);
      await AuthService.logout();
      socketService.disconnect();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

// Create the auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  print("Socket service in auth_provider: ${socketService}");
  return AuthNotifier(socketService);
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
