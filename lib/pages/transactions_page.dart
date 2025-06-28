import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../providers/transaction_provider.dart';
import '../providers/payment_method_provider.dart';
import '../models/payment_method.dart';
import '../services/currency_service.dart';
import 'add_transaction_page.dart';
import 'package:budgetwise/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String? selectedMethod;
  DateTime? selectedDate;
  String? sortBy; // Will be initialized with localized string

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionProvider);
    final paymentMethods = ref.watch(paymentMethodProvider);
    final currency = ref.watch(currencyProvider);
    final loc = AppLocalizations.of(context)!;
    
    // Initialize sortBy with localized string if not set
    sortBy ??= loc.date + ' ' + loc.descending;
    
    // Filter by current month
    final now = DateTime.now();
    final currentMonthTransactions = allTransactions.where((t) =>
        t.date.year == now.year &&
        t.date.month == now.month &&
        (selectedMethod == null || t.paymentMethod == selectedMethod) &&
        (selectedDate == null ||
            (t.date.year == selectedDate!.year &&
                t.date.month == selectedDate!.month &&
                t.date.day == selectedDate!.day))).toList();

    // Sorting logic - updated to work with localized strings
    currentMonthTransactions.sort((a, b) {
      final loc = AppLocalizations.of(context)!;
      
      if (sortBy == loc.date + ' ' + loc.descending || sortBy == 'Date Descending') {
        return b.date.compareTo(a.date);
      } else if (sortBy == loc.date + ' ' + loc.ascending || sortBy == 'Date Ascending') {
        return a.date.compareTo(b.date);
      } else if (sortBy == loc.amount + ' ' + loc.descending || sortBy == 'Amount Descending') {
        return b.amount.compareTo(a.amount);
      } else if (sortBy == loc.amount + ' ' + loc.ascending || sortBy == 'Amount Ascending') {
        return a.amount.compareTo(b.amount);
      } else {
        // Default to date descending
        return b.date.compareTo(a.date);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, loc, paymentMethods),
            tooltip: loc.filter,
          ),
        ],
      ),
      body: currentMonthTransactions.isEmpty
          ? Center(child: Text(loc.noTransactionsFound))
          : // Replace the ListView.separated with this improved version
ListView.separated(
  padding: const EdgeInsets.all(16),
  itemCount: currentMonthTransactions.length,
  separatorBuilder: (_, __) => const SizedBox(height: 12),
  itemBuilder: (context, index) {
    final transaction = currentMonthTransactions[index];
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transaction.isIncome
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction.isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.category} • ${transaction.paymentMethod}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat.yMMMd().format(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyService.formatAmount(transaction.amount, currency: currency, locale: Localizations.localeOf(context)),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionPage(),
                          ),
                        );
                      },
                      color: Colors.blue,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(loc.deleteTransaction),
                            content: Text(loc.deleteTransactionConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false), 
                                child: Text(loc.cancel)
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true), 
                                child: Text(loc.delete, style: const TextStyle(color: Colors.red))
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref.read(transactionProvider.notifier).deleteTransaction(transaction.id);
                        }
                      },
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddTransactionPage()));
        },
        child: const Icon(Icons.add),
        tooltip: loc.addTransaction,
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, AppLocalizations loc, List<PaymentMethod> paymentMethods) {
    // Get unique payment methods from actual data
    final methodNames = paymentMethods.map((m) => m.name).toSet().toList();
    methodNames.add('Clear'); // Add clear option
    
    final sortOptions = [
      loc.date + ' ' + loc.descending,
      loc.date + ' ' + loc.ascending,
      loc.amount + ' ' + loc.descending,
      loc.amount + ' ' + loc.ascending
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.filterByMethod,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: methodNames.map((method) {
                  return ChoiceChip(
                    label: Text(method),
                    selected: selectedMethod == method,
                    onSelected: (_) {
                      setState(() {
                        selectedMethod =
                            method == 'Clear' ? null : method;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(loc.filterByDate,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(selectedDate == null
                    ? loc.pickDate
                    : DateFormat.yMMMd().format(selectedDate!)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                    Navigator.pop(context);
                  }
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear),
                label: Text(loc.clearDate),
                onPressed: () {
                  setState(() {
                    selectedDate = null;
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 30),
              Text(loc.sortBy,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: sortBy,
                isExpanded: true,
                items: sortOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
