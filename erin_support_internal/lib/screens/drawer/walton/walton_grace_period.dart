import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';

class WaltonGracePeriod extends StatefulWidget {
  const WaltonGracePeriod({super.key});

  @override
  State<WaltonGracePeriod> createState() => _WaltonGracePeriodPageState();
}

class _WaltonGracePeriodPageState extends State<WaltonGracePeriod> {
  late TextEditingController imei1Controller;
  late TextEditingController releaseDateController;

  bool isLoading = false;

  LoginData? customer;
  String? token;
  String? oldImei1;
  DateTime? selectedReleaseDate;

  @override
  void initState() {
    super.initState();

    imei1Controller = TextEditingController();
    releaseDateController = TextEditingController();

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = await Save.getUser();

      if (!mounted) return;

      if (user?.data == null) {
        setState(() {
          customer = null;
          oldImei1 = null;
          token = null;
          imei1Controller.clear();
        });
        return;
      }

      final data = user!.data!;
      final imei = data.mdmInfo?.imei1;

      setState(() {
        customer = data;
        token = user.token;
        oldImei1 = imei;
        imei1Controller.text = imei ?? '';
      });
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  @override
  void dispose() {
    imei1Controller.dispose();
    releaseDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _selectReleaseDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedReleaseDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Release Date',
      cancelText: 'CANCEL',
      confirmText: 'SELECT',
    );

    if (picked == null || !mounted) return;

    setState(() {
      selectedReleaseDate = picked;
      releaseDateController.text = _formatDate(picked);
    });
  }

  Future<void> unlockDevice() async {
    final imei = imei1Controller.text.trim();
    final releaseDate = releaseDateController.text.trim();

    if (imei.isEmpty) {
      _showMessage('IMEI is required', isError: true);
      return;
    }

    if (releaseDate.isEmpty) {
      _showMessage('Please select a grace period release date', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$WaltonURl/api/allow-graceperiod');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',

      // Replace with your API's required authorization value.
      'Authorization': 'K9s8X7P0LwE3QzN2A==',
    };

    final body = jsonEncode({'imei': imei, 'release_date': releaseDate});

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('Grace Period Status: ${response.statusCode}');
      debugPrint('Grace Period Response: ${response.body}');

      if (!mounted) return;

      dynamic responseData;

      try {
        responseData = jsonDecode(response.body);
      } catch (_) {
        responseData = null;
      }

      final apiSuccess = responseData is Map && responseData['status'] == true;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          (responseData is! Map ||
              !responseData.containsKey('status') ||
              apiSuccess)) {
        _showMessage(
          'Grace period request completed successfully',
          isError: false,
        );
      } else {
        final message = responseData is Map
            ? responseData['message']?.toString()
            : null;

        _showMessage(
          message != null && message.isNotEmpty
              ? message
              : 'Failed to apply grace period '
                    '(${response.statusCode})',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Grace period API error: $e');

      if (!mounted) return;

      _showMessage(
        'Unable to connect to the server. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _initialize,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _sectionHeader(
                  icon: Icons.person_outline,
                  title: 'Grace Period',
                ),
                const SizedBox(height: 20),
                _buildApplicationCard(),
                const SizedBox(height: 20),
                _buildGracePeriodCard(),
              ],
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            label: 'Customer ID',
            value: customer?.applicationId?.toString() ?? 'N/A',
          ),
          const SizedBox(height: 18),
          _infoRow(label: 'Registered IMEI 1', value: oldImei1 ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildGracePeriodCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.calendar_month,
            title: 'Allow Grace Period',
          ),
          const SizedBox(height: 18),

          _buildEditableField(
            controller: imei1Controller,
            label: 'IMEI 1',
            icon: Icons.phone_android,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 14),

          TextField(
            controller: releaseDateController,
            readOnly: true,
            onTap: isLoading ? null : _selectReleaseDate,
            decoration:
                _inputDecoration(
                  hint: 'Select  Release Date',
                  icon: Icons.calendar_month,
                ).copyWith(
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF1A237E),
                  ),
                ),
          ),

          const SizedBox(height: 20),

          _primaryButton(
            icon: Icons.event_available,
            text: 'Allow Grace Period',
            onPressed: isLoading ? () {} : unlockDevice,
          ),
        ],
      ),
    );
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
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
          backgroundColor: const Color(0xFF155dfc),
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
