import 'package:flutter/material.dart';

import 'package:erin_support_internal/screens/dashboard.dart';
import 'package:erin_support_internal/screens/balance.dart';
import 'package:erin_support_internal/screens/fix.dart';

import 'package:erin_support_internal/widgets/bottomBar.dart';
import 'package:erin_support_internal/widgets/sideBar.dart';

import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/screens/auth/login.dart';

// Symphony
import 'package:erin_support_internal/screens/drawer/symphony/symphony_grace_period.dart';
import 'package:erin_support_internal/screens/drawer/symphony/symphony_payment.dart';
import 'package:erin_support_internal/screens/drawer/symphony/symphony_unlock.dart';
import 'package:erin_support_internal/screens/drawer/symphony/symphony_lock.dart';
import 'package:erin_support_internal/screens/drawer/symphony/symphony_sale_replace.dart';

// Walton
import 'package:erin_support_internal/screens/drawer/walton/walton_emi_payment.dart';
import 'package:erin_support_internal/screens/drawer/walton/walton_lock.dart';
import 'package:erin_support_internal/screens/drawer/walton/walton_unlock.dart';
import 'package:erin_support_internal/screens/drawer/walton/walton_sale_replace.dart';
import 'package:erin_support_internal/screens/drawer/walton/walton_grace_period.dart';
import 'package:erin_support_internal/screens/drawer/walton/payprotect.dart';

// ZTE
import 'package:erin_support_internal/screens/drawer/zte/unlock_phone.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  String? _brandName;

  final List<Widget> _pages = [
    const Dashboard(),
    const Balance(),
    const Fix(),

    // Walton
    const WaltonEmiPayment(),
    const WaltonGracePeriod(),
    const WaltonLock(),
    const WaltonUnlock(),
    const WaltonSaleReplace(),
    const SaleRecordScreen(),

    // Symphony
    const SymphonyEmiPayment(),
    const SymphonyGracePeriod(),
    const SymphonyLock(),
    const SymphonyUnlock(),
    const SymphonySaleReplace(),

    // ZTE
    const ZTEUnlock(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBrand();
  }

  Future<void> _loadBrand() async {
    try {
      final user = await Save.getUser();

      if (!mounted) return;

      setState(() {
        _brandName = user?.data?.productSelectionInfo?.brand?.name;
      });

      debugPrint('====================================');
      debugPrint('Brand Name: $_brandName');
      debugPrint('====================================');
    } catch (e) {
      debugPrint('Failed to load brand: $e');
    }
  }

  void _onItemSelected(int index) {
    if (index < 0 || index >= _pages.length) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    await Save.clearUser();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  backgroundColor: const Color(0xFF155dfc),
                  foregroundColor: Colors.white,
                  title: const Text(
                    'eRin Support',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Color(0xFF0F172A),
                          size: 20,
                        ),
                      ),
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Color(0xFFD50000),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'Do you want to logout?',
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
                                  _logout();
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : null,

          drawer: isMobile
              ? Drawer(
                  width: 280,
                  child: SideBar(
                    currentIndex: _currentIndex,
                    brandName: _brandName,
                    onItemSelected: (index) {
                      _onItemSelected(index);
                      Navigator.pop(context);
                    },
                  ),
                )
              : null,

          body: Row(
            children: [
              // Desktop sidebar
              if (!isMobile)
                SideBar(
                  currentIndex: _currentIndex,
                  brandName: _brandName,
                  onItemSelected: _onItemSelected,
                ),

              // Main content
              Expanded(child: _pages[_currentIndex]),
            ],
          ),

          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onItemSelected,
          ),
        );
      },
    );
  }
}
