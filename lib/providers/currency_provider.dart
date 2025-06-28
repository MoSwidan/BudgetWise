import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) => CurrencyNotifier());

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super(_getInitialCurrency());

  static String _getInitialCurrency() {
    final box = Hive.box('settings');
    return box.get('currency', defaultValue: 'USD');
  }

  void setCurrency(String currency) {
    final box = Hive.box('settings');
    box.put('currency', currency);
    state = currency;
  }
} 