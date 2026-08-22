import 'package:flutter/material.dart';

class WaltonLock extends StatefulWidget {
  const WaltonLock({super.key});

  @override
  State<WaltonLock> createState() => _WaltonLockPageState();
}

class _WaltonLockPageState extends State<WaltonLock> {
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
//imei = 354502150042353