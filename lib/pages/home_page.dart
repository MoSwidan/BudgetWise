import 'package:budgetwise/models/payment_method.dart';
import 'package:budgetwise/pages/payment_methods_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_method_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import '../services/currency_service.dart';
import 'add_transaction_page.dart';
import 'transactions_page.dart';
import 'package:budgetwise/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(paymentMethodProvider);
    final transactions = ref.watch(transactionProvider);
    final currency = ref.watch(currencyProvider);
    final loc = AppLocalizations.of(context)!;
    
    final income = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    final balance = income - expenses;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
            tooltip: loc.analytics,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: loc.settings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Payment Methods Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.paymentMethods, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage())),
                          child: Text(loc.viewAll, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (methods.isEmpty)
                      _buildEmptyState(
                        context,
                        icon: Icons.credit_card,
                        message: loc.noPaymentMethodsYet,
                        actionText: loc.addMethod,
                        onAction: () => _navigateToAddMethod(context),
                      )
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: methods.length,
                          itemBuilder: (context, index) {
                            final method = methods[index];
                            return _buildPaymentMethodCard(method);
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 14),

            // 2. Monthly Overview
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.monthlyOverview, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildOverviewCards(context, income, expenses, balance, currency, loc),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 14),

            // 3. Recent Transactions
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.recentTransactions, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsPage())),
                          child: Text(loc.viewAll, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (transactions.isEmpty)
                      _buildEmptyState(
                        context,
                        icon: Icons.receipt_long,
                        message: loc.noTransactionsYet,
                        actionText: loc.addTransaction,
                        onAction: () => _navigateToAddTransaction(context),
                      )
                    else
                      ...transactions
                          .take(3)
                          .map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TransactionTile(transaction: t, currency: currency),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: loc.addTransaction,
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: method.type.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(method.type.icon, size: 24, color: method.type.color),
            const SizedBox(height: 8),
            Text(
              method.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    double income,
    double expenses,
    double balance,
    String currency,
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        _buildSummaryCard(
          context,
          title: loc.income,
          value: income,
          icon: Icons.arrow_downward,
          color: Colors.green,
          currency: currency,
        ),
        const SizedBox(height: 8),
        _buildSummaryCard(
          context,
          title: loc.expenses,
          value: expenses,
          icon: Icons.arrow_upward,
          color: Colors.red,
          currency: currency,
        ),
        const SizedBox(height: 8),
        _buildSummaryCard(
          context,
          title: loc.balance,
          value: balance,
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
          currency: currency,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    required String currency,
  }) {
    final isNegative = value < 0;
    final locale = Localizations.localeOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3), 
          width: 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Text(
                CurrencyService.formatAmount(value.abs(), currency: currency, locale: locale),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? Colors.red : color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: Icon(
              icon,
              size: 36,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: onAction,
              icon: Icon(Icons.add, size: 20, color: Colors.white),
              label: Text(
                actionText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Navigation Helpers ---

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionPage(),
      ),
    );
  }

  void _navigateToAddMethod(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
    );
  }
}
