import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/core/localization/locale_provider.dart';
import 'package:homechef/core/localization/app_localizations_extension.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider) ?? 
        Localizations.localeOf(context);
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        Icons.language,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        'Language',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        ref.read(localeNotifierProvider.notifier)
            .getLanguageNameForCode(currentLocale.languageCode),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: () => _showLanguageDialog(context, ref),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeNotifierProvider) ?? 
        Localizations.localeOf(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedLocales.map((locale) {
              final isSelected = currentLocale.languageCode == locale.languageCode;
              final languageName = ref.read(localeNotifierProvider.notifier)
                  .getLanguageNameForCode(locale.languageCode);
              
              return RadioListTile<String>(
                title: Text(languageName),
                value: locale.languageCode,
                groupValue: currentLocale.languageCode,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(localeNotifierProvider.notifier)
                        .setLocale(Locale(value));
                    Navigator.of(context).pop();
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text(context.l10n.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}