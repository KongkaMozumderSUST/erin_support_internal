import 'package:flutter/material.dart';

class SymphonySaleReplace extends StatefulWidget {
  const SymphonySaleReplace({super.key});

  @override
  State<SymphonySaleReplace> createState() => _SymphonySaleReplacePageState();
}

class _SymphonySaleReplacePageState extends State<SymphonySaleReplace> {
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
