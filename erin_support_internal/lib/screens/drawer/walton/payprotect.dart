import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:erin_support_internal/models/payProtectData.dart';
import 'package:erin_support_internal/others/save.dart';

class SaleRecordScreen extends StatefulWidget {
  const SaleRecordScreen({
    super.key,
  });

  @override
  State<SaleRecordScreen> createState() => _SaleRecordScreenState();
}



class SaleRecordService {
  Future<SaleRecord?> getSaleRecord(String? customerId) async {
    if (customerId == null || customerId.isEmpty) {
      throw Exception('Customer ID not found');
    }

    final url = Uri.parse(
      'https://emi.bikroyik.com/api/sale-record-by-customer-id/$customerId',
    );

    final response = await http.get(url);

    debugPrint('Sale Record Status: ${response.statusCode}');
    debugPrint('Sale Record Response: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final data = jsonData['data'] as List? ?? [];

      if (data.isEmpty) {
        return null;
      }

      return SaleRecord.fromJson(data.first);
    }

    throw Exception(
      'Failed to load sale record: ${response.statusCode}',
    );
  }
}



class _SaleRecordScreenState extends State<SaleRecordScreen> {
  final SaleRecordService _service = SaleRecordService();

  SaleRecord? saleRecord;
  bool isLoading = true;

  String? error;
  String? customerId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }


  Future<void> _initialize() async {
    try {
      final user = await Save.getUser();

      if (!mounted) return;

      if (user?.data == null) {
        setState(() {
          isLoading = false;
          error = 'No user data found';
        });
        return;
      }

      final data = user!.data!;

      customerId = data.applicationId;

      await _loadSaleRecord();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }



  Future<void> _loadSaleRecord() async {
    try {
      final result = await _service.getSaleRecord(customerId);

      if (!mounted) return;

      setState(() {
        saleRecord = result;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }



  Future<void> _copyImei(
      String title,
      String value,
      ) async {
    if (value.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: value),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title copied'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }


  @override
  Widget build(BuildContext context) {


    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
          ),
        ),
      );
    }


    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 42,
                  color: Color(0xFFDC2626),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      error = null;
                    });

                    _initialize();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }


    if (saleRecord == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: Text(
            'No sale record found',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final data = saleRecord!;



    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: RefreshIndicator(
        color: const Color(0xFF059669),
        onRefresh: _loadSaleRecord,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              _customerCard(data),

              const SizedBox(height: 16),

              _paymentCard(data),

              const SizedBox(height: 16),

              _deviceCard(data),

              const SizedBox(height: 16),

              _statusCard(data),

              const SizedBox(height: 16),

              _saleInfoCard(data),

              const SizedBox(height: 16),

              _locationCard(data),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Erin Support v1.0.0',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  Widget _customerCard(SaleRecord data) {
    return _card(
      title: 'Customer Information',
      icon: Icons.person_outline,
      children: [
        _item(
          'Customer ID',
          data.customerId.toString(),
        ),

        _item(
          'Customer Name',
          data.customerName,
        ),

        _item(
          'POS Invoice',
          data.posInvoiceNumber,
        ),

        _item(
          'Retailer',
          data.retailName,
        ),

        _item(
          'Sales Person',
          data.salesPersonName.isEmpty
              ? 'Not assigned'
              : data.salesPersonName,
        ),
      ],
    );
  }



  Widget _paymentCard(SaleRecord data) {
    return _card(
      title: 'Payment Information',
      icon: Icons.payments_outlined,
      children: [
        _item(
          'Device Price',
          '৳${data.price.toStringAsFixed(2)}',
        ),

        _item(
          'Down Payment',
          '৳${data.downPayment.toStringAsFixed(2)}',
        ),

        _item(
          'Total Paid',
          '৳${data.totalPaid.toStringAsFixed(2)}',
        ),

        _item(
          'Due',
          '৳${data.due.toStringAsFixed(2)}',
          valueColor: const Color(0xFFDC2626),
        ),

        _item(
          'Installments',
          '${data.noOfInstallment}',
        ),

        _item(
          'Next Installment',
          data.nextInstallmentDate,
        ),
      ],
    );
  }



  Widget _deviceCard(SaleRecord data) {
    return _card(
      title: 'Device Information',
      icon: Icons.phone_android_outlined,
      children: [
        _item(
          'Brand',
          data.brand,
        ),

        _item(
          'Model',
          data.model,
        ),

        _item(
          'Color',
          data.color,
        ),

        // IMEI 1
        _copyItem(
          title: 'IMEI 1',
          value: data.imei1,
        ),

        // IMEI 2
        _copyItem(
          title: 'IMEI 2',
          value: data.imei2,
        ),
      ],
    );
  }



  Widget _statusCard(SaleRecord data) {
    return _card(
      title: 'Device Status',
      icon: Icons.security_outlined,
      children: [
        _item(
          'System Status',
          data.systemAppStatus,
          valueColor: const Color(0xFF059669),
        ),

        _item(
          'Device Status',
          data.deviceStatus,
          valueColor: data.deviceStatus == "Lock"?  const Color(0xFFFF0000) : const Color(0xFF059669),
        ),

        _item(
          'Lock Response',
          data.lockResponse,
        ),

        _item(
          'Force Lock',
          data.forceLockStatus == 1
              ? 'Enabled'
              : 'Disabled',
        ),

        _item(
          'EMI Status',
          data.emiStatus == 1
              ? 'Active'
              : 'Inactive',
        ),
      ],
    );
  }


  Widget _saleInfoCard(SaleRecord data) {
    return _card(
      title: 'Sale Information',
      icon: Icons.receipt_long_outlined,
      children: [
        _item(
          'Down Payment Date',
          data.downPaymentDate,
        ),

        _item(
          'Last Sync',
          data.lastSync,
        ),
      ],
    );
  }



  Widget _locationCard(SaleRecord data) {
    return _card(
      title: 'Last Known Location',
      icon: Icons.location_on_outlined,
      children: [
        Text(
          data.lastLocation.isEmpty
              ? 'Location not available'
              : data.lastLocation,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
            height: 1.4,
          ),
        ),
      ],
    );
  }



  Widget _copyItem({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Flexible(
                  child: Text(
                    value.isEmpty
                        ? 'Not available'
                        : value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Material(
                  color: Colors.transparent,

                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),

                    onTap: value.isEmpty
                        ? null
                        : () => _copyImei(
                      title,
                      value,
                    ),

                    child: Container(
                      padding: const EdgeInsets.all(6),

                      decoration: BoxDecoration(
                        color: value.isEmpty
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFE8F7F0),

                        borderRadius:
                        BorderRadius.circular(8),
                      ),

                      child: Icon(
                        Icons.copy_outlined,
                        size: 16,

                        color: value.isEmpty
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _item(
      String title,
      String value, {
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value.isEmpty
                  ? 'Not available'
                  : value,
              textAlign: TextAlign.right,

              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ??
                    const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.all(9),

                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),

                  borderRadius:
                  BorderRadius.circular(10),
                ),

                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }
}