import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class CurrencyService {
  static const String _currencyKey = 'currency';
  static const String _defaultCurrency = 'USD';
  
  // Currency symbols and formatting
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'INR': '₹',
    'AED': 'د.إ',
    'SAR': 'ر.س',
    'EGP': 'ج.م',
  };
  
  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'EGP': 'Egyptian Pound',
  };

  // Get current currency from settings
  static String getCurrentCurrency() {
    try {
      final settingsBox = Hive.box('settings');
      return settingsBox.get(_currencyKey, defaultValue: _defaultCurrency);
    } catch (e) {
      return _defaultCurrency;
    }
  }

  // Save currency to settings
  static Future<void> setCurrency(String currency) async {
    try {
      final settingsBox = Hive.box('settings');
      await settingsBox.put(_currencyKey, currency);
    } catch (e) {
      // Handle error
    }
  }

  // Get currency symbol (locale-aware for EGP)
  static String getCurrencySymbol(String? currency, {Locale? locale}) {
    final code = currency ?? getCurrentCurrency();
    if (code == 'EGP') {
      if (locale != null && locale.languageCode == 'ar') {
        return 'ج.م';
      } else {
        return 'EGP';
      }
    }
    return _currencySymbols[code] ?? code;
  }

  // Get currency name
  static String getCurrencyName(String? currency) {
    final code = currency ?? getCurrentCurrency();
    return _currencyNames[code] ?? code;
  }

  // Format amount with currency - updated to use locale
  static String formatAmount(double amount, {String? currency, Locale? locale}) {
    final code = currency ?? getCurrentCurrency();
    final symbol = getCurrencySymbol(code);
    
    // If locale is provided, use localized formatting
    if (locale != null) {
      return formatAmountLocalized(amount, currency: currency, locale: locale);
    }
    
    // Format with proper decimal places
    final formattedAmount = amount.toStringAsFixed(_getDecimalDigits(code));
    
    // Add thousand separators if needed
    final parts = formattedAmount.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );
    
    if (parts.length > 1) {
      return '$symbol$integerPart.${parts[1]}';
    }
    return '$symbol$integerPart';
  }

  // Format amount with NumberFormat for better localization
  static String formatAmountLocalized(double amount, {String? currency, Locale? locale}) {
    final code = currency ?? getCurrentCurrency();
    
    try {
      // Use provided locale or determine based on currency
      String localeString;
      if (locale != null) {
        localeString = locale.languageCode == 'ar' ? 'ar_SA' : 'en_US';
      } else {
        switch (code) {
          case 'EUR':
            localeString = 'de_DE'; // German locale for Euro
            break;
          case 'GBP':
            localeString = 'en_GB'; // British locale for Pound
            break;
          case 'JPY':
            localeString = 'ja_JP'; // Japanese locale for Yen
            break;
          case 'CNY':
            localeString = 'zh_CN'; // Chinese locale for Yuan
            break;
          case 'INR':
            localeString = 'en_IN'; // Indian locale for Rupee
            break;
          case 'AED':
          case 'SAR':
            localeString = 'ar_SA'; // Arabic locale for Dirham/Riyal
            break;
          case 'EGP':
            localeString = 'ar_EG'; // Egyptian locale for Pound
            break;
          default:
            localeString = 'en_US'; // Default to US locale
        }
      }
      
      final formatter = NumberFormat.currency(
        locale: localeString,
        symbol: getCurrencySymbol(code, locale: locale),
        decimalDigits: _getDecimalDigits(code),
      );
      
      return formatter.format(amount);
    } catch (e) {
      // Fallback to simple formatting
      return formatAmount(amount, currency: currency);
    }
  }

  // Get decimal digits for currency
  static int _getDecimalDigits(String currency) {
    switch (currency) {
      case 'JPY':
      case 'CNY':
      case 'INR':
        return 0;
      default:
        return 2;
    }
  }

  // Get all available currencies
  static Map<String, String> getAvailableCurrencies() {
    return Map.from(_currencyNames);
  }

  // Get currency display name (code + name)
  static String getCurrencyDisplayName(String currency) {
    final name = _currencyNames[currency];
    return name != null ? '$currency - $name' : currency;
  }

  // Parse amount from string
  static double? parseAmount(String amountString, {String? currency}) {
    try {
      // Remove currency symbols and commas
      String cleanString = amountString;
      final code = currency ?? getCurrentCurrency();
      final symbol = getCurrencySymbol(code);
      
      cleanString = cleanString.replaceAll(symbol, '');
      cleanString = cleanString.replaceAll(',', '');
      cleanString = cleanString.trim();
      
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  // Convert amount between currencies (basic implementation)
  // In a real app, you would use exchange rate APIs
  static double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    // This is a simplified conversion - in reality you'd use real exchange rates
    // For now, we'll use some basic conversion rates
    final conversionRates = {
      'USD': 1.0,
      'EUR': 0.85,
      'GBP': 0.73,
      'JPY': 110.0,
      'CAD': 1.25,
      'AUD': 1.35,
      'CHF': 0.92,
      'CNY': 6.45,
      'INR': 75.0,
      'AED': 3.67,
      'SAR': 3.75,
      'EGP': 15.7,
    };
    
    final fromRate = conversionRates[fromCurrency] ?? 1.0;
    final toRate = conversionRates[toCurrency] ?? 1.0;
    
    return (amount / fromRate) * toRate;
  }
} 