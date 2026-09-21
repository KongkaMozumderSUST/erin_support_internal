import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';
import 'package:erin_support_internal/models/EmiPayment.dart';

class Balance extends StatefulWidget {
  const Balance({super.key});

  @override
  State<Balance> createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  late Future<ApiResponse?> _userFuture;

  bool isLoading = true;

  // ==========================
  // User / Account
  // ==========================

  String? token;
  String? accountNumber;
  String? loanaccNumber;

  String? balance;
  String? accountName;
  String? customerNumber;

  // ==========================
  // Balance Status
  // ==========================

  String? receivableAmount;
  String? todayTurnOverDr;
  String? todayTurnOverCr;
  String? currentBalance;
  String? availBal;

  // ==========================
  // EMI
  // ==========================

  List<EmiPayment> emiPayments = [];

  @override
  void initState() {
    super.initState();

    _userFuture = Save.getUser();
    _initialize();
  }

  // ==========================
  // Initialize
  // ==========================

  Future<void> _initialize() async {
    final user = await Save.getUser();

    if (!mounted) return;

    setState(() {
      token = user?.token;
      accountNumber =
          user?.data?.loanCreationDetails?.emicollectionAc;
      loanaccNumber =
          user?.data?.loanCreationDetails?.loanaccno;
    });

    await checkBalance();
  }

  // ==========================
  // Refresh
  // ==========================

  Future<void> _refresh() async {
    await checkBalance();
  }

  // ==========================
  // Check Balance
  // ==========================

  Future<void> checkBalance() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final balanceUrl = Uri.parse(
      '$BaseURL/support/bank_api/account_balance',
    );

    final balanceStatusUrl = Uri.parse(
      '$BaseURL/support/bank_api/account_balance_status',
    );

    final loanAccUrl = Uri.parse(
      '$BaseURL/support/bank_api/emi_payments_by_account'
          '?account_number=$loanaccNumber',
    );

    final bodyBalance = jsonEncode({
      'account_number': accountNumber,
    });

    final bodyBalanceStatus = jsonEncode({
      'account_number': accountNumber,
    });

    final bodyloanAcc = jsonEncode({
      'account_number': loanaccNumber,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // ============================================================
      // 1. ACCOUNT BALANCE
      // ============================================================

      final resBalance = await http.post(
        balanceUrl,
        body: bodyBalance,
        headers: headers,
      );

      if (resBalance.statusCode == 200) {
        final json = jsonDecode(resBalance.body);

        if (json["status"] == true) {
          final data = json["data"];

          if (!mounted) return;

          setState(() {
            balance = data["balance"]?.toString();
            accountName = data["customername"]?.toString();
            customerNumber = data["customernumber"]?.toString();
            accountNumber = data["accountnumber"]?.toString();
          });
        }
      } else {
        _showError(
          "Balance check failed: ${resBalance.statusCode}",
        );
      }

      // ============================================================
      // 2. BALANCE STATUS
      // ============================================================

      final resBalanceStatus = await http.post(
        balanceStatusUrl,
        body: bodyBalanceStatus,
        headers: headers,
      );

      if (resBalanceStatus.statusCode == 200) {
        final json = jsonDecode(resBalanceStatus.body);

        if (json["status"] == true) {
          final data = json["data"];

          if (!mounted) return;

          setState(() {
            todayTurnOverDr =
                data["todayTurnOverDr"]?.toString();

            todayTurnOverCr =
                data["todayTurnOverCr"]?.toString();

            availBal =
                data["availBal"]?.toString();

            receivableAmount =
                data["receivableAmount"]?.toString();

            currentBalance =
                data["currentBalance"]?.toString();
          });
        }
      } else {
        _showError(
          "Balance status failed: "
              "${resBalanceStatus.statusCode}",
        );
      }



      final resLoanBalanceStatus = await http.post(
        loanAccUrl,
        body: bodyloanAcc,
        headers: headers,
      );

      if (resLoanBalanceStatus.statusCode == 200) {
        final json = jsonDecode(
          resLoanBalanceStatus.body,
        );

        if (json["success"] == true) {
          final List data = json["data"] ?? [];

          if (!mounted) return;

          setState(() {
            emiPayments = data
                .map(
                  (item) => EmiPayment.fromJson(item),
            )
                .toList();
          });
        }
      } else {
        _showError(
          "EMI check failed: "
              "${resLoanBalanceStatus.statusCode}",
        );
      }

      // Debug
      debugPrint(
        "Balance Status Code: ${resBalance.statusCode}",
      );

      debugPrint(
        "Balance Response: ${resBalance.body}",
      );
    } catch (e) {
      debugPrint("Error: $e");

      _showError(
        "Something went wrong. Please check your "
            "network connection.",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================
  // Error Snackbar
  // ==========================

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

  // ==========================
  // BUILD
  // ==========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Stack(
        children: [
          // ========================================================
          // MAIN CONTENT
          // ========================================================

          FutureBuilder<ApiResponse?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF059669),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data?.data == null) {
                return const Center(
                  child: Text(
                    "No user data found.",
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF059669),
                onRefresh: _refresh,

                child: ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.all(16),

                  children: [
                    // =================================================
                    // BALANCE
                    // =================================================

                    const Text(
                      "Balance",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),

                      child: Column(
                        children: [
                          _buildPreferenceTile(
                            icon: Icons
                                .account_balance_wallet_outlined,
                            title: "Current Balance",
                            subtitle:
                            balance ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),

                          _buildPreferenceTile(
                            icon: Icons.person_outline,
                            title: "Customer Name",
                            subtitle:
                            accountName ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),

                          _buildPreferenceTile(
                            icon:
                            Icons.phone_android_outlined,
                            title: "Customer Number",
                            subtitle:
                            customerNumber ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // BALANCE STATUS
                    // =================================================

                    const Text(
                      "Balance Status",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),

                      child: Column(
                        children: [
                          _buildPreferenceTile(
                            icon: Icons
                                .account_balance_wallet_outlined,
                            title: "Receivable Amount",
                            subtitle:
                            receivableAmount ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),

                          _buildPreferenceTile(
                            icon: Icons.trending_up_outlined,
                            title:
                            "Today Turnover Credit",
                            subtitle:
                            todayTurnOverCr ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),

                          _buildPreferenceTile(
                            icon: Icons.trending_down_outlined,
                            title:
                            "Today Turnover Debit",
                            subtitle:
                            todayTurnOverDr ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),

                          _buildPreferenceTile(
                            icon:
                            Icons.account_balance_wallet_outlined,
                            title: "Current Balance",
                            subtitle:
                            currentBalance ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),

                          _buildPreferenceTile(
                            icon:
                            Icons.account_balance_wallet_outlined,
                            title: "Available Balance",
                            subtitle:
                            availBal ?? "Loading...",
                            onTap: () {},
                          ),

                          _buildDivider(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // EMI SCHEDULE
                    // =================================================

                    const Text(
                      "EMI Schedule",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),

                      child: emiPayments.isEmpty
                          ? const Padding(
                        padding:
                        EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            "No EMI schedule found",
                            style: TextStyle(
                              color:
                              Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                          : ListView.separated(
                        shrinkWrap: true,

                        physics:
                        const NeverScrollableScrollPhysics(),

                        itemCount:
                        emiPayments.length,

                        separatorBuilder:
                            (_, __) =>
                            _buildDivider(),

                        itemBuilder:
                            (context, index) {
                          final emi =
                          emiPayments[index];

                          final now =
                          DateTime.now();

                          final isPaid =
                              emi.totSettled >=
                                  emi.emiAmt;

                          final isUpcoming =
                          emi.scheduleDueDate
                              .isAfter(now);

                          IconData statusIcon;

                          Color statusColor;

                          if (isPaid) {
                            statusIcon =
                                Icons.check_circle;

                            statusColor =
                                Colors.green;
                          } else if (isUpcoming) {
                            statusIcon =
                                Icons.schedule;

                            statusColor =
                                Colors.orange;
                          } else {
                            statusIcon =
                                Icons
                                    .warning_amber_rounded;

                            statusColor =
                                Colors.red;
                          }

                          return ListTile(
                            contentPadding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            leading:
                            CircleAvatar(
                              backgroundColor:
                              statusColor
                                  .withOpacity(.1),

                              child: Icon(
                                Icons
                                    .calendar_month_outlined,
                                color:
                                statusColor,
                              ),
                            ),

                            title: Text(
                              "EMI #${emi.scheduleNo}",
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  "Due Date: "
                                      "${emi.scheduleDueDate.day}/"
                                      "${emi.scheduleDueDate.month}/"
                                      "${emi.scheduleDueDate.year}",
                                ),

                                Text(
                                  "Amount: "
                                      "৳${emi.emiAmt.toStringAsFixed(2)}",
                                ),

                                Text(
                                  "Settled: "
                                      "৳${emi.totSettled.toStringAsFixed(2)}",
                                ),

                                Text(
                                  "Over Due: "
                                      "৳${emi.totOverDue.toStringAsFixed(2)}",

                                  style: TextStyle(
                                    color:
                                    statusColor,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            trailing: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ),

                    // =================================================
                    // FOOTER
                    // =================================================

                    const SizedBox(height: 30),

                    const Center(
                      child: Text(
                        "Erin Support v1.0.0",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),


          if (isLoading)
            if (isLoading)
              Container(
                color: const Color(0xFFF8FAFC).withOpacity(0.9),
                child: const Center(
                  child: CircularProgressIndicator(
                  ),
                ),
              ),
        ],
      ),
    );
  }


  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius:
        BorderRadius.circular(16),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          child: Row(
            children: [
              Container(
                padding:
                const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color:
                  const Color(0xFFF1F5F9),

                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: Icon(
                  icon,
                  color:
                  const Color(0xFF2563EB),
                  size: 20,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style:
                      const TextStyle(
                        fontSize: 12,
                        color:
                        Color(0xFF64748B),
                      ),

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DIVIDER
  // ================================================================

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFF1F5F9),
      height: 1,
      thickness: 1,
    );
  }
}