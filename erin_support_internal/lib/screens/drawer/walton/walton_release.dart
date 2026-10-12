import 'dart:convert';

import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';
import 'package:erin_support_internal/others/save.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WaltonRelease extends StatefulWidget {
  const WaltonRelease({super.key});

  @override
  State<WaltonRelease> createState() => _WaltonReleaseState();
}

class _WaltonReleaseState extends State<WaltonRelease> {
  LoginData? _customer;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final user = await Save.getUser();
      if (!mounted) return;

      setState(() {
        _customer = user?.data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _showMessage(
        'Unable to load customer information: $error',
        isError: true,
      );
    }
  }

  Future<void> _submitRelease() async {
    final customer = _customer;
    final customerId = customer?.applicationId;
    final imei = customer?.mdmInfo?.imei1;

    if (customerId == null ||
        customerId.isEmpty ||
        imei == null ||
        imei.isEmpty) {
      _showMessage(
        'Customer ID and IMEI are required to release this device.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final payload = {
      'data': [
        {
          'customer_id': customerId,
          'imei_1': imei,
          'pos_invoice_number': customerId,
          'payment_amount': 0,
          'payment_date': '2026-07-20',
          'total_due_amount': 0,
          'emi_status': 0,
          'payment_type': 'Bank',
          'payment_description': 'payment done from postman E',
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse('$WaltonURl/api/emi-payment'),
        headers: const {
          'Content-Type': 'application/json',
          'Authorization': 'K9s8X7P0LwE3QzN2A==',
        },
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showMessage('Release payment submitted successfully.');
      } else {
        _showMessage(
          'Release payment failed (${response.statusCode}).',
          isError: true,
        );
      }
    } catch (error) {
      if (!mounted) return;
      _showMessage('Release payment failed: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final customer = _customer;
    final customerId = customer?.applicationId ?? 'Unavailable';
    final imei = customer?.mdmInfo?.imei1 ?? 'Unavailable';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(),
          const SizedBox(height: 20),
          _card(
            children: [
              _infoRow('Customer ID', customerId),
              _infoRow('IMEI 1', imei),
              _infoRow('POS Invoice Number', customerId),
              _infoRow('Payment Amount', '1'),
              _infoRow('Payment Date', '2026-07-20'),
              _infoRow('Total Due Amount', '0'),
              _infoRow('EMI Status', '0'),
              _infoRow('Payment Type', 'Bank'),
              _infoRow('Description', 'payment done from postman E'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRelease,
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_open_outlined),
              label: Text(_isSubmitting ? 'Submitting...' : 'Release Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000080),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.lock_open_outlined,
            color: Color(0xFF1A237E),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Walton Release',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
      ),
    );
  }
}
