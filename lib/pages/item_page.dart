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
        toolbarHeight: 200,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.canteen.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                           Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                       Text(
                        "30-40 mins",
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
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
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryPill(
                      label: "Veg",
                      color: Colors.green,
                      isSelected: true,
                      onTap: () {},
                    ),
                    _CategoryPill(
                      label: "Non-Veg",
                      color: Colors.red,
                      onTap: () {},
                    ),
                    _CategoryPill(
                        label: "Rice Items",
                        color: Colors.orange,
                        onTap: () {}),
                    _CategoryPill(
                        label: "Curry", color: Colors.blue, onTap: () {}),
                  ],
                ),
              ),
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

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : _getIconForLabel(label),
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    if (label == 'Veg') return Icons.eco;
    if (label == 'Non-Veg') return Icons.kebab_dining;
    if (label == 'Rice Items') return Icons.rice_bowl;
    if (label == 'Curry') return Icons.local_drink;
    return Icons.fastfood;
  }
}
