import 'package:flutter/material.dart';

class SymphonyLock extends StatefulWidget {
  const SymphonyLock({super.key});

  @override
  State<SymphonyLock> createState() => _SymphonyLockPageState();
}

class _SymphonyLockPageState extends State<SymphonyLock> {
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
