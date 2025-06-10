import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'payment_method.g.dart'; // Generated file

@HiveType(typeId: 2)
enum PaymentType {
  @HiveField(0)
  card('Card', Icons.credit_card, Colors.blue),
  
  @HiveField(1)
  cash('Cash', Icons.money, Colors.green),
  
  @HiveField(2)
  eWallet('E-Wallet', Icons.phone_android, Colors.purple);

  final String displayName;
  final IconData icon;
  final Color color;

  const PaymentType(this.displayName, this.icon, this.color);
}

@HiveType(typeId: 0)
class PaymentMethod extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final PaymentType type;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
  });
}
