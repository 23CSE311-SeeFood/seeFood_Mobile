import 'package:flutter/material.dart';
import 'package:seefood/components/itemPage/item_card.dart';
import 'package:seefood/components/itemPage/plate_bar.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/data/canteen_api/canteen_api.dart';
import 'package:seefood/data/canteen_api/canteen_item.dart';
import 'package:seefood/themes/app_colors.dart';
import 'package:seefood/components/itemPage/simple_search_bar.dart';
import 'package:seefood/pages/prebook_checkout_page.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.canteen, this.prebookSlotStart});

  final Canteen canteen;
  final DateTime? prebookSlotStart;

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SimpleSearchBar()),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
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
                  padding: const EdgeInsets.only(bottom: 90),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return ItemCard(
                      item: items[index],
                      canteenId: widget.canteen.id,
                    );
                  },
                );
              },
            ),
          ),
          Positioned.fill(
            child: PlateBar(
              onCheckout: widget.prebookSlotStart == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PrebookCheckoutPage(
                            canteen: widget.canteen,
                            slotStart: widget.prebookSlotStart!,
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}
