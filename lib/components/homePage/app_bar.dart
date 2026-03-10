import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.grayground,
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
                color: AppColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "by amrita vishwa vidyapeetham",
              style: TextStyle(
                color: Color.fromARGB(223, 0, 2, 0),
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

class BackHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackHomeAppBar({
    super.key,
    required this.title,
    this.subtitle = "by amrita vishwa vidyapeetham",
    this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.grayground,
      foregroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: 100,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                color: AppColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color.fromARGB(223, 0, 2, 0),
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
