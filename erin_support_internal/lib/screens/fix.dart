import 'package:flutter/material.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/screens/auth/login.dart';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Fix extends StatefulWidget {
  const Fix({super.key});

  @override
  State<Fix> createState() => _FixState();
}

class _FixState extends State<Fix> {
  bool isLoading = true;

  LoginData? customer;
  String? token;
  String? applicationUuid;
  String? customerId;
  String? mdmName;

  // STATUS

  String selectedStatus = '';

  // MDM

  late TextEditingController imei1Controller;
  late TextEditingController imei2Controller;
  late TextEditingController downPaymentController;
  late TextEditingController mdmNameController;


  // EMI

  /*
   * This is the editable EMI list.
   *
   * Structure:
   *
   * {
   *   scheduleNumber: "1",
   *   scheduleDate: "2026-05-26",
   *   emiAmount: "1738.17",
   *   status: "unpaid"
   * }
   */
  List<Map<String, String>> editableEmiList = [];

  @override
  void initState() {
    super.initState();

    imei1Controller = TextEditingController();
    imei2Controller = TextEditingController();
    mdmNameController = TextEditingController();
    downPaymentController = TextEditingController();

    _initialize();
  }

  @override
  void dispose() {
    imei1Controller.dispose();
    imei2Controller.dispose();
    mdmNameController.dispose();
    downPaymentController.dispose();

    super.dispose();
  }


  // INITIALIZE


  Future<void> _initialize() async {
    final user = await Save.getUser();

    if (!mounted) return;

    if (user?.data == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final data = user!.data!;

    customer = data;

    token = user.token;
    applicationUuid = data.uuid;
    customerId = data.applicationId;

    // STATUS
    selectedStatus = data.status ?? '';

    // MDM
    imei1Controller.text = data.mdmInfo?.imei1 ?? '';
    imei2Controller.text = data.mdmInfo?.imei2 ?? '';
    downPaymentController.text =
        data.mdmInfo?.downPayment ?? '';

    // EMI
    _prepareEmiList();
    setState(() {
      isLoading = false;
    });
  }
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // PREPARE EMI LIST


  void _prepareEmiList() {
    final existingEmiInfo = customer?.emiInfo;

    // ==========================================================
    // CASE 1:
    // emiInfo exists
    //
    // Use emiInfo completely.
    // ==========================================================

    if (existingEmiInfo != null) {
      editableEmiList = existingEmiInfo.map((emi) {
        return {
          'scheduleNumber': emi.scheduleNumber ?? '',
          'scheduleDate': emi.scheduleDate ?? '',
          'emiAmount': emi.emiAmount ?? '',
          'status': _normalizeEmiStatus(
            emi.status,
          ),
        };
      }).toList();

      return;
    }

    // ==========================================================
    // CASE 2:
    // emiInfo is null
    //
    // Use loanCreationDetails.emischedule.
    //
    // Since there is no payment status yet,
    // default status = unpaid.
    // ==========================================================

    final loanEmiSchedule =
        customer?.loanCreationDetails?.emischedule;

    if (loanEmiSchedule == null) {
      editableEmiList = [];
      return;
    }

    editableEmiList = loanEmiSchedule.map((emi) {
      return {
        'scheduleNumber': emi.scheduleNumber ?? '',
        'scheduleDate': emi.scheduleDate ?? '',
        'emiAmount': emi.emiAmount ?? '',
        'status': 'unpaid',
      };
    }).toList();
  }

  // NORMALIZE EMI STATUS


  String _normalizeEmiStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return 'unpaid';
    }

    final value = status.toLowerCase().trim();

    if (value == 'paid') {
      return 'paid';
    }

    return 'unpaid';
  }


  // LOGOUT

  Future<void> _logout() async {
    await Save.clearUser();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Login(),
      ),
    );
  }

  // BUILD

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
            _buildApplicationCard(),

            const SizedBox(height: 16),

            //  _buildStatusCard(),

            const SizedBox(height: 16),

            _buildMdmCard(),

            const SizedBox(height: 16),

            _buildEmiCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // APPLICATION INFORMATION

  Widget _buildApplicationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            icon: Icons.person_outline,
            title: 'Application Information',
          ),
          const SizedBox(height: 12),
          _infoRow(
            label: 'Customer ID',
            value: customer?.applicationId ?? 'N/A',
          ),

          const SizedBox(height: 18),

          _infoRow(
            label: 'Application UUID',
            value: customer?.uuid ?? 'N/A',
          ),


          const SizedBox(height: 12),

          _infoRow(
            label: 'User Reference',
            value: customer?.userRefNo ?? 'N/A',
          ),

          const SizedBox(height: 12),

          _infoRow(
            label: 'Loan Account',
            value:
            customer?.loanCreationDetails?.loanaccno ??
                'N/A',
          ),
          const SizedBox(height: 12),
          _infoRowMdmOrEmi(
              label: 'Emi Information',
              value: customer?.emiInfo != null? "Available" : "Not Available"
          ),
          const SizedBox(height: 12),
          _infoRowMdmOrEmi(
              label: 'MDM Information',
              value:
              customer?.mdmInfo != null? "Available" : "Not Available"
          ),
        ],
      ),
    );
  }


  // STATUS CARD


  Widget _buildStatusCard() {
    final currentStatus = customer?.status ?? 'N/A';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            icon: Icons.flag_outlined,
            title: 'Application Status',
          ),

          const SizedBox(height: 18),

          const Text(
            'Current Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),

            decoration: BoxDecoration(
              color: _statusBackground(currentStatus),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _statusBorder(currentStatus),
              ),
            ),

            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,

                  decoration: BoxDecoration(
                    color: _statusColor(currentStatus),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  currentStatus.isEmpty
                      ? 'N/A'
                      : currentStatus,

                  style: TextStyle(
                    color: _statusColor(currentStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Update Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _statusDropdownValue(),

            decoration: _inputDecoration(
              hint: 'Select status',
              icon: Icons.swap_vert,
            ),

            items: const [
              DropdownMenuItem(
                value: '0',
                child: Text('0'),
              ),
              DropdownMenuItem(
                value: '11',
                child: Text('11'),
              ),
              DropdownMenuItem(
                value: '7',
                child: Text('7'),
              ),
              DropdownMenuItem(
                value: '12',
                child: Text('12'),
              ),
              DropdownMenuItem(
                value: '13',
                child: Text('13'),
              ),
              DropdownMenuItem(
                value: '14',
                child: Text('14'),
              ),
              DropdownMenuItem(
                value: '10',
                child: Text('10'),
              ),
            ],

            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedStatus = value;
              });
            },
          ),

          const SizedBox(height: 14),

          _primaryButton(
            icon: Icons.save_outlined,
            text: 'Update Status',

            onPressed: () async {
              // Connect status update API here.\
              await updateStatus();
            },
          ),
        ],
      ),
    );
  }

  // STATUS DROPDOWN VALUE

  String? _statusDropdownValue() {
    final value = selectedStatus.toLowerCase();

    const allowed = [
      'pending',
      'approved',
      'rejected',
      'processing',
      'completed',
    ];

    if (allowed.contains(value)) {
      return value;
    }

    return null;
  }


  // MDM CARD

  Widget _buildMdmCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.phone_android_outlined,
            title: 'MDM Information',
          ),

          const SizedBox(height: 18),

          // MDM NAME
          _buildEditableField(
              controller: mdmNameController,
              label: 'MDM Name',
              icon: Icons.security_outlined,
              keyboardType: TextInputType.text
          ),

          const SizedBox(height: 12),

          // IMEI 1
          _buildEditableField(
            controller: imei1Controller,
            label: 'IMEI 1',
            icon: Icons.smartphone_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 12),

          // IMEI 2
          _buildEditableField(
            controller: imei2Controller,
            label: 'IMEI 2',
            icon: Icons.smartphone_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          _primaryButton(
            icon: Icons.save_outlined,
            text: 'Update MDM Information',
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
                          Icons.save_outlined,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Confirm MDM Update',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    'Are you sure you want to update the MDM information?',
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
                        backgroundColor: const Color(0xFF059669),
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
                        updateMdmInfo();
                      },
                      child: const Text(
                        'Confirm',
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



  Widget _buildEmiCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.receipt_long_outlined,
            title: 'EMI Information',
          ),

          const SizedBox(height: 16),

          if (editableEmiList.isEmpty)
            _emptyState(
              icon: Icons.receipt_long_outlined,
              text: 'No EMI information available',
            )
          else
            Column(
              children: editableEmiList.asMap().entries.map((entry) {
                final index = entry.key;
                final emi = entry.value;

                final status = emi['status'] ?? 'unpaid';
                final isPaid = status.toLowerCase() == 'paid';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),

                    // EMI NUMBER
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        emi['scheduleNumber'] ?? '',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // DATE
                    title: Text(
                      'Date: ${_formatDate(emi['scheduleDate'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    // AMOUNT
                    subtitle: Text(
                      'Amount: ৳ ${emi['emiAmount'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    // PAID / UNPAID DROPDOWN
                    trailing: DropdownButton<String>(
                      value: isPaid ? 'paid' : 'unpaid',
                      underline: const SizedBox(),

                      items: const [
                        DropdownMenuItem(
                          value: 'paid',
                          child: Text('Paid'),
                        ),
                        DropdownMenuItem(
                          value: 'unpaid',
                          child: Text('Unpaid'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          editableEmiList[index]['status'] = value;
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

          // UPDATE BUTTON
          if (editableEmiList.isNotEmpty) ...[
            const SizedBox(height: 16),

            _primaryButton(
              icon: Icons.save_outlined,
              text: 'Update EMI Information',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      16,
                    ),

                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.save_outlined,
                            color: Color(0xFF059669),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Text(
                            'Confirm EMI Update',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    content: const Text(
                      'Are you sure you want to update the EMI information?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),

                    actionsPadding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      20,
                    ),

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
                          backgroundColor: const Color(0xFF059669),
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
                          updateEmiInfo();
                        },

                        child: const Text(
                          'Confirm',
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
        ],
      ),
    );
  }



  // // EMI CARD
  //
  // Widget _buildEmiCard() {
  //   return _card(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //
  //       children: [
  //         _sectionHeader(
  //           icon: Icons.receipt_long_outlined,
  //           title: 'EMI Information',
  //         ),
  //
  //         const SizedBox(height: 18),
  //
  //         if (editableEmiList.isEmpty)
  //           _emptyState(
  //             icon: Icons.receipt_long_outlined,
  //             text: 'No EMI information available',
  //           )
  //         else
  //           Column(
  //             children: [
  //               ...editableEmiList.asMap().entries.map(
  //                     (entry) {
  //                   final index = entry.key;
  //                   final emi = entry.value;
  //
  //                   return Padding(
  //                     padding: EdgeInsets.only(
  //                       bottom:
  //                       index == editableEmiList.length - 1
  //                           ? 0
  //                           : 12,
  //                     ),
  //
  //                     child: _buildEmiItem(
  //                       index: index,
  //                       emi: emi,
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //
  //         if (editableEmiList.isNotEmpty) ...[
  //           const SizedBox(height: 18),
  //
  //           _primaryButton(
  //             icon: Icons.save_outlined,
  //             text: 'Update EMI Information',
  //
  //             onPressed: () {
  //               showDialog(
  //                 context: context,
  //                 builder: (context) => AlertDialog(
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(20),
  //                   ),
  //                   contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
  //                   title: Row(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.all(10),
  //                         decoration: BoxDecoration(
  //                           color: const Color(0xFFE8F7F0),
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: const Icon(
  //                           Icons.save_outlined,
  //                           color: Color(0xFF059669),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       const Text(
  //                         'Confirm EMI Update',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   content: const Text(
  //                     'Are you sure you want to update the EMI information?',
  //                     style: TextStyle(
  //                       fontSize: 15,
  //                       color: Color(0xFF64748B),
  //                       height: 1.5,
  //                     ),
  //                   ),
  //                   actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text(
  //                         'Cancel',
  //                         style: TextStyle(
  //                           color: Color(0xFF64748B),
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ),
  //                     ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xFF059669),
  //                         foregroundColor: Colors.white,
  //                         elevation: 0,
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 22,
  //                           vertical: 12,
  //                         ),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         updateEmiInfo();
  //                       },
  //                       child: const Text(
  //                         'Confirm',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
  //
  // // EMI ITEM
  //
  // Widget _buildEmiItem({
  //   required int index,
  //   required Map<String, String> emi,
  // }) {
  //   final status = emi['status'] ?? 'unpaid';
  //
  //   final isPaid = status.toLowerCase() == 'paid';
  //
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF8FAFC),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: const Color(0xFFE2E8F0),
  //       ),
  //     ),
  //
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //
  //       children: [
  //
  //         // HEADER
  //
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 10,
  //                 vertical: 6,
  //               ),
  //
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFE8EAF6),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //
  //               child: Text(
  //                 'EMI #${emi['scheduleNumber']}',
  //
  //                 style: const TextStyle(
  //                   color: Color(0xFF1A237E),
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 13,
  //                 ),
  //               ),
  //             ),
  //
  //             const Spacer(),
  //
  //             _emiStatusBadge(status),
  //           ],
  //         ),
  //
  //         const SizedBox(height: 16),
  //
  //         // DATE
  //
  //         _infoRow(
  //           label: 'Schedule Date',
  //           value: _formatDate(
  //             emi['scheduleDate'],
  //           ),
  //         ),
  //
  //         const SizedBox(height: 12),
  //
  //         // AMOUNT
  //
  //
  //         _infoRow(
  //           label: 'EMI Amount',
  //           value: '৳ ${emi['emiAmount'] ?? ''}',
  //         ),
  //
  //         const SizedBox(height: 14),
  //
  //         // STATUS
  //
  //         const Text(
  //           'Payment Status',
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF64748B),
  //           ),
  //         ),
  //
  //         const SizedBox(height: 8),
  //
  //         DropdownButtonFormField<String>(
  //           value: isPaid ? 'paid' : 'unpaid',
  //
  //           decoration: _inputDecoration(
  //             hint: 'Select payment status',
  //             icon: Icons.payment_outlined,
  //           ),
  //
  //           items: const [
  //             DropdownMenuItem(
  //               value: 'paid',
  //               child: Text('Paid'),
  //             ),
  //
  //             DropdownMenuItem(
  //               value: 'unpaid',
  //               child: Text('Unpaid'),
  //             ),
  //           ],
  //
  //           onChanged: (value) {
  //             if (value == null) return;
  //
  //             setState(() {
  //               editableEmiList[index]['status'] = value;
  //             });
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  //
  // // EMI STATUS BADGE


  Widget _emiStatusBadge(String status) {
    final isPaid = status.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        isPaid ? 'Paid' : 'Unpaid',

        style: TextStyle(
          color: isPaid
              ? const Color(0xFF15803D)
              : const Color(0xFFD97706),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  // SHOW EMI PAYLOAD


  void _showEmiPayload() async {
    await updateEmiInfo();
    /*
     * This is the exact structure that can later be sent
     * to your update EMI API.
     *
     * Example:
     *
     * [
     *   {
     *     "scheduleNumber": "1",
     *     "scheduleDate": "2026-05-26",
     *     "emiAmount": "1738.17",
     *     "status": "paid"
     *   }
     * ]
     *
     * For now we only print it.
     */

    debugPrint(
      '========== EMI UPDATE PAYLOAD ==========',
    );

    for (final emi in editableEmiList) {
      debugPrint(emi.toString());
    }

    debugPrint(
      '=========================================',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'EMI changes are ready to update.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  // EDITABLE FIELD


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

  // CARD


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
  // SECTION HEADER


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

  // INFO ROW

  Widget _infoRowMdmOrEmi({
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

            style: TextStyle(
              color: value=="Available"?const Color(0xFF388E3C):const Color(0xFFD50000),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

  // INPUT DECORATION


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

  // PRIMARY BUTTON

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


  // EMPTY STATE

  Widget _emptyState({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: const Color(0xFF94A3B8),
          ),

          const SizedBox(height: 10),

          Text(
            text,

            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // DATE FORMAT

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'N/A';
    }

    try {
      final parsed = DateTime.parse(date);

      return '${parsed.day.toString().padLeft(2, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  // GENERAL STATUS COLOR

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
      case 'completed':
        return const Color(0xFF16A34A);

      case 'overdue':
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFDC2626);

      case 'pending':
      case 'processing':
        return const Color(0xFFD97706);

      default:
        return const Color(0xFF64748B);
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
      case 'completed':
        return const Color(0xFFF0FDF4);

      case 'overdue':
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFFEF2F2);

      case 'pending':
      case 'processing':
        return const Color(0xFFFFFBEB);

      default:
        return const Color(0xFFF8FAFC);
    }
  }

  Color _statusBorder(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
      case 'completed':
        return const Color(0xFFBBF7D0);

      case 'overdue':
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFFECACA);

      case 'pending':
      case 'processing':
        return const Color(0xFFFDE68A);

      default:
        return const Color(0xFFE2E8F0);
    }
  }





  Widget _buildDivider() {
    return Divider(color: const Color(0xFFF1F5F9), height: 1, thickness: 1);
  }

  // Update status
  Future<void> updateStatus() async {
    setState(() {
      isLoading = true;
    });
    final headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
    };
    final updateStatusUrl = Uri.parse(
        '$BaseURL/support/bank_api/update_status/application');

    final body = jsonEncode({
      'uuid': applicationUuid,
      'status': int.parse(selectedStatus)
    });

    try {
      final response = await http.post(updateStatusUrl,
        body: body,
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["success"] == true) {
          final data = json["data"];
          print(data);
          setState(() {

          });
        }
      }
      else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Balance check failed: ${response.statusCode}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    catch (e) {
      print("Error: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Something went wrong. Please check your network connection."),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),);
    }
    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }




  // Update mdm info
  Future<void> updateMdmInfo() async {
    if (token == null || token!.isEmpty) {
      _showError('Token not found');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      '$BaseURL/support/bank_api/update_info/application',
    );

    // MDM JSON
    final Map<String, dynamic> mdmInfo = {
      'customer_id': customerId ?? '',
      'mdm_name': mdmNameController.text.trim(),
      'imei_1': imei1Controller.text.trim(),
      'imei_2': imei2Controller.text.trim(),
    };

    debugPrint('========== MDM INFO ==========');
    debugPrint(mdmInfo.toString());
    debugPrint('==============================');

    final body = jsonEncode({
      'id': customerId,
      'info_name': 'mdm_info',
      'info_value': jsonEncode(mdmInfo),
    });

    debugPrint('========== MDM REQUEST ==========');
    debugPrint(body);
    debugPrint('=================================');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      debugPrint(
        'MDM RESPONSE STATUS: ${response.statusCode}',
      );

      debugPrint(
        'MDM RESPONSE BODY: ${response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["success"] == true) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'MDM information updated successfully',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          _showError(
            responseData['message'] ??
                'Failed to update MDM information',
          );
        }
      } else {
        _showError(
          'MDM update failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('MDM UPDATE ERROR: $e');

      _showError(
        'Something went wrong. Please check your network connection.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }





// Update emi info

  Future<void> updateEmiInfo() async {
    if (token == null || token!.isEmpty) {
      _showError('Token not found');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      '$BaseURL/support/bank_api/update_info/application',
    );

    final emiInfo = editableEmiList.map((emi) {
      return {
        'scheduleNumber': emi['scheduleNumber'] ?? '',
        'scheduleDate': emi['scheduleDate'] ?? '',
        'emiAmount': emi['emiAmount'] ?? '',
        'status': emi['status'] ?? 'unpaid',
      };
    }).toList();

    // Check exactly what will be sent
    debugPrint('========== UPDATED EMI INFO ==========');

    for (final emi in emiInfo) {
      debugPrint(
        'EMI ${emi['scheduleNumber']} '
            '=> ${emi['status']}',
      );
    }

    debugPrint('======================================');

    final body = jsonEncode({
      'id': customerId,
      'info_name': 'emi_info',
      'info_value': jsonEncode(emiInfo),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      debugPrint('EMI UPDATE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["success"] == true) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'EMI information updated successfully',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          _showError(
            json['message'] ?? 'Failed to update EMI information',
          );
        }
      } else {
        _showError(
          'EMI update failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('EMI UPDATE ERROR: $e');
      _showError(
        'Something went wrong. Please check your network connection.',
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
