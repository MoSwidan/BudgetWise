import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:budgetwise/l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/payment_method_provider.dart';
import '../services/currency_service.dart';
import '../providers/currency_provider.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final paymentMethods = ref.watch(paymentMethodProvider);
    final currency = ref.watch(currencyProvider);
    final loc = AppLocalizations.of(context)!;
    
    // Check if there are any transactions
    if (transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.analytics),
          centerTitle: true,
          elevation: 0,
        ),
        body: _buildEmptyState(context, loc),
      );
    }
    
    // Calculate analytics data
    final income = transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount.abs());
    final balance = income - expenses;
    
    // Get current month data
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final monthTransactions = transactions.where((t) {
      final txnMonth = DateTime(t.date.year, t.date.month);
      return txnMonth.isAtSameMomentAs(currentMonth);
    }).toList();
    
    final monthIncome = monthTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final monthExpenses = monthTransactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount.abs());
    
    // Category spending
    final categorySpending = <String, double>{};
    for (final transaction in transactions.where((t) => !t.isIncome)) {
      categorySpending[transaction.category] = (categorySpending[transaction.category] ?? 0) + transaction.amount.abs();
    }
    
    // Payment method usage
    final methodUsage = <String, double>{};
    for (final transaction in transactions) {
      methodUsage[transaction.paymentMethod] = (methodUsage[transaction.paymentMethod] ?? 0) + transaction.amount.abs();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.analytics),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Monthly Overview Card
          _buildOverviewCard(context, loc, monthIncome, monthExpenses, balance),
          
          const SizedBox(height: 16),
          
          // Income vs Expenses Chart
          if (transactions.isNotEmpty) ...[
            _buildChartCard(
              context,
              title: loc.incomeVsExpenses,
              icon: Icons.trending_up,
              child: _buildIncomeExpenseChart(monthIncome, monthExpenses, loc),
            ),
            const SizedBox(height: 16),
          ],
          
          // Category Spending Chart
          if (categorySpending.isNotEmpty) ...[
            _buildChartCard(
              context,
              title: loc.spendingByCategory,
              icon: Icons.pie_chart,
              child: _buildCategoryChart(categorySpending, loc),
            ),
            const SizedBox(height: 16),
          ],
          
          // Payment Method Usage
          if (methodUsage.isNotEmpty) ...[
            _buildChartCard(
              context,
              title: loc.paymentMethodUsage,
              icon: Icons.credit_card,
              child: _buildMethodUsageChart(context, methodUsage, loc),
            ),
            const SizedBox(height: 16),
          ],
          
          // Recent Activity
          _buildRecentActivityCard(context, loc, transactions.take(5).toList()),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, AppLocalizations loc, double income, double expenses, double balance) {
    final currency = CurrencyService.getCurrentCurrency();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.monthlyOverview,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Full width cards - one per row
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _buildStatItem(
                    context,
                    loc.income,
                    CurrencyService.formatAmount(income, currency: currency, locale: Localizations.localeOf(context)),
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildStatItem(
                    context,
                    loc.expenses,
                    CurrencyService.formatAmount(expenses, currency: currency, locale: Localizations.localeOf(context)),
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildStatItem(
                    context,
                    loc.balance,
                    CurrencyService.formatAmount(balance, currency: currency, locale: Localizations.localeOf(context)),
                    Icons.account_balance_wallet,
                    balance >= 0 ? Colors.blue : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart(double income, double expenses, AppLocalizations loc) {
    final total = income + expenses;
    if (total == 0) {
      return Center(child: Text(loc.noDataAvailable));
    }
    
    return SizedBox(
      height: 190,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: total * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0: return Text(loc.income);
                    case 1: return Text(loc.expenses);
                    default: return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income,
                  color: Colors.green,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expenses,
                  color: Colors.red,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, double> categorySpending, AppLocalizations loc) {
    final total = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);
    if (total == 0) {
      return Center(child: Text(loc.noSpendingDataAvailable));
    }
    
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    
    final entries = categorySpending.entries.toList();
    
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(enabled: false),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value.key;
                final amount = entry.value.value;
                final percentage = (amount / total * 100).toStringAsFixed(1);
                
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: amount,
                  title: '$percentage%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Category legend
        Column(
          children: entries.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final amount = entry.value.value;
            final percentage = (amount / total * 100).toStringAsFixed(1);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMethodUsageChart(BuildContext context, Map<String, double> methodUsage, AppLocalizations loc) {
    final total = methodUsage.values.fold(0.0, (sum, amount) => sum + amount);
    if (total == 0) {
      return Center(child: Text(loc.noTransactionDataAvailable));
    }
    
    return Column(
      children: methodUsage.entries.map((entry) {
        final method = entry.key;
        final amount = entry.value;
        final percentage = (amount / total * 100).toStringAsFixed(1);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  method,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: amount / total,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percentage%',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context, AppLocalizations loc, List<dynamic> recentTransactions) {
    final currency = CurrencyService.getCurrentCurrency();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.recentActivity,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentTransactions.isEmpty)
              Center(
                child: Text(
                  loc.noRecentTransactions,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
            else
              ...recentTransactions.map((transaction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaction.isIncome ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyService.formatAmount(transaction.amount, currency: currency, locale: Localizations.localeOf(context)),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction.isIncome ? Colors.green : Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loc.noDataAvailable,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            loc.comingSoon,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 