import 'package:flutter/material.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/data/canteen_api/canteen_api.dart';
import 'package:seefood/data/canteen_api/canteen_item.dart';
import 'package:seefood/themes/app_colors.dart';

class CanteenFoodPage extends StatefulWidget {
  const CanteenFoodPage({super.key, required this.canteen});

  final Canteen canteen;

  @override
  State<CanteenFoodPage> createState() => _CanteenFoodPageState();
}

class _CanteenFoodPageState extends State<CanteenFoodPage> {
  late final CanteenApi _api;
  late final Future<List<CanteenItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _api = CanteenApi();
    _itemsFuture = _api.fetchItems(canteenId: widget.canteen.id);
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(widget.canteen.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<CanteenItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('No items found'));
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.foreground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.description != null &&
                                item.description!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  item.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (item.price != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '₹${item.price}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
