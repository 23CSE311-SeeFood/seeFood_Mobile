import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:seefood/themes/app_colors.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/pages/item_page.dart';

class CanteenCard extends StatelessWidget {
  final Canteen canteen;

  const CanteenCard({super.key, required this.canteen});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3, // 4:3 Ratio
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.foreground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItemPage(canteen: canteen),
              ),
            );
          },
          child: Column(
            children: [
              // Image Section - 70% of height
              Expanded(
                flex: 70, 
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    canteen.imageUrl != null &&
                            canteen.imageUrl!.trim().isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: canteen.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => _FallbackImage(),
                            errorWidget: (_, __, ___) => _FallbackImage(),
                          )
                        : _FallbackImage(),
                    
                    // Time Overlay (Bottom Right)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.foreground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_filled_rounded, 
                                size: 14, 
                                color: Colors.grey.shade800
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "30-40 mins",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section - 30% of height
              Expanded(
                flex: 30,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column: Label + Name
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Canteen name",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6), 
                            Text(
                              canteen.name,
                              style: const TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),

                      // Right Side: Ratings Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4.5",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      width: double.infinity,
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 40,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
