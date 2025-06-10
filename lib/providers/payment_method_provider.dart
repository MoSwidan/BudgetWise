import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/payment_method.dart';

final paymentMethodBoxProvider = Provider<Box<PaymentMethod>>((ref) {
  return Hive.box<PaymentMethod>('payment_methods');
});

final paymentMethodProvider =  // match this name exactly in your imports!
    StateNotifierProvider<PaymentMethodNotifier, List<PaymentMethod>>((ref) {
  final box = ref.watch(paymentMethodBoxProvider);
  return PaymentMethodNotifier(box);
});

class PaymentMethodNotifier extends StateNotifier<List<PaymentMethod>> {
  final Box<PaymentMethod> box;

  PaymentMethodNotifier(this.box) : super(box.values.toList());

  Future<void> addMethod(PaymentMethod method) async {
    await box.put(method.id, method);
    state = box.values.toList();
  }

  Future<void> deleteMethod(String id) async {
    await box.delete(id);
    state = box.values.toList();
  }

  Future<void> updateMethod(PaymentMethod updated) async {
    await box.put(updated.id, updated);
    state = box.values.toList();
  }

  void loadMethods() {
    state = box.values.toList();
  }
}
