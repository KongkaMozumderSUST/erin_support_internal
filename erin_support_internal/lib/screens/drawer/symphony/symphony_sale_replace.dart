import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';

class SymphonySaleReplace extends StatefulWidget {
  const SymphonySaleReplace({super.key});

  @override
  State<SymphonySaleReplace> createState() => _SymphonySaleReplacePageState();
}

class _SymphonySaleReplacePageState extends State<SymphonySaleReplace> {
  late TextEditingController oldImei1Controller;
  late TextEditingController oldImei2Controller;
  late TextEditingController newImei1Controller;
  late TextEditingController newModelController;
  late TextEditingController oldModelController;

  bool isLoading = false;
  LoginData? customer;
  String? token;
  String? customerId;
  String? old_imei1;
  String? old_imei2;
  String? new_imei1;
  String? new_model;
  String? old_model;

  @override
  void initState() {
    super.initState();
    oldImei1Controller = TextEditingController();
    oldImei2Controller = TextEditingController();
    newImei1Controller = TextEditingController();
    newModelController = TextEditingController();
    oldModelController = TextEditingController();

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
    } else {
      setState(() {
        final data = user!.data!;
        customer = data;
        token = user.token;
        customerId = data.applicationId;
        old_imei1 = data.mdmInfo?.imei1;
        old_imei2 = data.mdmInfo?.imei2;
        oldImei1Controller.text = old_imei1 ?? '';
        oldImei2Controller.text = old_imei2 ?? '';
      });
    }
  }

  @override
  void dispose() {
    oldImei1Controller.dispose();
    oldImei2Controller.dispose();
    newImei1Controller.dispose();
    newModelController.dispose();
    oldModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
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
            SizedBox(height: 20),
            _buildApplicationCard(),
            SizedBox(height: 20),
            _buildPaymentCard(),
          ],
        ),
      ),
    );
  }

  Future<void> SaleReplace() async {
    final oldImei1 = oldImei1Controller.text.trim();
    final oldImei2 = oldImei2Controller.text.trim();
    final newImei1 = newImei1Controller.text.trim();
    final oldModel = oldModelController.text.trim();
    final newModel = newModelController.text.trim();

    if (newImei1.isEmpty || oldModel.isEmpty || newModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "New IMEI, old model, and new model are required",
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$SymphonyURL/api/sale-replace');
    final body = jsonEncode({
      "new_imei": newImei1,
      "new_model": newModel,
      "old_imei_1": oldImei1,
      "old_imei_2": oldImei2,
      "old_model": oldModel,
      "manager_id": "31012",
      "manager_name": "Branch Manager",
      "replaced_by_user_id": "198116",
      "replaced_by_user_name": "CSM,Shariatpur",
      "date_of_approval": DateTime.now().toIso8601String().split('T').first,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'iF3PTw5zRSMTAyMTY=7JdKeu2ULE3A==',
    };

    try {
      final res = await http.post(url, body: body, headers: headers);

      print("Status Code: ${res.statusCode}");
      print("Response: ${res.body}");
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        if (json["status"] == 200) {
          final data = json["data"];
          print(data);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sale replacement completed"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            isLoading = false;
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                json["message"]?.toString() ?? "Sale replacement failed",
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
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
          content: const Text(
            "Something went wrong. Please check your network connection.",
          ),
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

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(9),
          ),

          child: Icon(icon, color: const Color(0xFF1A237E), size: 20),
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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE2E8F0)),

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
          _infoRow(label: 'Imei 1', value: old_imei1 ?? 'N/A'),
          const SizedBox(height: 12),
          _infoRow(label: 'Imei 2', value: old_imei2 ?? 'N/A'),
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
            title: 'Update Imei Information',
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
            controller: oldModelController,
            label: 'Old Model',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: newModelController,
            label: 'New Model',
            icon: Icons.payment_outlined,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          _primaryButton(
            icon: Icons.save_outlined,
            text: 'Sale Replace',
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
                          Icons.warning,
                          color: Color(0xFFD50000),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Symphony Sale Replace',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    'Do you want to change the imei?',
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
                        SaleReplace();
                      },
                      child: const Text(
                        'Change Imei',
                        style: TextStyle(fontWeight: FontWeight.w600),
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

      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),

      filled: true,

      fillColor: const Color(0xFFF8FAFC),

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
      ),
    );
  }

  Widget _infoRow({required String label, required String value}) {
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

        icon: Icon(icon, size: 18),

        label: Text(text),

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF000080),
          foregroundColor: Colors.white,

          elevation: 0,

          padding: const EdgeInsets.symmetric(vertical: 14),

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

      decoration: _inputDecoration(hint: label, icon: icon),
    );
  }
}
