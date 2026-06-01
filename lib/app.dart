import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/screens/settings/language_provider.dart';
import 'presentation/screens/settings/settings_provider.dart';

class CropGuardApp extends StatelessWidget {
  const CropGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, SettingsProvider>(
      builder: (context, langProvider, settings, _) {
        return MaterialApp.router(
          title: 'CropGuard AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          locale: Locale(langProvider.currentLanguage.code),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            final scale = settings.largeTextMode ? 1.3 : 1.0;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
