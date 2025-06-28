import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:budgetwise/l10n/app_localizations.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final void Function(Locale) onLocaleChanged;
  final void Function(String) onCurrencyChanged;
  final String currentCurrency;
  
  const SettingsPage({
    super.key, 
    required this.onThemeChanged, 
    required this.onLocaleChanged, 
    required this.onCurrencyChanged, 
    required this.currentCurrency
  });
  
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  ThemeMode _currentTheme = ThemeMode.system;
  String _currentLanguage = 'en';
  String _currentCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _currentCurrency = widget.currentCurrency;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsBox = Hive.box('settings');
    final themeMode = settingsBox.get('themeMode', defaultValue: 'system');
    final language = settingsBox.get('language', defaultValue: 'en');
    final currency = settingsBox.get('currency', defaultValue: 'USD');
    
    setState(() {
      _currentTheme = _getThemeModeFromString(themeMode);
      _currentLanguage = language;
      _currentCurrency = currency;
    });
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('themeMode', _getThemeModeString(mode));
    widget.onThemeChanged(mode);
    setState(() => _currentTheme = mode);
  }

  Future<void> _saveLanguage(String language) async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('language', language);
    widget.onLocaleChanged(Locale(language));
    setState(() => _currentLanguage = language);
  }

  Future<void> _saveCurrency(String currency) async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('currency', currency);
    widget.onCurrencyChanged(currency);
    setState(() => _currentCurrency = currency);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.settings,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Appearance Section
          _buildSectionCard(
            title: loc.appearance,
            icon: Icons.palette,
            children: [
              _buildThemeSelector(loc),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Language Section
          _buildSectionCard(
            title: loc.language,
            icon: Icons.language,
            children: [
              _buildLanguageSelector(loc),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Currency Section
          _buildSectionCard(
            title: loc.currency,
            icon: Icons.attach_money,
            children: [
              _buildCurrencySelector(loc),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // About Section
          _buildSectionCard(
            title: loc.about,
            icon: Icons.info,
            children: [
              _buildAboutSection(loc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppLocalizations loc) {
    return Column(
      children: [
        _buildOptionTile(
          title: loc.light,
          subtitle: loc.useLightTheme,
          icon: Icons.light_mode,
          isSelected: _currentTheme == ThemeMode.light,
          onTap: () => _saveThemeMode(ThemeMode.light),
        ),
        _buildOptionTile(
          title: loc.dark,
          subtitle: loc.useDarkTheme,
          icon: Icons.dark_mode,
          isSelected: _currentTheme == ThemeMode.dark,
          onTap: () => _saveThemeMode(ThemeMode.dark),
        ),
        _buildOptionTile(
          title: loc.system,
          subtitle: loc.useSystemTheme,
          icon: Icons.brightness_auto,
          isSelected: _currentTheme == ThemeMode.system,
          onTap: () => _saveThemeMode(ThemeMode.system),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(AppLocalizations loc) {
    return Column(
      children: [
        _buildOptionTile(
          title: 'English',
          subtitle: 'English language',
          icon: Icons.flag,
          isSelected: _currentLanguage == 'en',
          onTap: () => _saveLanguage('en'),
        ),
        _buildOptionTile(
          title: 'العربية',
          subtitle: 'Arabic language',
          icon: Icons.flag,
          isSelected: _currentLanguage == 'ar',
          onTap: () => _saveLanguage('ar'),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(AppLocalizations loc) {
    final currencies = {
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

    return Column(
      children: currencies.entries.map((entry) {
        return _buildOptionTile(
          title: entry.value,
          subtitle: 'Currency code: ${entry.key}',
          icon: Icons.attach_money,
          isSelected: _currentCurrency == entry.key,
          onTap: () => _saveCurrency(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildAboutSection(AppLocalizations loc) {
    return Column(
      children: [
        _buildInfoTile(
          title: 'BudgetWise',
          subtitle: 'Personal Finance Manager',
          icon: Icons.account_balance_wallet,
        ),
        _buildInfoTile(
          title: 'Version',
          subtitle: '1.0.0',
          icon: Icons.info,
        ),
        _buildInfoTile(
          title: 'Developer',
          subtitle: 'BudgetWise Team',
          icon: Icons.person,
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Icon(
          icon,
          size: 18,
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: isSelected 
            ? Icon(
                Icons.check_circle,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
} 