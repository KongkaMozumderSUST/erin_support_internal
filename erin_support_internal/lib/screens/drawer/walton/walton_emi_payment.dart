import 'package:flutter/material.dart';

class WaltonEmiPayment extends StatefulWidget {
  const WaltonEmiPayment({super.key});

  @override
  State<WaltonEmiPayment> createState() => _WaltonEmiPaymentPageState();
}

class _WaltonEmiPaymentPageState extends State<WaltonEmiPayment> {
  final TextEditingController customerIdController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    customerIdController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold();
}
}
