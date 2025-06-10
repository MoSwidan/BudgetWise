import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/payment_method.dart';
import 'models/transaction.dart';
import 'pages/home_page.dart';
import 'pages/splash_page.dart';
import 'pages/add_transaction_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  final splashSeen = settingsBox.get('onboardingComplete', defaultValue: false);

  runApp(ProviderScope(child: BudgetWiseApp(splashSeen: splashSeen)));
}

class BudgetWiseApp extends StatelessWidget {
  final bool splashSeen;

  const BudgetWiseApp({Key? key, required this.splashSeen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetWise',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: splashSeen ? '/home' : '/splash',
      routes: {
        '/splash': (context) => const OnboardingScreen(),
        '/home': (context) => const HomePage(),
        '/add-transaction': (context) => const AddTransactionPage(),
      },
    );
  }
}
