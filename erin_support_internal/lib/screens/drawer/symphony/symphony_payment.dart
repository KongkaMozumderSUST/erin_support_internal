import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';

class SymphonyEmiPayment extends StatefulWidget {
  const SymphonyEmiPayment({super.key});

  @override
  State<SymphonyEmiPayment> createState() => _SymphonyEmiPaymentPageState();
}

class _SymphonyEmiPaymentPageState extends State<SymphonyEmiPayment> {

  late TextEditingController paymentController;
  late TextEditingController totalDuePaymentController;

  bool isLoading = false;
  LoginData? customer;
  String? token;
  String? customerId;
  String? imei1;
  String? invoiceNumber;
  int? paymentAmount ;
  int? totalDueAmount;

  @override
  void initState() {
    super.initState();
    paymentController = TextEditingController();
    totalDuePaymentController = TextEditingController();
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
        imei1 =  data.mdmInfo?.imei1;
      });
    }

  }

  @override
  void dispose() {
    paymentController.dispose();
    totalDuePaymentController.dispose();
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
            value: imei1 ?? 'N/A',
          ),
          const SizedBox(height: 12),

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
            title: 'Update Installment',
          ),

          const SizedBox(height: 18),


          // IMEI 1
          _buildEditableField(
            controller: paymentController,
            label: 'Payment Amount',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 12),

          // IMEI 2
          _buildEditableField(
            controller: totalDuePaymentController,
            label: 'Total Due Amount',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          _primaryButton(
            icon: Icons.save_outlined,
            text: 'Update Payment',
            onPressed: updatePayment,
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
  Future<void> updatePayment() async {
    if (paymentController.text.trim().isEmpty && totalDuePaymentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Installment amount and total due are required"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      paymentAmount = int.tryParse(paymentController.text.trim());
      totalDueAmount = int.tryParse(totalDuePaymentController.text.trim());
      isLoading = true;
    });

    final url = Uri.parse('$SymphonyURL/api/emi-payment');
    final body = jsonEncode({
      'data' :
      [
        {
          'customer_id': customerId,
          'payment_id': customerId,
          'imei_1': imei1,
          'pos_invoice_number': customerId,
          'payment_amount': paymentAmount,
          'payment_date': "2026-07-20",
          'total_due_amount': totalDueAmount,
          'emi_status': 1,
          'payment_type': "Bank",
          'payment_description': "payment done from Erin Support Internal App"
        }
      ]
    });




    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'iF3PTw5zRSMTAyMTY=7JdKeu2ULE3A=='
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
            content: Text("Payment Update Successful: ${res.statusCode}"),
            backgroundColor: Colors.green.shade700,
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
            content: Text("Payment Update failed: ${res.statusCode}"),
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
}



