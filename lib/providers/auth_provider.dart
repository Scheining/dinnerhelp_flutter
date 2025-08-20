import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/services/auth_service.dart';
import 'package:homechef/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthService(supabaseClient: supabaseClient);
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((state) => state.session?.user);
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// User profile provider
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final result = await authService.getUserProfile();
  
  return result.fold(
    (failure) => null,
    (profile) => profile,
  );
});

// Auth state notifier for sign in/sign up operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AuthState.initial());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    
    final result = await _authService.signIn(
      email: email,
      password: password,
    );
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    bool marketingConsent = false,
  }) async {
    state = const AuthState.loading();
    
    final result = await _authService.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      marketingConsent: marketingConsent,
    );
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    
    final result = await _authService.signInWithGoogle();
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signInWithApple() async {
    state = const AuthState.loading();
    
    final result = await _authService.signInWithApple();
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    
    final result = await _authService.signOut();
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (_) => const AuthState.unauthenticated(),
    );
  }

  Future<void> resetPassword(String email) async {
    state = const AuthState.loading();
    
    final result = await _authService.resetPassword(email);
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (_) => const AuthState.passwordResetSent(),
    );
  }

  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.initial();
    }
  }
}

// Auth state
abstract class AuthState {
  const AuthState();
  
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
  const factory AuthState.passwordResetSent() = AuthStatePasswordResetSent;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final User user;
  const AuthStateAuthenticated(this.user);
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();
}

// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});