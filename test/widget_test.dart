import 'dart:io';

import 'package:budgetwise/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:budgetwise/models/payment_method.dart';
import 'package:budgetwise/models/transaction.dart';

void main() {
  setUpAll(() async {
    // Use a temporary directory for Hive in tests
    final tempDir = Directory.systemTemp.createTempSync();
    await Hive.initFlutter(tempDir.path);

    // Register adapters only once
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PaymentMethodAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    // Open boxes needed for the app
    await Hive.openBox<PaymentMethod>('payment_methods');
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App starts and shows splash or home depending on setting', (WidgetTester tester) async {
    // Set splashSeen to true to go directly to home
    var settingsBox = Hive.box('settings');
    await settingsBox.put('splashSeen', true);

    await tester.pumpWidget(const ProviderScope(child: BudgetWiseApp(splashSeen: true)));
    await tester.pumpAndSettle();

    expect(find.text('BudgetWise'), findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
  });
}
