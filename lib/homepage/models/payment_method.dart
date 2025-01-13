import 'package:flutter/material.dart';

class PaymentMethod {
  final String type;
  final String? number;
  final String? expiry;
  final String? email;
  final IconData icon;

  PaymentMethod({
    required this.type,
    this.number,
    this.expiry,
    this.email,
    required this.icon,
  });

  static List<PaymentMethod> samplePaymentMethods = [
    PaymentMethod(
      type: 'Credit Card',
      number: '**** **** **** 1234',
      expiry: '12/25',
      icon: Icons.credit_card,
    ),
    PaymentMethod(
      type: 'PayPal',
      email: 'john.doe@example.com',
      icon: Icons.payment,
    ),
  ];
}

