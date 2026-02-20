import 'package:flutter/material.dart';
import 'package:seefood/themes/app_colors.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/pages/item_page.dart';

class CanteenCard extends StatelessWidget {
  final Canteen canteen;

  const CanteenCard({super.key, required this.canteen});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 320,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.foreground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemPage(canteen: canteen),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: canteen.imageUrl != null &&
                              canteen.imageUrl!.trim().isNotEmpty
                          ? Image.network(
                              canteen.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _FallbackImage(),
                            )
                          : _FallbackImage(),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Canteen Name",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                canteen.name,
                                style: const TextStyle(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: Icon(
          Icons.storefront,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }
}
