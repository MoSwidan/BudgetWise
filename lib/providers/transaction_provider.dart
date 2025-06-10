import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/db_service.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super(DBService.getAll());

  Future<void> addTransaction(Transaction txn) async {
    await DBService.add(txn);
    state = DBService.getAll(); // Refresh state
  }

  Future<void> deleteTransaction(String id) async {
    await DBService.delete(id);
    state = DBService.getAll();
  }

  Future<void> updateTransaction(Transaction updatedTxn) async {
    await DBService.update(updatedTxn);
    state = DBService.getAll();
  }
}
