import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1) // Changed from 0 to 1 (or another unique number)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String paymentMethod;

  @HiveField(6)
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.isIncome,
  });
}
