import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:homechef/l10n/app_localizations.dart';
import 'package:homechef/theme.dart';
import 'package:homechef/core/localization/locale_provider.dart';
import 'package:homechef/supabase/supabase_config.dart';
import 'package:homechef/di/dependencies.dart';
import 'package:homechef/navigation/app_router.dart';
import 'package:homechef/services/stripe_service.dart';
import 'package:homechef/services/onesignal_service.dart';
import 'package:homechef/services/onesignal_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await SupabaseConfig.initialize();
  await initializeDependencies();
  
  // Initialize Stripe
  await StripeService.instance.initialize();
  
  // Initialize OneSignal
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
  if (oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    await OneSignalService.instance.initialize(oneSignalAppId);
    
    // CRITICAL: Wait for OneSignal to fully connect before requesting permission
    // This ensures APNs registration completes and push token is available
    debugPrint('Main: Waiting for OneSignal to fully initialize...');
    await Future.delayed(const Duration(seconds: 2));
    
    // Request permission for push notifications
    debugPrint('Main: Requesting push notification permission...');
    await OneSignalService.instance.requestPermission();
    
    // CRITICAL: Sync OneSignal External ID if user is already logged in
    // This ensures existing users get their External ID set
    // Add delay to ensure OneSignal is fully initialized (iOS SDK 5.1.2 bug workaround)
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session?.user != null) {
          debugPrint('Main: User already logged in, starting OneSignal sync...');
          await OneSignalSyncService.syncUserWithOneSignal();
        }
      } catch (e) {
        debugPrint('Main: Error during initial OneSignal sync: $e');
      }
    });
  } else {
    debugPrint('Warning: ONESIGNAL_APP_ID not found in .env file');
  }
  
  runApp(
    const ProviderScope(
      child: DinnerHelpApp(),
    ),
  );
}

class DinnerHelpApp extends ConsumerStatefulWidget {
  const DinnerHelpApp({super.key});

  @override
  ConsumerState<DinnerHelpApp> createState() => _DinnerHelpAppState();
}

class _DinnerHelpAppState extends ConsumerState<DinnerHelpApp> with WidgetsBindingObserver {
  Timer? _periodicSyncTimer;
  int _periodicSyncCount = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Set up auth state listener for OneSignal sync
    _setupAuthListener();
    
    // If user is already logged in, set up periodic sync
    // This handles the case where user was logged in from previous session
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      debugPrint('InitState: User already logged in, setting up periodic sync');
      _setupPeriodicSync();
    }
  }

  @override
  void dispose() {
    _periodicSyncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sync OneSignal when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed, checking OneSignal sync...');
      OneSignalSyncService.syncUserWithOneSignal();
    }
  }

  void _setupAuthListener() {
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      debugPrint('Auth state changed: $event');
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        // User just signed in, sync with OneSignal
        debugPrint('User signed in, syncing with OneSignal...');
        OneSignalSyncService.syncUserWithOneSignal();
        
        // Start periodic sync for new sign-ins (iOS SDK bug workaround)
        _setupPeriodicSync();
      } else if (event == AuthChangeEvent.signedOut) {
        // User signed out, clear OneSignal external ID
        debugPrint('User signed out, clearing OneSignal external ID...');
        OneSignalService.instance.removeExternalUserId();
        
        // Stop periodic sync when user signs out
        _periodicSyncTimer?.cancel();
        _periodicSyncTimer = null;
        _periodicSyncCount = 0;
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        // Token refreshed, ensure sync is still valid
        debugPrint('Token refreshed, verifying OneSignal sync...');
        OneSignalSyncService.syncUserWithOneSignal();
      }
    });
  }

  /// Set up periodic sync attempts for first 5 minutes (iOS SDK 5.1.2 bug workaround)
  void _setupPeriodicSync() {
    // Cancel any existing timer
    _periodicSyncTimer?.cancel();
    _periodicSyncCount = 0;
    
    // Sync every 60 seconds for first 5 attempts (5 minutes total)
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _periodicSyncCount++;
      
      if (_periodicSyncCount <= 5) {
        debugPrint('Main: Periodic sync attempt $_periodicSyncCount/5');
        OneSignalSyncService.syncUserWithOneSignal();
      } else {
        // Stop after 5 attempts
        debugPrint('Main: Stopping periodic sync after 5 attempts');
        timer.cancel();
        _periodicSyncTimer = null;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeNotifierProvider);
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'DinnerHelp',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      routerConfig: router,
    );
  }
}
