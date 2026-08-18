import 'package:flutter/material.dart';

class WaltonUnlock extends StatefulWidget {
  const WaltonUnlock({super.key});

  @override
  State<WaltonUnlock> createState() => _WaltonUnlockPageState();
}

class _WaltonUnlockPageState extends State<WaltonUnlock> {
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
