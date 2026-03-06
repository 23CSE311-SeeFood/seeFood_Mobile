import 'package:flutter/material.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/pages/item_page.dart';
import 'package:seefood/prebook/prebook_api.dart';
import 'package:seefood/prebook/prebook_models.dart';
import 'package:seefood/themes/app_colors.dart';

class PrebookSlotsPage extends StatefulWidget {
  const PrebookSlotsPage({super.key, required this.canteen});

  final Canteen canteen;

  @override
  State<PrebookSlotsPage> createState() => _PrebookSlotsPageState();
}

class _PrebookSlotsPageState extends State<PrebookSlotsPage> {
  late final PrebookApi _prebookApi;
  late Future<PrebookSlotResponse> _future;

  @override
  void initState() {
    super.initState();
    _prebookApi = PrebookApi();
    final today = DateTime.now();
    final date = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    _future = _prebookApi.fetchSlots(
      canteenId: widget.canteen.id,
      date: date,
    );
  }

  @override
  void dispose() {
    _prebookApi.close();
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
        title: const Text('Select Slot'),
      ),
      body: FutureBuilder<PrebookSlotResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data;
          if (data == null || data.slots.isEmpty) {
            return const Center(child: Text('No slots available')); 
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: data.slots.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final slot = data.slots[index];
              return _SlotCard(
                slot: slot,
                onSelect: slot.remaining > 0
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ItemPage(
                              canteen: widget.canteen,
                              prebookSlotStart: slot.start,
                            ),
                          ),
                        );
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot, this.onSelect});

  final PrebookSlot slot;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final start = TimeOfDay.fromDateTime(slot.start.toLocal()).format(context);
    final end = TimeOfDay.fromDateTime(slot.end.toLocal()).format(context);
    final remaining = slot.remaining;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$start - $end',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                remaining > 0
                    ? '$remaining slots left'
                    : 'Full',
                style: TextStyle(
                  fontSize: 12,
                  color: remaining > 0 ? Colors.black54 : Colors.red,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onSelect,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  remaining > 0 ? AppColors.primary : Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
