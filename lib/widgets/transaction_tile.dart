import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}";

    return ListTile(
      leading: Icon(
        transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: transaction.isIncome ? Colors.green : Colors.red,
      ),
      title: Text(
        '${transaction.title} (${transaction.isIncome ? "Income" : "Expense"})',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transaction.isIncome ? Colors.green : Colors.red,
        ),
      ),
      subtitle: Text(dateFormatted),
      trailing: Text(
        '\$${transaction.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
