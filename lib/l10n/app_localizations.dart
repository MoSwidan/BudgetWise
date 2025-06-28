import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BudgetWise'**
  String get appTitle;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods'**
  String get noPaymentMethods;

  /// No description provided for @pleaseAddPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please add a payment method first.'**
  String get pleaseAddPaymentMethod;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expenses'**
  String get incomeVsExpenses;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @noPaymentMethodsYet.
  ///
  /// In en, this message translates to:
  /// **'No payment methods yet'**
  String get noPaymentMethodsYet;

  /// No description provided for @addYourFirstPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add your first payment method above'**
  String get addYourFirstPaymentMethod;

  /// No description provided for @deletePaymentMethodError.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete: This payment method is used in a transaction.'**
  String get deletePaymentMethodError;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionConfirm;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @monthlyOverview.
  ///
  /// In en, this message translates to:
  /// **'Monthly Overview'**
  String get monthlyOverview;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @addMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Method'**
  String get addMethod;

  /// No description provided for @addTransactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully!'**
  String get addTransactionSuccess;

  /// No description provided for @editTransactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully!'**
  String get editTransactionSuccess;

  /// No description provided for @deleteTransactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully!'**
  String get deleteTransactionSuccess;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @addYourFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction to get started'**
  String get addYourFirstTransaction;

  /// No description provided for @welcomeToBudgetWise.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BudgetWise'**
  String get welcomeToBudgetWise;

  /// No description provided for @setupYourPreferences.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your preferences'**
  String get setupYourPreferences;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD - US Dollar'**
  String get usd;

  /// No description provided for @eur.
  ///
  /// In en, this message translates to:
  /// **'EUR - Euro'**
  String get eur;

  /// No description provided for @gbp.
  ///
  /// In en, this message translates to:
  /// **'GBP - British Pound'**
  String get gbp;

  /// No description provided for @jpy.
  ///
  /// In en, this message translates to:
  /// **'JPY - Japanese Yen'**
  String get jpy;

  /// No description provided for @cad.
  ///
  /// In en, this message translates to:
  /// **'CAD - Canadian Dollar'**
  String get cad;

  /// No description provided for @aud.
  ///
  /// In en, this message translates to:
  /// **'AUD - Australian Dollar'**
  String get aud;

  /// No description provided for @chf.
  ///
  /// In en, this message translates to:
  /// **'CHF - Swiss Franc'**
  String get chf;

  /// No description provided for @cny.
  ///
  /// In en, this message translates to:
  /// **'CNY - Chinese Yuan'**
  String get cny;

  /// No description provided for @inr.
  ///
  /// In en, this message translates to:
  /// **'INR - Indian Rupee'**
  String get inr;

  /// No description provided for @aed.
  ///
  /// In en, this message translates to:
  /// **'AED - UAE Dirham'**
  String get aed;

  /// No description provided for @sar.
  ///
  /// In en, this message translates to:
  /// **'SAR - Saudi Riyal'**
  String get sar;

  /// No description provided for @egp.
  ///
  /// In en, this message translates to:
  /// **'EGP - Egyptian Pound'**
  String get egp;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @filterByMethod.
  ///
  /// In en, this message translates to:
  /// **'Filter by payment method'**
  String get filterByMethod;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noSpendingDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No spending data available'**
  String get noSpendingDataAvailable;

  /// No description provided for @noTransactionDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No transaction data available'**
  String get noTransactionDataAvailable;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Data, Your Device'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'All your financial data stays securely on your device with end-to-end encryption.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingFeature1_1.
  ///
  /// In en, this message translates to:
  /// **'Bank-level security'**
  String get onboardingFeature1_1;

  /// No description provided for @onboardingFeature1_2.
  ///
  /// In en, this message translates to:
  /// **'No cloud storage'**
  String get onboardingFeature1_2;

  /// No description provided for @onboardingFeature1_3.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get onboardingFeature1_3;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Smart Money Insights'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Get powerful analytics to understand your spending patterns.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingFeature2_1.
  ///
  /// In en, this message translates to:
  /// **'Visual spending reports'**
  String get onboardingFeature2_1;

  /// No description provided for @onboardingFeature2_2.
  ///
  /// In en, this message translates to:
  /// **'Customizable budgets'**
  String get onboardingFeature2_2;

  /// No description provided for @onboardingFeature2_3.
  ///
  /// In en, this message translates to:
  /// **'Trend analysis'**
  String get onboardingFeature2_3;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'All Payment Methods'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Track all your accounts in one place.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingFeature3_1.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Cards'**
  String get onboardingFeature3_1;

  /// No description provided for @onboardingFeature3_2.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallets'**
  String get onboardingFeature3_2;

  /// No description provided for @onboardingFeature3_3.
  ///
  /// In en, this message translates to:
  /// **'Cash & Bank Accounts'**
  String get onboardingFeature3_3;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BudgetWise'**
  String get welcome;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your preferences'**
  String get setupSubtitle;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @eWallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get eWallet;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon! Add some transactions to see your analytics.'**
  String get comingSoon;

  /// No description provided for @paymentMethodUsage.
  ///
  /// In en, this message translates to:
  /// **'Payment Method Usage'**
  String get paymentMethodUsage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @useLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Use light theme'**
  String get useLightTheme;

  /// No description provided for @useDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get useDarkTheme;

  /// No description provided for @useSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Follow system theme'**
  String get useSystemTheme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
