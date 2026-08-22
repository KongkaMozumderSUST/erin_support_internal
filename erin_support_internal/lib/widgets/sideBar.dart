import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const SideBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  static const Color navy = Color(0xFF000080);

  bool waltonExpanded = false;
  bool symphonyExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: navy,
      child: Column(
        children: [
          // HEADER
          const SizedBox(height: 50),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.apps,
                    color: navy,
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  'Erin Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: Colors.white24,
            height: 1,
          ),

          // MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                // Dashboard
                _menuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  index: 0,
                ),

                // Balance
                _menuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Balance',
                  index: 1,
                ),

                // Fix
                _menuItem(
                  icon: Icons.build_outlined,
                  title: 'Fix',
                  index: 2,
                ),

                const SizedBox(height: 10),


                // WALTON

                _brandHeader(
                  title: 'Walton',
                  icon: Icons.phone_android,
                  expanded: waltonExpanded,
                  onTap: () {
                    setState(() {
                      waltonExpanded = !waltonExpanded;
                    });
                  },
                ),

                if (waltonExpanded)
                  _brandChildren([
                    _subMenuItem(
                      icon: Icons.payments_outlined,
                      title: 'EMI Payment',
                      index: 3,
                    ),
                    _subMenuItem(
                      icon: Icons.access_time,
                      title: 'Allow Grace Period',
                      index: 4,
                    ),
                    _subMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Lock',
                      index: 5,
                    ),
                    _subMenuItem(
                      icon: Icons.lock_open_outlined,
                      title: 'Unlock',
                      index: 6,
                    ),
                    _subMenuItem(
                      icon: Icons.swap_horiz,
                      title: 'Sale Replace',
                      index: 7,
                    ),
                  ]),

                const SizedBox(height: 6),

                // SYMPHONY

                _brandHeader(
                  title: 'Symphony',
                  icon: Icons.phone_android,
                  expanded: symphonyExpanded,
                  onTap: () {
                    setState(() {
                      symphonyExpanded = !symphonyExpanded;
                    });
                  },
                ),

                if (symphonyExpanded)
                  _brandChildren([
                    _subMenuItem(
                      icon: Icons.payments_outlined,
                      title: 'EMI Payment',
                      index: 8,
                    ),
                    _subMenuItem(
                      icon: Icons.access_time,
                      title: 'Allow Grace Period',
                      index: 9,
                    ),
                    _subMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Lock',
                      index: 10,
                    ),
                    _subMenuItem(
                      icon: Icons.lock_open_outlined,
                      title: 'Unlock',
                      index: 11,
                    ),
                    _subMenuItem(
                      icon: Icons.swap_horiz,
                      title: 'Sale Replace',
                      index: 12,
                    ),
                  ]),
              ],
            ),
          ),

          // USER

          const Divider(
            color: Colors.white24,
          ),

          const Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: navy,
                  ),
                ),

                SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Administrator',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // BRAND HEADER


  Widget _brandHeader({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return Material(
      color: expanded
          ? Colors.white.withOpacity(0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(
                  milliseconds: 200,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BRAND CHILDREN

  Widget _brandChildren(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(
        left: 15,
        top: 4,
        bottom: 5,
      ),
      padding: const EdgeInsets.only(
        left: 8,
      ),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.white24,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }


  // MAIN MENU

  Widget _menuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = widget.currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? Colors.white
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            widget.onItemSelected(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: selected
                      ? navy
                      : Colors.white70,
                ),

                const SizedBox(width: 13),

                Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? navy
                        : Colors.white70,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // SUB MENU

  Widget _subMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = widget.currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: selected
            ? Colors.white
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            widget.onItemSelected(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? navy
                      : Colors.white60,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? navy
                          : Colors.white70,
                      fontSize: 13.5,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}