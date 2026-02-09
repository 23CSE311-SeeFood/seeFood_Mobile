import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class InitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const InitAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      toolbarHeight: 100,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "SEEFOOD",
              style: TextStyle(
                fontSize: 30,
                color: AppColors.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "by amrita vishwa vidyapeetham",
              style: TextStyle(
                color: Color.fromARGB(204, 255, 255, 255),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
