import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String? selectedMethod;
  DateTime? selectedDate;
  String sortBy = 'Date Descending';

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionProvider);

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

    // Sorting logic
    currentMonthTransactions.sort((a, b) {
      switch (sortBy) {
        case 'Amount Ascending':
          return a.amount.compareTo(b.amount);
        case 'Amount Descending':
          return b.amount.compareTo(a.amount);
        case 'Date Ascending':
          return a.date.compareTo(b.date);
        case 'Date Descending':
        default:
          return b.date.compareTo(a.date);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: currentMonthTransactions.isEmpty
          ? const Center(child: Text('No transactions found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: currentMonthTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final transaction = currentMonthTransactions[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.isIncome
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        transaction.isIncome
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction.isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      transaction.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        '${transaction.category} • ${transaction.paymentMethod}\n${DateFormat.yMMMd().format(transaction.date)}'),
                    isThreeLine: true,
                    trailing: Text(
                      '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.isIncome
                            ? Colors.green
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final methods = ['Cash', 'Card', 'Wallet', 'E-Wallet', 'Clear'];
    final sortOptions = [
      'Date Descending',
      'Date Ascending',
      'Amount Descending',
      'Amount Ascending'
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
              const Text('Filter by Method',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: methods.map((method) {
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
              const Text('Filter by Date',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(selectedDate == null
                    ? 'Pick Date'
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
                label: const Text('Clear Date'),
                onPressed: () {
                  setState(() {
                    selectedDate = null;
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 30),
              const Text('Sort By',
                  style: TextStyle(
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
