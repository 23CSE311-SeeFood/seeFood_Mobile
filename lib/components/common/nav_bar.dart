import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class BottomPillNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomPillNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Design system padding
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Container(
        height: 80, // Slightly reduced height to keep pill shape tight
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100), // Fully rounded main pill
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_rounded, "Home", 0),
            _navItem(Icons.search_rounded, "Search", 1),
            _navItem(Icons.receipt_long_rounded, "Orders", 2),
            _navItem(Icons.person_rounded, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        // Highlight wraps both Icon and Text
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100), // Full rounded corners
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.grey,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
