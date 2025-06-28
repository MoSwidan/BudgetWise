import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:budgetwise/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    
    // Create localized onboarding pages
    final List<OnboardingPage> _pages = [
      OnboardingPage(
        icon: Icons.security,
        color: Colors.indigo,
        title: loc.onboardingTitle1,
        description: loc.onboardingDesc1,
        features: [
          loc.onboardingFeature1_1,
          loc.onboardingFeature1_2,
          loc.onboardingFeature1_3,
        ],
      ),
      OnboardingPage(
        icon: Icons.insights,
        color: Colors.blue,
        title: loc.onboardingTitle2,
        description: loc.onboardingDesc2,
        features: [
          loc.onboardingFeature2_1,
          loc.onboardingFeature2_2,
          loc.onboardingFeature2_3,
        ],
      ),
      OnboardingPage(
        icon: Icons.account_balance_wallet,
        color: Colors.teal,
        title: loc.onboardingTitle3,
        description: loc.onboardingDesc3,
        features: [
          loc.onboardingFeature3_1,
          loc.onboardingFeature3_2,
          loc.onboardingFeature3_3,
        ],
      ),
    ];
    
    // Debug: Print current locale
    print('Splash Screen Locale: ${currentLocale.languageCode}');
    print('Splash Screen Text: ${_currentPage == _pages.length - 1 ? loc.getStarted : loc.continueLabel}');
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return OnboardingPageView(page: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _currentPage == _pages.length - 1
                          ? _completeOnboarding
                          : () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                              ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? loc.getStarted : loc.continueLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Skip button
                  if (_currentPage != _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(loc.skip),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('onboardingComplete', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<String> features;

  OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.features,
  });
}

class OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Features
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: page.features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: page.color,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}