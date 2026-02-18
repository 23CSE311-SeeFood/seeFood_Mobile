import 'package:flutter/material.dart';
import 'package:seefood/themes/app_colors.dart';
import 'package:seefood/pages/main_page.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
