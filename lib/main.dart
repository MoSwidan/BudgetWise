import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:budgetwise/l10n/app_localizations.dart';

import 'models/payment_method.dart';
import 'models/transaction.dart';
import 'pages/home_page.dart';
import 'pages/splash_page.dart';
import 'pages/setup_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/analytics_page.dart';
import 'pages/settings_page.dart';
import 'providers/currency_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LoadingSplash()); // Show loading splash immediately

  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Register adapters only once
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PaymentMethodAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TransactionAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {  // Add this for PaymentType
    Hive.registerAdapter(PaymentTypeAdapter());
  }
  // Open boxes
  await Hive.openBox<PaymentMethod>('payment_methods');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox('settings');

  final settingsBox = Hive.box('settings');
  final onboardingComplete = settingsBox.get('onboardingComplete', defaultValue: false);
  final currency = settingsBox.get('currency', defaultValue: 'USD');
  final localeCode = settingsBox.get('language', defaultValue: 'en');
  final locale = Locale(localeCode);

  runApp(ProviderScope(child: BudgetWiseApp(
    onboardingComplete: onboardingComplete, 
    initialCurrency: currency, 
    initialLocale: locale
  )));
}

class BudgetWiseApp extends StatefulWidget {
  final bool onboardingComplete;
  final String initialCurrency;
  final Locale initialLocale;
  const BudgetWiseApp({
    super.key, 
    required this.onboardingComplete, 
    required this.initialCurrency, 
    required this.initialLocale
  });
  @override
  State<BudgetWiseApp> createState() => _BudgetWiseAppState();
}

class _BudgetWiseAppState extends State<BudgetWiseApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final settingsBox = Hive.box('settings');
    final themeMode = settingsBox.get('themeMode', defaultValue: 'system');
    setState(() {
      _themeMode = _getThemeModeFromString(themeMode);
    });
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);
  void setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final currency = ref.watch(currencyProvider);
          return MaterialApp(
            title: 'BudgetWise',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: _themeMode,
            locale: _locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: widget.onboardingComplete ? '/home' : '/setup',
            routes: {
              '/splash': (context) => const OnboardingScreen(),
              '/setup': (context) => SetupPage(
                onLocaleChanged: (locale) {
                  setLocale(locale);
                },
              ),
              '/home': (context) => const HomePage(),
              '/add-transaction': (context) => const AddTransactionPage(),
              '/analytics': (context) => const AnalyticsPage(),
              '/settings': (context) => SettingsPage(
                onThemeChanged: setThemeMode,
                onLocaleChanged: setLocale,
                onCurrencyChanged: (c) => ref.read(currencyProvider.notifier).setCurrency(c),
                currentCurrency: currency,
              ),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData.light(useMaterial3: true).copyWith(
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineLarge: ThemeData.light().textTheme.headlineLarge?.copyWith(fontSize: 28),
        headlineMedium: ThemeData.light().textTheme.headlineMedium?.copyWith(fontSize: 24),
        headlineSmall: ThemeData.light().textTheme.headlineSmall?.copyWith(fontSize: 20),
        titleLarge: ThemeData.light().textTheme.titleLarge?.copyWith(fontSize: 18),
        titleMedium: ThemeData.light().textTheme.titleMedium?.copyWith(fontSize: 16),
        titleSmall: ThemeData.light().textTheme.titleSmall?.copyWith(fontSize: 14),
        bodyLarge: ThemeData.light().textTheme.bodyLarge?.copyWith(fontSize: 14),
        bodyMedium: ThemeData.light().textTheme.bodyMedium?.copyWith(fontSize: 13),
        bodySmall: ThemeData.light().textTheme.bodySmall?.copyWith(fontSize: 12),
        labelLarge: ThemeData.light().textTheme.labelLarge?.copyWith(fontSize: 13),
        labelMedium: ThemeData.light().textTheme.labelMedium?.copyWith(fontSize: 12),
        labelSmall: ThemeData.light().textTheme.labelSmall?.copyWith(fontSize: 11),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      textTheme: ThemeData.dark().textTheme.copyWith(
        headlineLarge: ThemeData.dark().textTheme.headlineLarge?.copyWith(fontSize: 28),
        headlineMedium: ThemeData.dark().textTheme.headlineMedium?.copyWith(fontSize: 24),
        headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(fontSize: 20),
        titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(fontSize: 18),
        titleMedium: ThemeData.dark().textTheme.titleMedium?.copyWith(fontSize: 16),
        titleSmall: ThemeData.dark().textTheme.titleSmall?.copyWith(fontSize: 14),
        bodyLarge: ThemeData.dark().textTheme.bodyLarge?.copyWith(fontSize: 14),
        bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(fontSize: 13),
        bodySmall: ThemeData.dark().textTheme.bodySmall?.copyWith(fontSize: 12),
        labelLarge: ThemeData.dark().textTheme.labelLarge?.copyWith(fontSize: 13),
        labelMedium: ThemeData.dark().textTheme.labelMedium?.copyWith(fontSize: 12),
        labelSmall: ThemeData.dark().textTheme.labelSmall?.copyWith(fontSize: 11),
      ),
    );
  }
}

class LoadingSplash extends StatelessWidget {
  const LoadingSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.indigo,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo (use a placeholder asset or network image for now)
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.account_balance_wallet, size: 100, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'BudgetWise',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
