import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/orders/order_models.dart';
import 'package:seefood/orders/orders_api.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/themes/app_colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrdersApi _ordersApi;
  Future<List<OrderModel>>? _future;
  int? _lastStudentId;

  @override
  void initState() {
    super.initState();
    _ordersApi = OrdersApi();
  }

  @override
  void dispose() {
    _ordersApi.close();
    super.dispose();
  }

  void _loadIfNeeded(AuthRepository authRepository) {
    final studentId = authRepository.getStudentId();
    if (studentId == null) return;
    if (_future != null && _lastStudentId == studentId) return;
    _lastStudentId = studentId;
    _future = _ordersApi.fetchOrders(
      studentId: studentId,
      token: authRepository.getToken(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.watch<AuthRepository>();
    final profile = authRepository.getProfileOrFromToken();
    _loadIfNeeded(authRepository);

    final studentId = authRepository.getStudentId();
    if (studentId == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('Login to view your orders'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<OrderModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load orders: ${snapshot.error}'),
                  );
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders yet'));
                }

                return ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _OrderCard(order: orders[index]);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Student: ${profile?.name ?? '—'}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = order.status ?? 'CREATED';
    final orderId = order.orderId ?? 'Order #${order.id}';
    final total = order.total ?? 0;
    final canteen = order.canteenId != null
        ? 'Canteen #${order.canteenId}'
        : 'Canteen';

    final statusColor = _statusColor(status);
    final statusBg = statusColor.withOpacity(0.15);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                canteen,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            orderId,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: order.items.map((item) {
              final name =
                  item.name ?? (item.canteenItemId != null ? 'Item ${item.canteenItemId}' : 'Item');
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$name x${item.quantity}',
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '₹${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
