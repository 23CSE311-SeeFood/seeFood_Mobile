import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/orders/order_models.dart';
import 'package:seefood/orders/orders_api.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/themes/app_colors.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key, required this.orderId});

  final int orderId;

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  late final OrdersApi _ordersApi;
  late Future<OrderModel> _future;

  @override
  void initState() {
    super.initState();
    _ordersApi = OrdersApi();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authRepository = context.read<AuthRepository>();
    _future = _ordersApi.fetchOrderDetail(
      orderId: widget.orderId,
      token: authRepository.getToken(),
    );
  }

  @override
  void dispose() {
    _ordersApi.close();
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
        title: const Text('Order Queue'),
      ),
      body: FutureBuilder<OrderModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load order: ${snapshot.error}'),
            );
          }
          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderCard(order: order),
              const SizedBox(height: 16),
              Text(
                'Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              ...order.items.map((item) => _ItemStatusCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = order.status ?? 'CREATED';
    final token = order.tokenNumber?.toString() ?? '—';
    final canteenName = order.canteenName ??
        (order.canteenId != null ? 'Canteen #${order.canteenId}' : 'Canteen');

    return Container(
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
            canteenName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            order.orderId ?? 'Order #${order.id}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Pill(
                label: 'Token $token',
                color: const Color(0xFF2B5F06),
              ),
              const SizedBox(width: 10),
              _Pill(
                label: status,
                color: _statusColor(status),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemStatusCard extends StatelessWidget {
  const _ItemStatusCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final name = item.name ??
        item.canteenItemName ??
        (item.canteenItemId != null ? 'Item ${item.canteenItemId}' : 'Item');
    final status = item.status ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.foreground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name x${item.quantity}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.category != null || item.foodType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        if (item.category != null) item.category,
                        if (item.foodType != null) item.foodType,
                      ].whereType<String>().join(' • '),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
          _Pill(
            label: status,
            color: _statusColor(status),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'READY':
      return const Color(0xFF2B5F06);
    case 'DELIVERED':
    case 'COMPLETED':
      return Colors.green;
    case 'PAID':
      return Colors.orange;
    case 'CANCELLED':
    case 'FAILED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
