import 'package:flutter/material.dart';
import 'package:seefood/components/homePage/appBar.dart';
import 'package:seefood/components/common/navBar.dart';
import 'package:seefood/themes/app_colors.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: const HomeAppBar(),
      body: const Center(
        child: Text("Home Content"),
      ),
      bottomNavigationBar: BottomPillNav(
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
