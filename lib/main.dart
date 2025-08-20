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
    // Request permission for push notifications
    await OneSignalService.instance.requestPermission();
  } else {
    debugPrint('Warning: ONESIGNAL_APP_ID not found in .env file');
  }
  
  runApp(
    const ProviderScope(
      child: DinnerHelpApp(),
    ),
  );
}

class DinnerHelpApp extends ConsumerWidget {
  const DinnerHelpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
