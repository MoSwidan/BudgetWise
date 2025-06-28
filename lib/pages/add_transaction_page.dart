import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/payment_method.dart';
import '../providers/transaction_provider.dart';
import '../providers/payment_method_provider.dart';
import '../services/currency_service.dart';
import 'package:budgetwise/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const AddTransactionPage({super.key, this.transaction});

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
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _categoryController.text = widget.transaction!.category;
      selectedMethod = widget.transaction!.paymentMethod;
      selectedDate = widget.transaction!.date;
      isIncome = widget.transaction!.isIncome;
    } else {
      selectedMethod = methods.isNotEmpty ? methods.first.name : 'Cash';
    }
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
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    bool noPaymentMethods = paymentMethods.isEmpty;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction != null ? loc.editTransaction : loc.addTransaction),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: loc.title,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.title),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: theme.textTheme.bodyLarge,
                        validator: (value) => value == null || value.isEmpty ? loc.title + ' ' + loc.add + ' ' + loc.pleaseAddPaymentMethod : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: loc.amount,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.money_rounded),
                          prefixText: CurrencyService.getCurrencySymbol(currency, locale: Localizations.localeOf(context)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.bodyLarge,
                        validator: (value) {
                          if (value == null || value.isEmpty) return loc.amount + ' ' + loc.pleaseAddPaymentMethod;
                          if (double.tryParse(value) == null) {
                            return loc.amount + ' ' + loc.add + ' ' + loc.pleaseAddPaymentMethod;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.transactionType, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(value: false, label: Text(loc.expense), icon: const Icon(Icons.arrow_upward)),
                                ButtonSegment(value: true, label: Text(loc.income), icon: const Icon(Icons.arrow_downward)),
                              ],
                              selected: {isIncome},
                              onSelectionChanged: (newSelection) {
                                setState(() => isIncome = newSelection.first);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                  (states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return isIncome ? Colors.green.shade100 : Colors.red.shade100;
                                    }
                                    return theme.colorScheme.surfaceContainerHighest;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: loc.category,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.category),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: theme.textTheme.bodyLarge,
                        validator: (value) => value == null || value.isEmpty ? loc.category + ' ' + loc.pleaseAddPaymentMethod : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: loc.paymentMethod,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.credit_card),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        value: paymentMethods.isNotEmpty ? selectedMethod : 'No methods available',
                        items: paymentMethods.isNotEmpty
                            ? paymentMethods
                                .map((method) => DropdownMenuItem(
                                      value: method.name,
                                      child: Row(
                                        children: [
                                          Icon(method.type.icon, color: method.type.color, size: 20),
                                          const SizedBox(width: 12),
                                          Text(method.name),
                                        ],
                                      ),
                                    ))
                                .toList()
                            : [
                                DropdownMenuItem(
                                  value: 'No methods available',
                                  child: Text(loc.noPaymentMethods),
                                )
                              ],
                        onChanged: paymentMethods.isNotEmpty ? (value) => setState(() => selectedMethod = value!) : null,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
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
                                  colorScheme: theme.colorScheme.copyWith(primary: theme.colorScheme.primary),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (noPaymentMethods) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            loc.pleaseAddPaymentMethod,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      FilledButton.icon(
                        icon: Icon(widget.transaction != null ? Icons.save : Icons.check),
                        label: Text(widget.transaction != null ? loc.saveChanges : loc.addTransaction),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: noPaymentMethods ? null : _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      if (widget.transaction != null) {
        // Edit mode
        final updatedTransaction = Transaction(
          id: widget.transaction!.id,
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _categoryController.text.trim(),
          date: selectedDate,
          paymentMethod: method?.name ?? 'Cash',
          isIncome: isIncome,
        );
        ref.read(transactionProvider.notifier).updateTransaction(updatedTransaction);
      } else {
        // Add mode
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
      }
      Navigator.pop(context);
    }
  }
}