import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
class Initpage extends StatelessWidget {
  const Initpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("SEEFOOD",
        style: TextStyle(
          color: AppColors.foreground,
          fontWeight: FontWeight.bold
        ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const []
        ),
      ),
    );
  }
}
