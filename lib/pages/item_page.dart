import 'package:flutter/material.dart';
import 'package:seefood/components/itemPage/itemCard.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/data/canteen_api/canteen_api.dart';
import 'package:seefood/data/canteen_api/canteen_item.dart';
import 'package:seefood/themes/app_colors.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.canteen});

  final Canteen canteen;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
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
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ItemCard(item: items[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
