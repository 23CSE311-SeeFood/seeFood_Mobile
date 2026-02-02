import 'package:flutter/material.dart';
import 'package:seefood/components/homePage/appBar.dart';
import 'package:seefood/themes/app_colors.dart';
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppColors.grayground,
      appBar: HomeAppBar(),
      body: const Column(
        children: [
          Spacer()
        ],
      ),

    );
  }
}