import 'package:flutter/material.dart';
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/screens/auth/login.dart';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:erin_support_internal/models/CustomerModel.dart';
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: false,
        title: const Text(
          "Check Balance",
          style: TextStyle(
            color:  const Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Color(0xFF0F172A), size: 20),
            ),
            onPressed: () async {
              await Save.clearUser();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },

          ),
          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Available Balance",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      balance ?? "৳ 0.00",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text("Account Name"),
                    subtitle: Text(accountName ?? "-"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text("Customer Number"),
                    subtitle: Text(customerNumber?? "-"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text("Account Number"),
                    subtitle: Text(accountNumber ?? "-"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: const Text("Loan Account"),
                    subtitle: Text(loanaccNumber ?? "-"),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text("Account Name"),
                    subtitle: Text(accountName ?? "-"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text("Customer Number"),
                    subtitle: Text(customerNumber?? "-"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text("Account Number"),
                    subtitle: Text(accountNumber ?? "-"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: const Text("Loan Account"),
                    subtitle: Text(loanaccNumber ?? "-"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : checkBalance,
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.refresh),
                label: Text(
                  isLoading ? "Checking..." : "Refresh Balance",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Pull down to refresh",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
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
      final resLoanBalanceStatus = await http.post(
        loanAccUrl,
        body: bodyloanAcc,
        headers: headers,
      );
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

}

