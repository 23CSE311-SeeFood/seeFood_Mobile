import 'package:flutter/material.dart';
import 'package:seefood/data/canteen_api/canteen_api.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/pages/prebook_slots_page.dart';
import 'package:seefood/themes/app_colors.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late final CanteenApi _api;
  late final Future<List<Canteen>> _canteensFuture;

  @override
  void initState() {
    super.initState();
    _api = CanteenApi();
    _canteensFuture = _api.fetchCanteens();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grayground,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Canteen>>(
          future: _canteensFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final canteens = snapshot.data ?? [];
            if (canteens.isEmpty) {
              return const Center(child: Text('No canteens available'));
            }

            return ListView.separated(
              itemCount: canteens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _CanteenBookingCard(canteen: canteens[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CanteenBookingCard extends StatelessWidget {
  const _CanteenBookingCard({required this.canteen});

  final Canteen canteen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.foreground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Canteen',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  canteen.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrebookSlotsPage(canteen: canteen),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Pick slot'),
          ),
        ],
      ),
    );
  }
}
