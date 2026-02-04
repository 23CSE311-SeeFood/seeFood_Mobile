import 'package:flutter/material.dart';
import 'package:seefood/themes/app_colors.dart';

class CanteenCard extends StatefulWidget {
  const CanteenCard({super.key});

  @override
  State<CanteenCard> createState() => _CanteenCardState();
}

class _CanteenCardState extends State<CanteenCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child:DecoratedBox(
  
      decoration: BoxDecoration(
        color: AppColors.foreground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
         child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:AppColors.primary,
                    borderRadius: BorderRadius.circular(25)
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Canteen Name",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Soopnam Canteen",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                         width: 80,
                         height: 35,
                         decoration: BoxDecoration(
                           color: Colors.grey.shade300,
                           borderRadius: BorderRadius.circular(20),
                         ),
                      )
                    ],
                  ),
                ),
              )
            ],
         )
      ),
    )
    );
  }
}
