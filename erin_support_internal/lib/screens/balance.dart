import 'package:flutter/material.dart';
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/screens/auth/login.dart';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';
import 'package:erin_support_internal/models/EmiPayment.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Balance extends StatefulWidget {
  const Balance({super.key});

  @override
  State<Balance> createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  late Future<ApiResponse?> _userFuture;
  bool isLoading = false;

  //==========================
  String? token ;
  String? accountNumber;
  String? loanaccNumber;
  String? balance;
  String? accountName;
  String? customerNumber;

  //==========================
  String? receivableAmount;
  String? todayTurnOverDr;
  String? todayTurnOverCr;
  String? currentBalance;
  String? availBal;


  //===============================
   List<EmiPayment> emiPayments = [];

  //=============================
  String? schedule_no;
  String? schedule_due_date;
  String? emi_amt;
  String? tot_settled;
  String? tot_over_due;
  String? tot_not_due;

  @override
  void initState() {
    super.initState();
    _userFuture = Save.getUser();
    _initialize();
  }
  Future<void> _refresh() async {
    await checkBalance();
  }

  Future<void> _initialize() async {
    final user = await Save.getUser();

    if (mounted) {
      setState(() {
        token = user?.token;
        accountNumber = user?.data?.loanCreationDetails?.emicollectionAc;
        loanaccNumber = user?.data?.loanCreationDetails?.loanaccno;
      });
    }
    await checkBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<ApiResponse?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data?.data == null) {
            return const Center(child: Text("No user data found."));
          }


          return  RefreshIndicator(
            onRefresh: _refresh,
            child:   ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // Balance
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildPreferenceTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: "Current Balance",
                        subtitle:
                        "${balance}",
                        onTap: () {
                        },
                      ),
                      _buildDivider(),
                      _buildPreferenceTile(
                        icon: Icons.person_outline,
                        title: "Customer Name",
                        subtitle: "${accountName}",
                        onTap: () {

                        },
                      ),
                      _buildDivider(),
                      _buildPreferenceTile(
                        icon: Icons.phone_android_outlined,
                        title: "Customer Number",
                        subtitle: "${customerNumber}",
                        onTap: () {

                        },
                      ),
                      _buildDivider(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Balance Status
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildPreferenceTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: "Receivable Amount",
                        subtitle:
                        "${receivableAmount}",
                        onTap: () {
                        },
                      ),
                      _buildDivider(),
                      _buildPreferenceTile(
                        icon: Icons.person_outline,
                        title: "Today Turnover Credit",
                        subtitle: "${todayTurnOverCr}",
                        onTap: () {

                        },
                      ),
                      _buildDivider(),
                      _buildPreferenceTile(
                        icon: Icons.phone_android_outlined,
                        title: "Today Turnover Debit",
                        subtitle: "${todayTurnOverDr}",
                        onTap: () {

                        },
                      ),
                      _buildDivider(),
                      _buildPreferenceTile(
                        icon: Icons.phone_android_outlined,
                        title: "Current Balance",
                        subtitle: "${currentBalance}",
                        onTap: () {

                        },
                      ),
                      _buildDivider(),
                      _buildPreferenceTile(
                        icon: Icons.phone_android_outlined,
                        title: "Available Balance",
                        subtitle: "${availBal}",
                        onTap: () {

                        },
                      ),
                      _buildDivider(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),


                // EMI Schedule
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: emiPayments.length,
                    separatorBuilder: (_, __) => _buildDivider(),
                    itemBuilder: (context, index) {
                      final emi = emiPayments[index];
                      final now = DateTime.now();

                      final isPaid = emi.totSettled >= emi.emiAmt;
                      final isUpcoming = emi.scheduleDueDate.isAfter(now);

                      IconData icon;
                      Color iconColor;

                      if (isPaid) {
                        icon = Icons.check_circle;
                        iconColor = Colors.green;
                      } else if (isUpcoming) {
                        icon = Icons.schedule;
                        iconColor = Colors.orange;
                      } else {
                        icon = Icons.warning_amber_rounded;
                        iconColor = Colors.red;
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: iconColor.withOpacity(.1),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            color: iconColor,
                          ),
                        ),
                        title: Text(
                          "EMI #${emi.scheduleNo}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Due Date: ${emi.scheduleDueDate.day}/${emi.scheduleDueDate.month}/${emi.scheduleDueDate.year}",
                            ),
                            Text("Amount: ৳${emi.emiAmt.toStringAsFixed(2)}"),
                            Text("Settled: ৳${emi.totSettled.toStringAsFixed(2)}"),
                            Text(
                              "Over Due: ৳${emi.totOverDue.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          icon,
                          color: iconColor,
                          size: 28,
                        ),
                      );
                    },
                  ),
                ),

                // Version Footer
                const Center(
                  child: Text(
                    "Erin Support v1.0.0",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }



  @override




  Future<void> checkBalance() async {
    setState(() {
      isLoading = true;
    });

    final balanceUrl = Uri.parse('$BaseURL/support/bank_api/account_balance');
    final balanceStatusUrl = Uri.parse('$BaseURL/support/bank_api/account_balance_status');
    final loanAccUrl = Uri.parse('$BaseURL/support/bank_api/emi_payments_by_account?account_number=$loanaccNumber');

    final bodyBalance = jsonEncode({
      'account_number': accountNumber
    });
    final bodyBalanceStatus = jsonEncode({
      'account_number': accountNumber
    });
    final bodyloanAcc = jsonEncode({
      'account_number': loanaccNumber
    });

    final headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
    };

    try {
      final resBalance = await http.post(
        balanceUrl,
        body: bodyBalance,
        headers: headers,
      );
      if (resBalance.statusCode == 200) {
        final json = jsonDecode(resBalance.body);

        if (json["status"] == true) {
          final data = json["data"];

          setState(() {
            balance = data["balance"];
            accountName = data["customername"];
            customerNumber = data["customernumber"];
            accountNumber = data["accountnumber"];
          });
        }
      }
      else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Balance check failed: ${resBalance.statusCode}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      final resBalanceStatus = await http.post(
        balanceStatusUrl,
        body: bodyBalanceStatus,
        headers: headers,
      );
      if (resBalanceStatus.statusCode == 200) {
        final json = jsonDecode(resBalanceStatus.body);

        if (json["status"] == true) {
          final data = json["data"];

          setState(() {
            todayTurnOverDr = data["todayTurnOverDr"];
            todayTurnOverCr = data["todayTurnOverCr"];
            availBal = data["availBal"];
            receivableAmount = data["receivableAmount"];
            currentBalance = data["currentBalance"];
          });
        }
      }
      else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Balance check failed: ${resBalance.statusCode}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      final resLoanBalanceStatus = await http.post(
        loanAccUrl,
        body: bodyloanAcc,
        headers: headers,
      );

      if (resLoanBalanceStatus.statusCode == 200) {
        final json = jsonDecode(resLoanBalanceStatus.body);

        if (json["success"] == true) {
          setState(() {
            emiPayments = (json["data"] as List)
                .map((item) => EmiPayment.fromJson(item))
                .toList();
          });
        }
      }
      else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Balance check failed: ${resBalance.statusCode}"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      print("Status Code: ${resBalance.statusCode}");
      print("Response: ${resBalance.body}");

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





  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDivider() {
    return Divider(color: const Color(0xFFF1F5F9), height: 1, thickness: 1);
  }
}



