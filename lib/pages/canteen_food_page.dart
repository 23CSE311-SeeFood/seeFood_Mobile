import 'package:flutter/material.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/themes/app_colors.dart';

class CanteenFoodPage extends StatelessWidget {
  const CanteenFoodPage({super.key, required this.canteen});

  final Canteen canteen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(canteen.name),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Food items will show here.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
