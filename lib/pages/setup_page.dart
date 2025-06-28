import 'package:flutter/material.dart';
import 'package:budgetwise/l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/currency_provider.dart';

class SetupPage extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  const SetupPage({super.key, this.onLocaleChanged});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  String selectedLanguage = 'en';
  String selectedCurrency = 'USD';
  bool isLoading = false;

  final Map<String, String> languages = {
    'en': 'English',
    'ar': 'العربية',
  };

  final Map<String, String> currencies = {
    'USD': 'USD - US Dollar',
    'EUR': 'EUR - Euro',
    'GBP': 'GBP - British Pound',
    'JPY': 'JPY - Japanese Yen',
    'CAD': 'CAD - Canadian Dollar',
    'AUD': 'AUD - Australian Dollar',
    'CHF': 'CHF - Swiss Franc',
    'CNY': 'CNY - Chinese Yuan',
    'INR': 'INR - Indian Rupee',
    'AED': 'AED - UAE Dirham',
    'SAR': 'SAR - Saudi Riyal',
    'EGP': 'EGP - Egyptian Pound',
  };

  @override
  Widget build(BuildContext context) {
    final locale = Locale(selectedLanguage);
    return Localizations.override(
      context: context,
      locale: locale,
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context)!;
          
          // Create localized currency map
          final Map<String, String> localizedCurrencies = {
            'USD': loc.usd,
            'EUR': loc.eur,
            'GBP': loc.gbp,
            'JPY': loc.jpy,
            'CAD': loc.cad,
            'AUD': loc.aud,
            'CHF': loc.chf,
            'CNY': loc.cny,
            'INR': loc.inr,
            'AED': loc.aed,
            'SAR': loc.sar,
            'EGP': loc.egp,
          };

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              loc.welcome,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.setupSubtitle,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Language Selection
                      Text(
                        loc.selectLanguage,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSelectionGrid(
                        items: languages.entries.map((e) => MapEntry(e.key, e.value)).toList(),
                        selectedValue: selectedLanguage,
                        onChanged: (value) => setState(() => selectedLanguage = value),
                      ),

                      const SizedBox(height: 32),

                      // Currency Selection
                      Text(
                        loc.selectCurrency,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSelectionGrid(
                        items: localizedCurrencies.entries.map((e) => MapEntry(e.key, e.value)).toList(),
                        selectedValue: selectedCurrency,
                        onChanged: (value) => setState(() => selectedCurrency = value),
                      ),

                      const SizedBox(height: 48),

                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : _savePreferences,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  loc.getStarted,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionGrid({
    required List<MapEntry<String, String>> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedValue == item.key;
        
        return GestureDetector(
          onTap: () => onChanged(item.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.value,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _savePreferences() async {
    setState(() => isLoading = true);
    
    try {
      final settingsBox = Hive.box('settings');
      await settingsBox.put('onboardingComplete', true);
      await settingsBox.put('language', selectedLanguage);
      await settingsBox.put('currency', selectedCurrency);
      
      if (mounted) {
        final container = ProviderScope.containerOf(context, listen: false);
        container.read(currencyProvider.notifier).setCurrency(selectedCurrency);
        if (widget.onLocaleChanged != null) {
          widget.onLocaleChanged!(Locale(selectedLanguage));
        }
        Navigator.pushReplacementNamed(context, '/splash');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
} 