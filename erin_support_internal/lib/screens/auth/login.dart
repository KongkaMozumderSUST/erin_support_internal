import 'dart:convert';
import 'package:erin_support_internal/constants/api_constants.dart';
import 'package:erin_support_internal/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erin_support_internal/models/CustomerModel.dart';
import 'package:erin_support_internal/others/save.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final TextEditingController customerIdController = TextEditingController();
  final TextEditingController appVersionController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    customerIdController.dispose();
    appVersionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo / Icon Header Container
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Subtitle
                const Text(
                  "Erin Support Internal",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter customer ID to load internal profile data",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // Form Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: customerIdController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: "Customer ID",
                          hintText: "Enter ID number",
                          prefixIcon: const Icon(Icons.badge_outlined, color: const Color(0xFF1A237E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: const Color(0xFF1A237E), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TextField(
                      //   controller: appVersionController,
                      //   keyboardType: TextInputType.number,
                      //   style: const TextStyle(fontWeight: FontWeight.w500),
                      //   decoration: InputDecoration(
                      //     labelText: "App Version",
                      //     hintText: "Enter app version",
                      //     prefixIcon: const Icon(Icons.badge_outlined, color: const Color(0xFF1A237E)),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       borderSide: BorderSide(color: Colors.grey.shade300),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       borderSide: const BorderSide(color: const Color(0xFF1A237E), width: 2),
                      //     ),
                      //   ),
                      // ),
                     //764388 const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000080),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> login() async {
    if (customerIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Customer ID is required"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$BaseURL/auth/support_login');

    final body = jsonEncode({
      'customer_id': customerIdController.text.trim(),
      'app_version': 2,
    });

    final headers = {
      'Content-Type': 'application/json',
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
        final jsonData = jsonDecode(res.body);

        ApiResponse apiResponse = ApiResponse.fromMap(jsonData);

        if (apiResponse.success == true) {
          await Save.saveUser(apiResponse);

          print("Login Success & Data Saved");

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiResponse.message ?? "Login failed"),
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: ${res.statusCode}"),
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