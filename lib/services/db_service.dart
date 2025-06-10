import 'package:hive/hive.dart';
import '../models/transaction.dart';

class DBService {
  static final Box<Transaction> _box = Hive.box<Transaction>('transactions');

  static List<Transaction> getAll() => _box.values.toList();

  static Future<void> add(Transaction txn) async {
    await _box.put(txn.id, txn);
  }

  static Future<void> delete(String id) async {
    await _box.delete(id);
  }

  static Future<void> update(Transaction txn) async {
    await _box.put(txn.id, txn); // Overwrites by id
  }
}
