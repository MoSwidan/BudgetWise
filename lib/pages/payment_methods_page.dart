import 'package:budgetwise/providers/payment_method_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment_method.dart';
import 'package:uuid/uuid.dart';

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
    await box.deleteAt(index);
    if (mounted) setState(() {});
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Methods",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Add Method Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 12,),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.1),
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Payment Method Name",
                        hintText: "e.g. Chase Visa, PayPal Cash",
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            _selectedType.icon,
                            size: 24,
                            color: _selectedType.color,
                          ),
                        ),
                        suffixIcon:
                            _controller.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {});
                                  },
                                )
                                : null,
                        labelStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a payment method name';
                        }
                        if (value.length > 24) {
                          return 'Name too long (max 24 chars)';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      maxLength: 24,
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            '$currentLength/$maxLength',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Payment Type Selector
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: paymentTypes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final type = paymentTypes[index];
                        return ChoiceChip(
                          label: Text(
                            type.displayName,
                            style: TextStyle(
                              color:
                                  _selectedType == type
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          selected: _selectedType == type,
                          onSelected:
                              (_) => setState(() => _selectedType = type),
                          selectedColor: Theme.of(context).colorScheme.primary,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _isAdding
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  _addMethod(_controller.text.trim());
                                }
                              },
                      icon:
                          _isAdding
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.add, size: 20),
                      label: const Text("Add Payment Method"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Methods List
            Expanded(
              child:
                  methods.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                        itemCount: methods.length,
                        itemBuilder: (context, index) {
                          final method = methods[index];
                          return _buildMethodItem(method, index);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodItem(PaymentMethod method, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: method.type.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(method.type.icon, size: 20, color: method.type.color),
        ),
        title: Text(
          method.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          method.type.displayName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red.withOpacity(0.7),
          onPressed: () => _showDeleteDialog(context, index),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No payment methods yet",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first payment method above",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
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
