import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Main navigation
import 'package:homechef/screens/main_navigation_screen.dart';
import 'package:homechef/screens/home_screen.dart';
import 'package:homechef/screens/search_screen.dart';
import 'package:homechef/screens/bookings_screen.dart';
import 'package:homechef/screens/notifications_screen.dart';
import 'package:homechef/screens/profile_screen.dart';
import 'package:homechef/screens/chef_profile_screen.dart';

// Profile screens
import 'package:homechef/screens/profile/personal_information_screen.dart';
import 'package:homechef/screens/profile/service_addresses_screen.dart';
import 'package:homechef/screens/profile/notifications_settings_screen.dart';

// Auth screens
import 'package:homechef/screens/auth/sign_in_screen.dart';
import 'package:homechef/screens/auth/sign_up_screen.dart';

// Booking flow screens
import 'package:homechef/features/booking/presentation/screens/chef_search_results_screen.dart';
import 'package:homechef/features/booking/presentation/screens/dish_selection_screen.dart';
import 'package:homechef/features/booking/presentation/screens/booking_summary_screen.dart';
import 'package:homechef/features/booking/presentation/screens/booking_management_screen.dart';

// Payment screens
import 'package:homechef/features/payment/presentation/screens/payment_processing_screen.dart';
import 'package:homechef/features/payment/presentation/screens/payment_history_screen.dart';

// Notification screens
import 'package:homechef/features/notifications/presentation/pages/notification_preferences_page.dart';

// Models
import 'package:homechef/models/chef.dart';
import 'package:homechef/features/booking/domain/entities/booking_request.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: AuthStateNotifier(),
    redirect: (context, state) {
      // Check if user is authenticated
      final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
      final isAuthRoute = state.uri.path.startsWith('/auth');
      
      debugPrint('Router redirect - Authenticated: $isAuthenticated, AuthRoute: $isAuthRoute, Path: ${state.uri.path}');
      
      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/signin';
      }
      
      // If authenticated and trying to access auth routes
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // Search tab
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
            routes: [
              // Chef search results
              GoRoute(
                path: '/results',
                name: 'chef-search-results',
                builder: (context, state) {
                  // For now, return with empty chef list
                  // This should be populated from a provider or passed as extra
                  return ChefSearchResultsScreen(
                    allChefs: const [],
                    onChefSelected: (chef) {
                      // Navigate to chef profile or booking screen
                      context.go('/chef/${chef.id}');
                    },
                  );
                },
              ),
            ],
          ),
          
          // Bookings tab
          GoRoute(
            path: '/bookings',
            name: 'bookings',
            builder: (context, state) => const BookingsScreen(),
            routes: [
              // Booking management
              GoRoute(
                path: '/manage/:bookingId',
                name: 'booking-management',
                builder: (context, state) {
                  // For now, return with empty bookings list
                  // In a real app, this would fetch bookings from a provider
                  return BookingManagementScreen(
                    bookings: const [],
                    onModifyBooking: (bookingId) {
                      // Handle booking modification
                    },
                    onCancelBooking: (bookingId) {
                      // Handle booking cancellation
                    },
                    onContactChef: (bookingId) {
                      // Handle contacting chef
                    },
                  );
                },
              ),
            ],
          ),
          
          // Messages tab (using NotificationsScreen with messages tab preselected)
          GoRoute(
            path: '/messages',
            name: 'messages',
            builder: (context, state) => const NotificationsScreen(initialTabIndex: 1),
          ),
          
          // Profile tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // Personal information
              GoRoute(
                path: 'personal-information',
                name: 'personal-information',
                builder: (context, state) => const PersonalInformationScreen(),
              ),
              // Service addresses
              GoRoute(
                path: 'service-addresses',
                name: 'service-addresses',
                builder: (context, state) => const ServiceAddressesScreen(),
              ),
              // Old route for compatibility
              GoRoute(
                path: 'delivery-addresses',
                redirect: (context, state) => '/profile/service-addresses',
              ),
              // Notification settings
              GoRoute(
                path: 'notifications',
                name: 'notifications-settings',
                builder: (context, state) => const NotificationsSettingsScreen(),
              ),
              // Notification preferences (old route kept for compatibility)
              GoRoute(
                path: '/notifications-old',
                name: 'notification-preferences',
                builder: (context, state) => const NotificationPreferencesPage(
                  userId: 'current-user-id', // TODO: Get from auth provider
                ),
              ),
              // Payment history
              GoRoute(
                path: 'payment-history',
                name: 'payment-history',
                builder: (context, state) => const PaymentHistoryScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Chef profile (outside main navigation)
      GoRoute(
        path: '/chef/:chefId',
        name: 'chef-profile',
        builder: (context, state) {
          final chef = state.extra as Chef?;
          // If chef is passed as extra, use it. Otherwise, this would need to fetch from a provider
          if (chef != null) {
            return ChefProfileScreen(chef: chef);
          } else {
            // For now, return error screen as we don't have the chef data
            // In a real app, this would fetch from a provider using chefId
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Chef data not found. Please go back and try again.'),
              ),
            );
          }
        },
      ),
      
      // Booking flow (outside main navigation)
      GoRoute(
        path: '/booking/dish-selection',
        name: 'dish-selection',
        builder: (context, state) {
          final chefId = state.uri.queryParameters['chefId'] ?? '';
          final chefName = state.uri.queryParameters['chefName'] ?? 'Chef';
          
          // For now, return with empty dishes list
          // In a real app, this would fetch from a provider
          return DishSelectionScreen(
            chefId: chefId,
            chefName: chefName,
            availableDishes: const [],
            onSelectionComplete: (dishes, customRequest) {
              // Handle dish selection completion
              // This would navigate to booking summary
            },
          );
        },
      ),
      
      GoRoute(
        path: '/booking/summary',
        name: 'booking-summary',
        builder: (context, state) {
          // For now, return error screen as we need complex booking data
          // In a real app, this would receive data from previous screens or providers
          return Scaffold(
            appBar: AppBar(title: const Text('Booking Summary')),
            body: const Center(
              child: Text('Booking data not available. Please start the booking process again.'),
            ),
          );
        },
      ),
      
      GoRoute(
        path: '/booking/payment',
        name: 'payment-processing',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return PaymentProcessingScreen(bookingId: bookingId);
        },
      ),
      
      // Booking confirmation
      GoRoute(
        path: '/booking/confirmation/:bookingId',
        name: 'booking-confirmation',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you requested could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Extension methods for navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to chef profile
  void goToChefProfile(String chefId, {Chef? chef}) {
    go('/chef/$chefId', extra: chef);
  }
  
  /// Navigate to dish selection
  void goToDishSelection({
    required String chefId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int guests,
  }) {
    go('/booking/dish-selection'
        '?chefId=$chefId'
        '&date=${date.toIso8601String()}'
        '&startTime=$startTime'
        '&endTime=$endTime'
        '&guests=$guests');
  }
  
  /// Navigate to booking summary
  void goToBookingSummary(BookingRequest bookingRequest) {
    go('/booking/summary', extra: bookingRequest);
  }
  
  /// Navigate to payment processing
  void goToPaymentProcessing(String bookingId) {
    go('/booking/payment/$bookingId');
  }
  
  /// Navigate to booking confirmation
  void goToBookingConfirmation(String bookingId) {
    go('/booking/confirmation/$bookingId');
  }
  
  /// Navigate to chef search results
  void goToSearchResults({
    String? query,
    String? location,
    DateTime? date,
    int guests = 2,
  }) {
    final queryParams = <String, String>{};
    if (query != null) queryParams['query'] = query;
    if (location != null) queryParams['location'] = location;
    if (date != null) queryParams['date'] = date.toIso8601String();
    queryParams['guests'] = guests.toString();
    
    final uri = Uri(path: '/search/results', queryParameters: queryParams);
    go(uri.toString());
  }
  
  /// Navigate to booking management
  void goToBookingManagement(String bookingId) {
    go('/bookings/manage/$bookingId');
  }
  
  /// Navigate to notification preferences
  void goToNotificationPreferences() {
    go('/profile/notifications');
  }
  
  /// Navigate to payment history
  void goToPaymentHistory() {
    go('/profile/payment-history');
  }
}

/// Booking confirmation screen widget
class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  
  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Your booking has been successfully created.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Booking ID: $bookingId',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/bookings'),
                  child: const Text('View Bookings'),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifier for auth state changes to refresh router
class AuthStateNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _authSubscription;
  
  AuthStateNotifier() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      debugPrint('Auth state changed: ${data.event}');
      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}