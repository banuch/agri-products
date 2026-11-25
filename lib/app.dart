import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'screens/auth/language_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/buyer/buyer_home.dart';
import 'screens/seller/seller_home.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';
import 'services/pincode_service.dart';
import 'state/language_controller.dart';
import 'state/session_controller.dart';
import 'widgets/common.dart';

class AgriSocietyApp extends StatelessWidget {
  const AgriSocietyApp({super.key, required this.language});

  final LanguageController language;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: language),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => DataService()),
        Provider(create: (_) => PincodeService()),
        ChangeNotifierProvider(
          create: (c) => SessionController(c.read<AuthService>(), c.read<DataService>()),
        ),
      ],
      child: const AppMaterial(home: RootGate()),
    );
  }
}

/// MaterialApp with the app's theme, languages and font-size cap.
/// Separate from [AgriSocietyApp] so tests can show any screen with it.
class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key, required this.home});

  final Widget home;

  /// Largest phone font-size multiplier we honour.
  static const maxTextScale = 1.2;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    return MaterialApp(
      title: 'Agriculture Society',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(telugu: lang.isTelugu),
      locale: lang.locale,
      supportedLocales: const [Locale('te'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Our text is already large; cap the phone's font-size setting so
      // layouts don't break on "huge font" phones.
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: maxTextScale, child: child!),
      home: home,
    );
  }
}

/// Decides the first screen: language choice → welcome/login → role home.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    if (!lang.hasChosen) return const LanguageScreen();

    final session = context.watch<SessionController>();
    switch (session.status) {
      case SessionStatus.loading:
        return const Scaffold(body: LoadingView());
      case SessionStatus.signedOut:
        return const WelcomeScreen();
      case SessionStatus.signedIn:
        return session.user!.isSeller ? const SellerHome() : const BuyerHome();
    }
  }
}

/// Shown when `flutterfire configure` has not been run yet.
class SetupRequiredApp extends StatelessWidget {
  const SetupRequiredApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 72, color: AppColors.green),
                const SizedBox(height: 16),
                const Text('Firebase setup needed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'Run "flutterfire configure" in the project folder, then restart the app. '
                  'See README.md for the steps.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 12),
                Text('$error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
