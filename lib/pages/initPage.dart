import 'package:flutter/material.dart';
import 'package:seefood/components/initPage/aggrementText.dart';
import 'package:seefood/components/initPage/getStarted.dart';
import 'package:seefood/components/initPage/appBar.dart';
import '../themes/app_colors.dart';

class Initpage extends StatelessWidget {
  const Initpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const InitAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: const [
              Spacer(),  
              aggrementText(),
              SizedBox(height: 12,),      
              GetStarted(),     
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
