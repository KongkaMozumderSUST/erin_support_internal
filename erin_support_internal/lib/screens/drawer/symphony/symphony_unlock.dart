import 'package:flutter/material.dart';

class SymphonyUnlock extends StatefulWidget {
  const SymphonyUnlock({super.key});

  @override
  State<SymphonyUnlock> createState() => _SymphonyUnlockPageState();
}

class _SymphonyUnlockPageState extends State<SymphonyUnlock> {
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
