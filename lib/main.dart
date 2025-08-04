import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:homechef/l10n/app_localizations.dart';
import 'package:homechef/theme.dart';
import 'package:homechef/screens/main_navigation_screen.dart';
import 'package:homechef/core/localization/locale_provider.dart';
import 'package:homechef/supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
    
    return MaterialApp(
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
      home: const MainNavigationScreen(),
    );
  }
}
