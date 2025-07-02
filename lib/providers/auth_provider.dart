import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  final ApiService _apiService = ApiService();

  Future<void> _checkAuthStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');

      if (token != null && userJson != null) {
        _apiService.setAuthToken(token);
        // In a real app, you might want to validate the token with the server
        state = state.copyWith(
          isAuthenticated: true,
          user: User(
            id: '1',
            name: 'Demo User',
            email: userJson, // Use the actual stored email
          ),
        );
      } else {
        // Ensure state is reset when no auth data
        state = AuthState(
          user: null,
          isLoading: false,
          error: null,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      // Handle error and reset state
      state = AuthState(
        user: null,
        isLoading: false,
        error: null,
        isAuthenticated: false,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // For demo purposes, accept any valid email/password
      if (email.contains('@') && password.length >= 6) {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        final user = User(
          id: '1',
          name: 'Demo User',
          email: email,
        );

        // Save to local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'demo_token_123');
        await prefs.setString('user_data', user.email);

        _apiService.setAuthToken('demo_token_123');

        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // For demo purposes, accept any valid input
      if (name.isNotEmpty && email.contains('@') && password.length >= 6) {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        final user = User(
          id: '1',
          name: name,
          email: email,
        );

        // Save to local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'demo_token_123');
        await prefs.setString('user_data', user.email);

        _apiService.setAuthToken('demo_token_123');

        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Please fill all fields correctly',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    // Set loading state first
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Handle error silently
    } finally {
      // Clear local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      _apiService.clearAuthToken();

      // Reset to completely new, clean state
      state = AuthState(
        user: null,
        isLoading: false,
        error: null,
        isAuthenticated: false,
      );
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    if (state.user == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedUser = User(
        id: state.user!.id,
        name: name,
        email: email,
        profileImage: state.user!.profileImage,
      );

      // Update local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', updatedUser.email);

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Profile update failed: ${e.toString()}',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Force recheck auth status (useful after onboarding)
  Future<void> recheckAuthStatus() async {
    await _checkAuthStatus();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final userProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
