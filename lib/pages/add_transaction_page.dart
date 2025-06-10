import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/payment_method_provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  late String selectedMethod;
  DateTime selectedDate = DateTime.now();
  bool isIncome = false;

  @override
  void initState() {
    super.initState();
    final methods = ref.read(paymentMethodProvider);
    selectedMethod = methods.isNotEmpty ? methods.first.name : 'Cash';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = ref.watch(paymentMethodProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a title' : null,
                ),
                const SizedBox(height: 20),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixText: '\$ ',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter amount';
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Type selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Type',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Expense'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Income'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                      ],
                      selected: {isIncome},
                      onSelectionChanged: (newSelection) {
                        setState(() => isIncome = newSelection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(MaterialState.selected)) {
                              return isIncome
                                  ? Colors.green.shade100
                                  : Colors.red.shade100;
                            }
                            return theme.colorScheme.surfaceVariant;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category field
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a category' : null,
                ),
                const SizedBox(height: 20),

                // Payment method dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  value: paymentMethods.isNotEmpty
                      ? selectedMethod
                      : 'No methods available',
                  items: paymentMethods.isNotEmpty
                      ? paymentMethods
                          .map((method) => DropdownMenuItem(
                                value: method.name,
                                child: Row(
                                  children: [
                                    Icon(
                                      method.type.icon,
                                      color: method.type.color,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(method.name),
                                  ],
                                ),
                              ))
                          .toList()
                      : [
                          const DropdownMenuItem(
                            value: 'No methods available',
                            child: Text('No payment methods'),
                          )
                        ],
                  onChanged: paymentMethods.isNotEmpty
                      ? (value) => setState(() => selectedMethod = value!)
                      : null,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),

                // Date picker
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: theme.copyWith(
                            colorScheme: theme.colorScheme.copyWith(
                              primary: theme.colorScheme.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat.yMMMd().format(selectedDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Add button
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Add Transaction'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final paymentMethods = ref.read(paymentMethodProvider);
      final method = paymentMethods.isNotEmpty
          ? paymentMethods.firstWhere(
              (m) => m.name == selectedMethod,
              orElse: () => paymentMethods.first,
            )
          : null;

      final newTransaction = Transaction(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _categoryController.text.trim(),
        date: selectedDate,
        paymentMethod: method?.name ?? 'Cash',
        isIncome: isIncome,
      );

      ref.read(transactionProvider.notifier).addTransaction(newTransaction);

      Navigator.pop(context);
    }
  }
}