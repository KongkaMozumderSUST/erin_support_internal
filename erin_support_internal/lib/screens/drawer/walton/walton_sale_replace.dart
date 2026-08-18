import 'package:flutter/material.dart';

class WaltonSaleReplace extends StatefulWidget {
  const WaltonSaleReplace({super.key});

  @override
  State<WaltonSaleReplace> createState() => _WaltonSaleReplacePageState();
}

class _WaltonSaleReplacePageState extends State<WaltonSaleReplace> {
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
