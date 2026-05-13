import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';

class CropGuardApp extends StatelessWidget {
  const CropGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CropGuard AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // AppLocalizations.delegate, // Uncomment after running flutter gen-l10n
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('tw'), // Twi
      ],
    );
  }
}
