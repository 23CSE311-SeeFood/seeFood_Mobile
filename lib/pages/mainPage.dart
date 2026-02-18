import 'package:flutter/material.dart';
import 'package:seefood/components/common/navBar.dart';
import 'package:seefood/components/homePage/appBar.dart';
import 'package:seefood/pages/homePage.dart';
import 'package:seefood/pages/ordersPage.dart';
import 'package:seefood/pages/profilePage.dart';
import 'package:seefood/themes/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

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
