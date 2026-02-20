import 'package:flutter/material.dart';
import 'package:seefood/components/initPage/agreement_text.dart';
import 'package:seefood/components/initPage/get_started.dart';
import 'package:seefood/components/initPage/app_bar.dart';
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
              AgreementText(),
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
