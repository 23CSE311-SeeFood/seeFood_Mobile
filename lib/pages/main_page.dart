import 'package:flutter/material.dart';
import 'package:seefood/components/common/nav_bar.dart';
import 'package:seefood/components/homePage/app_bar.dart';
import 'package:seefood/pages/home_page.dart';
import 'package:seefood/pages/orders_page.dart';
import 'package:seefood/pages/profile_page.dart';
import 'package:seefood/themes/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
  }

  void _handleLogout() {
    setState(() {
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: _index == 3
          ? AppBar(
              backgroundColor: AppColors.foreground,
              foregroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text('Profile'),
            )
          : _index == 2
              ? AppBar(
                  backgroundColor: AppColors.foreground,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: const Text('Orders'),
                )
              : const HomeAppBar(),
      body: IndexedStack(
        index: _index == 3
            ? 2
            : _index == 2
                ? 1
                : 0,
        children: [
          const Homepage(),
          const OrdersPage(),
          ProfilePage(onLogout: _handleLogout),
        ],
      ),
      bottomNavigationBar: BottomPillNav(
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
