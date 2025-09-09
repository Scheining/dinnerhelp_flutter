import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';
import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import 'package:homechef/services/onesignal_sync_service.dart';

class AuthService {
  final SupabaseClient _supabaseClient;
  
  AuthService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;
  
  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;
  
  // Get current session
  Session? get currentSession => _supabaseClient.auth.currentSession;
  
  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
  
  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
  
  /// Sign up with email and password
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    bool marketingConsent = false,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          'is_chef': false,
          'is_admin': false,
          'role': 'user', // Explicitly set role to 'user', not 'chef'
        },
      );

      if (response.user == null) {
        return Left(AuthFailure('Kunne ikke oprette bruger'));
      }

      // The trigger should create a basic profile, but let's make sure
      // Wait a moment for the trigger to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        // Check if profile exists
        final existingProfile = await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();
            
        if (existingProfile == null) {
          // Profile doesn't exist, create it
          print('Profile not created by trigger, creating manually...');
          await _supabaseClient
              .from('profiles')
              .insert({
                'id': response.user!.id,
                'first_name': firstName,
                'last_name': lastName,
                'email': email,
                'phone_number': phone,
                'is_chef': false,
                'is_admin': false,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
        } else {
          // Profile exists, update it with additional information
          print('Profile exists, updating with additional info...');
          await _supabaseClient
              .from('profiles')
              .update({
                'first_name': firstName,
                'last_name': lastName,
                'email': email,
                'phone_number': phone,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', response.user!.id);
        }
      } catch (e) {
        print('Warning: Could not create/update profile after signup: $e');
        // Don't fail the signup if profile creation/update fails
      }

      // CRITICAL: Sync with OneSignal after successful signup
      // This ensures the External User ID is set for push notifications
      try {
        print('AuthService: Syncing new user with OneSignal...');
        await OneSignalSyncService.syncUserWithOneSignal();
      } catch (e) {
        print('AuthService: Failed to sync with OneSignal (non-critical): $e');
        // Don't fail signup if OneSignal sync fails
      }

      // Add to Brevo mailing list and send welcome email via Edge Function
      try {
        final brevoResponse = await _supabaseClient.functions.invoke(
          'add-to-brevo',
          body: {
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'phone': phone,
            'marketingConsent': marketingConsent,
            'sendWelcomeEmail': true,
          },
        );
        
        if (brevoResponse.data != null) {
          print('✅ Successfully processed Brevo request');
        } else {
          print('⚠️ Brevo Edge Function returned no data');
        }
      } catch (e) {
        // Don't fail sign up if Brevo fails
        print('⚠️ Failed to call Brevo Edge Function: $e');
      }

      return Right(response.user!);
    } on AuthException catch (e) {
      print('AuthException during sign up: ${e.message}');
      return Left(AuthFailure(_mapAuthError(e.message)));
    } on PostgrestException catch (e) {
      print('PostgrestException during sign up: ${e.message}');
      print('Details: ${e.details}');
      print('Code: ${e.code}');
      return Left(AuthFailure('Database fejl: ${e.message}'));
    } catch (e, stackTrace) {
      print('Unexpected error during sign up: $e');
      print('Stack trace: $stackTrace');
      return Left(AuthFailure('En uventet fejl opstod: ${e.toString()}'));
    }
  }

  /// Sign in with email and password
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Left(AuthFailure('Login fejlede'));
      }

      // CRITICAL: Sync with OneSignal after successful signin
      // This ensures the External User ID is set for push notifications
      try {
        print('AuthService: Syncing signed-in user with OneSignal...');
        await OneSignalSyncService.syncUserWithOneSignal();
      } catch (e) {
        print('AuthService: Failed to sync with OneSignal (non-critical): $e');
        // Don't fail signin if OneSignal sync fails
      }

      return Right(response.user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e) {
      return Left(AuthFailure('En uventet fejl opstod: ${e.toString()}'));
    }
  }

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle({String? phone, bool marketingConsent = false}) async {
    try {
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'dk.dinnerhelp://login-callback',
      );

      if (!response) {
        return Left(AuthFailure('Google login fejlede'));
      }

      // Wait for auth state to update
      await Future.delayed(const Duration(seconds: 1));
      
      final user = currentUser;
      if (user == null) {
        return Left(AuthFailure('Kunne ikke hente brugeroplysninger'));
      }

      // Check if profile exists, if not create it
      final profile = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        final firstName = user.userMetadata?['full_name']?.split(' ').first ?? '';
        final lastName = user.userMetadata?['full_name']?.split(' ').last ?? '';
        
        await _supabaseClient.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          'is_chef': false,
          'is_admin': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Add to Brevo mailing list and send welcome email to new users
        if (user.email != null) {
          try {
            final brevoResponse = await _supabaseClient.functions.invoke(
              'add-to-brevo',
              body: {
                'email': user.email!,
                'firstName': firstName,
                'lastName': lastName,
                'phone': phone,
                'marketingConsent': marketingConsent && phone != null,
                'sendWelcomeEmail': true,
              },
            );
            
            if (brevoResponse.data != null) {
              print('✅ Successfully processed Brevo request');
            } else {
              print('⚠️ Brevo Edge Function returned no data');
            }
          } catch (e) {
            print('⚠️ Failed to call Brevo Edge Function: $e');
          }
        }
      } else if (phone != null && profile['phone_number'] == null) {
        // Update phone if it wasn't set before
        await _supabaseClient
            .from('profiles')
            .update({'phone_number': phone})
            .eq('id', user.id);
      }

      // CRITICAL: Sync with OneSignal after successful Google signin
      // This ensures the External User ID is set for push notifications
      try {
        print('AuthService: Syncing Google-signed-in user with OneSignal...');
        await OneSignalSyncService.syncUserWithOneSignal();
      } catch (e) {
        print('AuthService: Failed to sync with OneSignal (non-critical): $e');
        // Don't fail signin if OneSignal sync fails
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e) {
      return Left(AuthFailure('Google login fejlede: ${e.toString()}'));
    }
  }

  /// Sign in with Apple
  Future<Either<Failure, User>> signInWithApple({String? phone, bool marketingConsent = false}) async {
    try {
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'dk.dinnerhelp://login-callback',
      );

      if (!response) {
        return Left(AuthFailure('Apple login fejlede'));
      }

      // Wait for auth state to update
      await Future.delayed(const Duration(seconds: 1));
      
      final user = currentUser;
      if (user == null) {
        return Left(AuthFailure('Kunne ikke hente brugeroplysninger'));
      }

      // Check if profile exists, if not create it
      final profile = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        final firstName = user.userMetadata?['full_name']?.split(' ').first ?? '';
        final lastName = user.userMetadata?['full_name']?.split(' ').last ?? '';
        
        await _supabaseClient.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          'is_chef': false,
          'is_admin': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Add to Brevo mailing list and send welcome email to new users
        if (user.email != null) {
          try {
            final brevoResponse = await _supabaseClient.functions.invoke(
              'add-to-brevo',
              body: {
                'email': user.email!,
                'firstName': firstName,
                'lastName': lastName,
                'phone': phone,
                'marketingConsent': marketingConsent && phone != null,
                'sendWelcomeEmail': true,
              },
            );
            
            if (brevoResponse.data != null) {
              print('✅ Successfully processed Brevo request');
            } else {
              print('⚠️ Brevo Edge Function returned no data');
            }
          } catch (e) {
            print('⚠️ Failed to call Brevo Edge Function: $e');
          }
        }
      } else if (phone != null && profile['phone_number'] == null) {
        // Update phone if it wasn't set before
        await _supabaseClient
            .from('profiles')
            .update({'phone_number': phone})
            .eq('id', user.id);
      }

      // CRITICAL: Sync with OneSignal after successful Apple signin
      // This ensures the External User ID is set for push notifications
      try {
        print('AuthService: Syncing Apple-signed-in user with OneSignal...');
        await OneSignalSyncService.syncUserWithOneSignal();
      } catch (e) {
        print('AuthService: Failed to sync with OneSignal (non-critical): $e');
        // Don't fail signin if OneSignal sync fails
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e) {
      return Left(AuthFailure('Apple login fejlede: ${e.toString()}'));
    }
  }

  /// Sign out
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e) {
      return Left(AuthFailure('Kunne ikke logge ud: ${e.toString()}'));
    }
  }

  /// Send password reset email
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'dk.dinnerhelp://reset-password',
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e) {
      return Left(AuthFailure('Kunne ikke sende nulstillingsmail: ${e.toString()}'));
    }
  }

  /// Update user password
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e) {
      return Left(AuthFailure('Kunne ikke opdatere adgangskode: ${e.toString()}'));
    }
  }

  /// Update user profile
  Future<Either<Failure, void>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return Left(AuthFailure('Ingen bruger logget ind'));
      }

      final updates = <String, dynamic>{
        'id': user.id,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;

      await _supabaseClient
          .from('profiles')
          .update(updates)
          .eq('id', user.id);

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Kunne ikke opdatere profil: ${e.toString()}'));
    }
  }

  /// Get user profile
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) {
        return Left(AuthFailure('Ingen bruger logget ind'));
      }

      final profile = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Right(profile);
    } catch (e) {
      return Left(AuthFailure('Kunne ikke hente profil: ${e.toString()}'));
    }
  }

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        return Left(AuthFailure('Ingen bruger logget ind'));
      }

      // Delete profile first (cascade will handle related data)
      await _supabaseClient
          .from('profiles')
          .delete()
          .eq('id', user.id);

      // Then delete auth user
      // Note: This requires admin privileges or a server-side function
      // For now, we'll just sign out
      await signOut();

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Kunne ikke slette konto: ${e.toString()}'));
    }
  }

  /// Map auth error messages to Danish
  String _mapAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Ugyldig email eller adgangskode';
    } else if (error.contains('Email not confirmed')) {
      return 'Email er ikke bekræftet. Tjek din indbakke';
    } else if (error.contains('User already registered')) {
      return 'En bruger med denne email eksisterer allerede';
    } else if (error.contains('Password should be at least')) {
      return 'Adgangskoden skal være mindst 6 tegn';
    } else if (error.contains('Invalid email')) {
      return 'Ugyldig email adresse';
    } else if (error.contains('Network')) {
      return 'Netværksfejl. Tjek din internetforbindelse';
    } else {
      return 'En fejl opstod. Prøv igen senere';
    }
  }
}

// Auth Failure class
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}