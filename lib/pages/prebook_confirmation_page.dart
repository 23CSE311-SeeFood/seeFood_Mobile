import 'package:flutter/material.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/pages/main_page.dart';
import 'package:seefood/prebook/prebook_models.dart';
import 'package:seefood/themes/app_colors.dart';

class PrebookConfirmationPage extends StatelessWidget {
  const PrebookConfirmationPage({
    super.key,
    required this.canteen,
    required this.slotStart,
    required this.confirmation,
  });

  final Canteen canteen;
  final DateTime slotStart;
  final PrebookVerifyResponse confirmation;

  @override
  Widget build(BuildContext context) {
    final slotTime = TimeOfDay.fromDateTime(slotStart.toLocal()).format(context);
    final order = confirmation.order;

    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Booking Confirmed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.foreground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canteen.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Slot: $slotTime',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Order: ${order.orderId}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Status: ${order.status}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Token: ${order.tokenNumber?.toString() ?? 'Pending'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainPage(initialIndex: 2),
                    ),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B5F06),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  'View Orders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
