import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String category = '';
  double amount = 0.0;
  bool isIncome = false;
  DateTime selectedDate = DateTime.now();
  String selectedMethod = 'Cash';

  final List<String> paymentMethods = ['Cash', 'Card', 'Wallet', 'E-Wallet'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => title = value!,
              ),
              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => amount = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Income or Expense toggle
              Row(
                children: [
                  const Text('Type:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: !isIncome,
                    onSelected: (_) => setState(() => isIncome = false),
                    selectedColor: Colors.red.shade100,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: isIncome,
                    onSelected: (_) => setState(() => isIncome = true),
                    selectedColor: Colors.green.shade100,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter a category' : null,
                onSaved: (value) => category = value!,
              ),
              const SizedBox(height: 16),

              // Payment method dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                value: selectedMethod,
                items: paymentMethods
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedMethod = value!),
              ),
              const SizedBox(height: 16),

              // Date picker
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat.yMMMd().format(selectedDate)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 30),

              // Add button
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Add Transaction'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final newTransaction = Transaction(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        category: category,
        date: selectedDate,
        paymentMethod: selectedMethod,
        isIncome: isIncome,
      );

      ref.read(transactionProvider.notifier).addTransaction(newTransaction);

      Navigator.pop(context);
    }
  }
}
