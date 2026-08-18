import 'package:flutter/material.dart';

class SymphonyEmiPayment extends StatefulWidget {
  const SymphonyEmiPayment({super.key});

  @override
  State<SymphonyEmiPayment> createState() => _SymphonyEmiPaymentPageState();
}

class _SymphonyEmiPaymentPageState extends State<SymphonyEmiPayment> {
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
