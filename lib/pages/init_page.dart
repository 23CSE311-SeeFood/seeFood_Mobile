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
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: FractionalTranslation(
                            translation: const Offset(0.25, 0),
                            child: SizedBox(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              child: Image.asset(
                                'assets/images/init.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
                  AgreementText(),
                  SizedBox(height: 12),
                  GetStarted(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
