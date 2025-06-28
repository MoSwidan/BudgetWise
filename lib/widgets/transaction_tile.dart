import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/currency_service.dart';
import 'package:budgetwise/l10n/app_localizations.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String currency;

  const TransactionTile({super.key, required this.transaction, this.currency = 'USD'});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}";
    final locale = Localizations.localeOf(context);
    final loc = AppLocalizations.of(context)!;

    return ListTile(
      leading: Icon(
        transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: transaction.isIncome ? Colors.green : Colors.red,
      ),
      title: Text(
        '${transaction.title} (${transaction.isIncome ? loc.income : loc.expense})',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transaction.isIncome ? Colors.green : Colors.red,
        ),
      ),
      subtitle: Text(dateFormatted),
      trailing: Text(
        CurrencyService.formatAmount(transaction.amount, currency: currency, locale: locale),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
