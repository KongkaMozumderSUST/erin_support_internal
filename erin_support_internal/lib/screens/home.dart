 import 'package:flutter/material.dart';
  import 'package:erin_support_internal/screens/dashboard.dart';
  import 'package:erin_support_internal/screens/balance.dart';
  import 'package:erin_support_internal/screens/fix.dart';
  import 'package:erin_support_internal/widgets/bottomBar.dart';
  import 'package:erin_support_internal/widgets/sideBar.dart';
  import 'package:erin_support_internal/others/save.dart';
  import 'package:erin_support_internal/screens/auth/login.dart';
  import 'package:erin_support_internal/screens/drawer/symphony/symphony_grace_period.dart';
 import 'package:erin_support_internal/screens/drawer/symphony/symphony_payment.dart';
 import 'package:erin_support_internal/screens/drawer/symphony/symphony_unlock.dart';
 import 'package:erin_support_internal/screens/drawer/symphony/symphony_lock.dart';
 import 'package:erin_support_internal/screens/drawer/symphony/symphony_sale_replace.dart';
 import 'package:erin_support_internal/screens/drawer/walton/walton_emi_payment.dart';
 import 'package:erin_support_internal/screens/drawer/walton/walton_lock.dart';
 import 'package:erin_support_internal/screens/drawer/walton/walton_unlock.dart';
 import 'package:erin_support_internal/screens/drawer/walton/walton_sale_replace.dart';
 import 'package:erin_support_internal/screens/drawer/walton/walton_grace_period.dart';

 class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
  }

  class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
  const Dashboard(),
  const Balance(),
  const Fix(),
    //walton
  const WaltonEmiPayment(),
  const WaltonGracePeriod(),
  const WaltonLock(),
  const WaltonUnlock(),
  const WaltonSaleReplace(),
//symphony
  const SymphonyEmiPayment(),
  const SymphonyGracePeriod(),
  const SymphonyLock(),
  const SymphonyUnlock(),
  const SymphonySaleReplace(),
  ];

  @override
  Widget build(BuildContext context) {
  return LayoutBuilder(
  builder: (context, constraints) {
  final bool isMobile = constraints.maxWidth < 700;

  return Scaffold(
  // MOBILE APP BAR
  appBar: isMobile ? AppBar(
  backgroundColor: const Color(0xFF000080),
  foregroundColor: Colors.white,
  title: const Text(
  'Erin Support',
  style: TextStyle(
  fontWeight: FontWeight.bold,
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
  )
      : null,

  // MOBILE DRAWER


  drawer: isMobile? Drawer(
  width: 280,
  child: SideBar(
  currentIndex: _currentIndex,
  onItemSelected: (index) {
  setState(() {
  _currentIndex = index;
  });
  Navigator.pop(context);
  },
  ),
  )
      : null,


  // BODY

  body: Row(
    children: [
  // Desktop sidebar only
  if (!isMobile)
    SideBar(
  currentIndex: _currentIndex,
  onItemSelected: (index) {
  setState(() {
  _currentIndex = index;
  });
  },
  ),

  // Main content
  Expanded(
  child: _pages[_currentIndex],
  ),
  ],
  ),


  // BOTTOM BAR

  bottomNavigationBar: CustomBottomNavBar(
  currentIndex: _currentIndex,
  onTap: (index) {
  setState(() {
  _currentIndex = index;
  });
  },
  ),
  );
  },
  );
  }
  }

