import 'package:flutter/material.dart';

class SymphonyGracePeriod extends StatefulWidget {
  const SymphonyGracePeriod({super.key});

  @override
  State<SymphonyGracePeriod> createState() => _SymphonyGracePeriodPageState();
}

class _SymphonyGracePeriodPageState extends State<SymphonyGracePeriod> {
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
