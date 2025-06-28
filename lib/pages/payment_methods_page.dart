import 'package:budgetwise/providers/payment_method_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment_method.dart';
import 'package:uuid/uuid.dart';
import '../providers/transaction_provider.dart';
import 'package:budgetwise/l10n/app_localizations.dart';

class PaymentMethodsPage extends ConsumerStatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  ConsumerState<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends ConsumerState<PaymentMethodsPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isAdding = false;
  PaymentType _selectedType = PaymentType.card;

  // Static payment types
  static const List<PaymentType> paymentTypes = [
    PaymentType.card,
    PaymentType.cash,
    PaymentType.eWallet,
  ];

  // In your _PaymentMethodsPageState class
  Future<void> _addMethod(String name) async {
  setState(() => _isAdding = true);
  try {
    final notifier = ref.read(paymentMethodProvider.notifier);
    final newMethod = PaymentMethod(
      id: const Uuid().v4(),
      name: name,
      type: _selectedType,
    );
    await notifier.addMethod(newMethod); // Use the provider's method
    _controller.clear();
  } finally {
    if (mounted) {
      setState(() => _isAdding = false);
    }
  }
}

  Future<void> _deleteMethod(int index) async {
    final box = Hive.box<PaymentMethod>('payment_methods');
    final methods = box.values.toList();
    final method = methods[index];
    
    // Check if this method is used in any transaction using the provider
    final transactions = ref.read(transactionProvider);
    final used = transactions.any((txn) => txn.paymentMethod == method.name);
    
    if (used) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cannot Delete'),
            content: const Text('This payment method is used in a transaction and cannot be deleted.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete: This payment method is used in a transaction.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    await box.deleteAt(index);
    // Refresh payment methods
    if (mounted) {
      setState(() {});
      ref.read(paymentMethodProvider.notifier).loadMethods();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final methodsBox = Hive.box<PaymentMethod>('payment_methods');
    final methods = methodsBox.values.toList();
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final loc = AppLocalizations.of(context)!;

    String getPaymentTypeLabel(PaymentType type) {
      switch (type) {
        case PaymentType.card:
          return loc.card;
        case PaymentType.cash:
          return loc.cash;
        case PaymentType.eWallet:
          return loc.eWallet;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.paymentMethods),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(loc.addPaymentMethod, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: loc.paymentMethod,
                        hintText: 'e.g. Visa, PayPal',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: Icon(_selectedType.icon, color: _selectedType.color),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.pleaseAddPaymentMethod;
                        }
                        if (value.length > 24) {
                          return loc.paymentMethod + ' (max 24)';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      maxLength: 24,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: paymentTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final type = paymentTypes[index];
                          return ChoiceChip(
                            label: Text(getPaymentTypeLabel(type)),
                            selected: _selectedType == type,
                            onSelected: (_) => setState(() => _selectedType = type),
                            selectedColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            labelStyle: TextStyle(color: _selectedType == type ? Colors.white : Theme.of(context).colorScheme.onSurface),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isAdding ? null : () {
                        if (_formKey.currentState!.validate()) {
                          _addMethod(_controller.text.trim());
                        }
                      },
                      icon: _isAdding
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.add, size: 20),
                      label: Text(loc.addPaymentMethod),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (methods.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off, size: 64, color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(loc.noPaymentMethodsYet, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 8),
                  Text(loc.addYourFirstPaymentMethod, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                ],
              ),
            )
          else
            // Replace the card for each payment method with this improved version
...methods.map((method) => Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 1,
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: method.type.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(method.type.icon, size: 24, color: method.type.color),
    ),
    title: Text(
      method.name,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    subtitle: Text(
      method.type.displayName,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        fontSize: 12,
      ),
    ),
    trailing: IconButton(
      icon: const Icon(Icons.delete_outline, size: 20),
      color: Colors.red.withOpacity(0.7),
      onPressed: () => _showDeleteDialog(context, methods.indexOf(method)),
      tooltip: loc.delete,
    ),
  ),
)),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Payment Method"),
            content: const Text(
              "Are you sure you want to delete this payment method?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteMethod(index);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
