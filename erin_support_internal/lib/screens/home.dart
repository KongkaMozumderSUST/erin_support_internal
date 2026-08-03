import 'package:flutter/material.dart';
import 'package:erin_support_internal/widgets/bottomBar.dart';
import 'package:erin_support_internal/screens/balance.dart';
import 'package:erin_support_internal/screens/dashboard.dart';
import 'package:erin_support_internal/screens/fix.dart';



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


  @override
  class _HomeState extends State<Home> {

  int _currentIndex = 0;
  final List<Widget> _pages = [
  const Dashboard(), //0
  const Balance(), // 1
     const Fix(), //2
  ];

  @override
  Widget build(BuildContext context) {
  return Scaffold(

  body: _pages[_currentIndex],

  bottomNavigationBar: CustomBottomNavBar(
  currentIndex: _currentIndex,
  onTap: (index) {
  setState(() {
  _currentIndex = index;
  });
  },
  ),
  );
  }
  }

