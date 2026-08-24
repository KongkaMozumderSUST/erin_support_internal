import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';

class WaltonSaleReplace extends StatefulWidget {
  const WaltonSaleReplace({super.key});

  @override
  State<WaltonSaleReplace> createState() => _WaltonSaleReplacePageState();
}

class _WaltonSaleReplacePageState extends State<WaltonSaleReplace> {

  late TextEditingController oldImei1Controller;
  late TextEditingController oldImei2Controller;
  late TextEditingController newImei1Controller;
  late TextEditingController newImei2Controller;
  late TextEditingController newModelController;

  bool isLoading = false;
  LoginData? customer;
  String? token;
  String? customerId;
  String? old_imei1;
  String? old_imei2;
  String? new_imei1;
  String? new_imei2;
  String? new_model;

  @override
  void initState() {
    super.initState();
   oldImei1Controller = TextEditingController();
    oldImei2Controller = TextEditingController();
    newImei1Controller = TextEditingController();
    newImei2Controller = TextEditingController();
    newModelController = TextEditingController();
    _initialize();
  }


  Future<void> _initialize() async {
    final user = await Save.getUser();
    if (!mounted) return;
    if (user?.data == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    else {
      setState(() {
        final data = user!.data!;
        customer = data;
        token = user.token;
        customerId = data.applicationId;
        old_imei1 =  data.mdmInfo?.imei1;
        old_imei2  = data.mdmInfo?.imei2;
        oldImei1Controller.text = old_imei1!;
        oldImei2Controller.text = old_imei2!;
      });
    }

  }

  @override
  void dispose() {
    oldImei1Controller.dispose();
    oldImei2Controller.dispose();
    newImei1Controller.dispose();
    newModelController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // BODY
      body: RefreshIndicator(
        onRefresh: _initialize,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader(
              icon: Icons.person_outline,
              title: 'Payment Update Information',
            ),
            SizedBox(height: 20,),
            _buildApplicationCard(),
            SizedBox(height: 20,),
            _buildPaymentCard()
          ],
        ),
      ),
    );
  }
  Future<void> waltonSaleReplace() async {
    if (oldImei1Controller.text.trim().isEmpty && oldImei2Controller.text.trim().isEmpty && newImei1Controller.text.trim().isEmpty&&newImei2Controller.text.trim().isEmpty&&newModelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Imei information incomplete"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      new_imei1= newImei1Controller.text.trim();
      new_imei2= newImei2Controller.text.trim();
      new_model = newModelController.text.trim();
      isLoading = true;
    });

    final url = Uri.parse('$BaseURL/external/mdm/replace');
    final body = jsonEncode({
        "mdm_name": "Walton MDM",
        "application_id": customerId,
        "new_imei_1": new_imei1,
        "new_imei_2": new_imei2,
        "old_imei_1": old_imei1,
        "old_imei_2": old_imei2,
        "new_model": new_model,
        "reason" : "Kongka"
      }
      );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'K9s8X7P0LwE3QzN2B=='
    };

    try {
      final res = await http.post(
        url,
        body: body,
        headers: headers,
      );

      print("Status Code: ${res.statusCode}");
      print("Response: ${res.body}");
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sale Replace failed: ${res.statusCode}"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (json["status"] == true) {
          final data = json["data"];
          print(data);
          setState(() {
            isLoading = false;
          });
        }
      }
      else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sale Replace failed: ${res.statusCode}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Something went wrong. Please check your network connection."),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Widget _sectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(9),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF1A237E),
            size: 20,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  Widget _card({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: child,
    );
  }
  Widget _buildApplicationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            label: 'Customer ID',
            value: customer?.applicationId ?? 'N/A',
          ),
          const SizedBox(height: 18),
          _infoRow(
            label: 'Imei 1',
            value: old_imei1 ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _infoRow(
            label: 'Imei 2',
            value: old_imei2 ?? 'N/A',
          ),
        ],
      ),
    );
  }
  Widget _buildPaymentCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.phone_android_outlined,
            title: 'Update IMEI Information',
          ),

          const SizedBox(height: 18),


          // IMEI 1
          _buildEditableField(
            controller: oldImei1Controller,
            label: 'Old Imei 1',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 12),

          // IMEI 2
          _buildEditableField(
            controller: oldImei2Controller,
            label: 'Old Imei 2',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: newImei1Controller,
            label: 'New Imei 1',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: newImei2Controller,
            label: 'New Imei 2',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: newModelController,
            label: 'New Model',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _primaryButton(
            icon: Icons.save_outlined,
            text: 'Sale Replace',
            onPressed: waltonSaleReplace,
          ),
        ],
      ),
    );
  }
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF64748B),
      ),

      filled: true,

      fillColor: const Color(0xFFF8FAFC),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF1A237E),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Text(
            label,

            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            value,

            textAlign: TextAlign.right,

            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  Widget _primaryButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: Icon(
          icon,
          size: 18,
        ),

        label: Text(text),

        style: ElevatedButton.styleFrom(
          backgroundColor:  const Color(0xFF000080),
          foregroundColor: Colors.white,

          elevation: 0,

          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: _inputDecoration(
        hint: label,
        icon: icon,
      ),
    );
  }
}




//{
// "data": [
// {
// "customer_id": "214111",
// "imei_1": "351406250347931",
// "pos_invoice_number": "214111",
// "payment_amount":   -4198,
// "payment_date": "2026-07-20",
// "total_due_amount": 4198,
// "emi_status": 1,
// "payment_type": "Bank",
// "payment_description": "payment done from postman E"
// }
// ]
// }
// {
// "mdm_name": "Walton MDM",
// "application_id": "151635",
// "new_imei": "356516190319736",
// "old_imei_1": "356516190461678",
// "old_imei_2": "356516190461686",
// "new_model": "Orbit Y72",
// "reason" : "Kongka"
// }