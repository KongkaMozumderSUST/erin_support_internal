import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';


class SymphonyLock extends StatefulWidget {
  const SymphonyLock({super.key});

  @override
  State<SymphonyLock> createState() => _SymphonyLockPageState();
}

class _SymphonyLockPageState extends State<SymphonyLock> {

  late TextEditingController Imei1Controller;


  bool isLoading = false;
  LoginData? customer;
  String? token;
  String? old_imei1;

  @override
  void initState() {
    super.initState();
    Imei1Controller = TextEditingController();
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
        old_imei1 =  data.mdmInfo?.imei1;
        Imei1Controller.text = old_imei1!;
      });
    }

  }

  @override
  void dispose() {
    Imei1Controller.dispose();
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
              title: 'Lock the helio device',
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
  Future<void> lockDevice() async {
    if (Imei1Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Imei is required"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$SymphonyURL/api/lock-device-by-seller?imei=$old_imei1');


    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'iF3PTw5zRSMTAyMTY=7JdKeu2ULE3A=='
    };

    try {
      final res = await http.post(
        url,
        headers: headers,
      );

      print("Status Code: ${res.statusCode}");
      print("Response: ${res.body}");
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

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
            content: Text("Locked Device Successfully: ${res.statusCode}"),
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
          content: const Text("Something went wrong."),
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
            title: 'Lock the helio device',
          ),

          const SizedBox(height: 18),


          // IMEI 1
          _buildEditableField(
            controller: Imei1Controller,
            label: 'Imei 1',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 12),

          _primaryButton(
            icon: Icons.lock,
            text: 'Lock Device',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Color(0xFFD50000),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Lock the phone',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    'Do you want to lock phone?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD50000),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        lockDevice();
                      },
                      child: const Text(
                        'Lock Phone',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
