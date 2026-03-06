import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/data/app_env.dart';
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
  WebSocket? _socket;
  bool _wsConnecting = false;
  String? _liveStatus;
  int? _liveToken;
  final Map<int, QueuePosition> _positionsByItemId = {};
  int? _currentOrderId;
  String? _currentOrderPublicId;

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
    _socket?.close();
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _ensureWebSocket(order);
          });

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderCard(
                order: order,
                statusOverride: _liveStatus,
                tokenOverride: _liveToken,
              ),
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
              ...order.items.map(
                (item) => _ItemStatusCard(
                  item: item,
                  position: _positionsByItemId[item.id],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _ensureWebSocket(OrderModel order) async {
    if (_socket != null || _wsConnecting) return;
    _currentOrderId ??= order.id;
    _currentOrderPublicId ??= order.orderId;
    final canteenId = order.canteenId;
    if (canteenId == null) return;

    _wsConnecting = true;
    final wsUri = _buildWsUri(canteenId);
    try {
      final socket = await WebSocket.connect(wsUri.toString());
      _socket = socket;
      _wsConnecting = false;
      socket.listen(
        (msg) {
          _handleWsMessage(msg);
        },
        onError: (_) {},
        onDone: () {
          _socket = null;
        },
      );
    } catch (e) {
      _wsConnecting = false;
    }
  }

  Uri _buildWsUri(int canteenId) {
    final base = Uri.parse(AppEnv.apiBaseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final host = (Platform.isAndroid &&
            (base.host == 'localhost' || base.host == '127.0.0.1'))
        ? '10.0.2.2'
        : base.host;
    return Uri(
      scheme: scheme,
      host: host,
      port: base.hasPort ? base.port : null,
      path: '/ws',
      queryParameters: {'canteenId': '$canteenId'},
    );
  }

  void _handleWsMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message.toString());
      if (decoded is! Map<String, dynamic>) return;
      final type = decoded['type']?.toString();
      if (type == 'queue_update') {
        _applyQueueUpdate(decoded);
        return;
      }
      if (type == 'queue_snapshot') {
        _applyQueueSnapshot(decoded);
        return;
      }
    } catch (e) {
      debugPrint('Error handling WS message: $e');
    }
  }

  bool _matchesOrder(dynamic orderId) {
    if (orderId == null) return false;
    final orderIdStr = orderId.toString();
    if (_currentOrderId != null &&
        orderIdStr == _currentOrderId.toString()) {
      return true;
    }
    if (_currentOrderPublicId != null &&
        orderIdStr == _currentOrderPublicId) {
      return true;
    }
    return false;
  }

  void _applyQueueUpdate(Map<String, dynamic> decoded) {
    final orderId = decoded['orderId'];
    if (!_matchesOrder(orderId)) return;

    final queues = decoded['queues'];
    final nextPositions = <int, QueuePosition>{};
    if (queues is List) {
      for (final entry in queues) {
        if (entry is Map<String, dynamic>) {
          final itemIdRaw = entry['orderItemId'];
          final station = entry['station']?.toString();
          final position = entry['position'];
          final itemId = itemIdRaw is int
              ? itemIdRaw
              : int.tryParse(itemIdRaw?.toString() ?? '');
          if (itemId != null && station != null && position is num) {
            nextPositions[itemId] = QueuePosition(
              station: station,
              position: position.toInt(),
            );
          }
        }
      }
    }

    setState(() {
      _liveStatus = decoded['orderStatus']?.toString() ?? _liveStatus;
      final token = decoded['tokenNumber'];
      if (token is num) {
        _liveToken = token.toInt();
      }
      if (nextPositions.isNotEmpty) {
        _positionsByItemId
          ..clear()
          ..addAll(nextPositions);
      }
    });
  }

  void _applyQueueSnapshot(Map<String, dynamic> decoded) {
    final queues = decoded['queues'];
    if (queues is! Map) return;

    final nextPositions = <int, QueuePosition>{};
    int? nextToken;

    queues.forEach((stationKey, value) {
      final station = stationKey.toString();
      if (value is! List) return;
      for (final entry in value) {
        if (entry is Map<String, dynamic>) {
          final entryOrderId = entry['orderId'];
          if (!_matchesOrder(entryOrderId)) continue;

          final itemIdRaw = entry['orderItemId'];
          final position = entry['position'];
          final itemId = itemIdRaw is int
              ? itemIdRaw
              : int.tryParse(itemIdRaw?.toString() ?? '');
          if (itemId != null && position is num) {
            nextPositions[itemId] = QueuePosition(
              station: station,
              position: position.toInt(),
            );
          }
          final tokenRaw = entry['tokenNumber'];
          if (tokenRaw is num) {
            nextToken = tokenRaw.toInt();
          }
        }
      }
    });

    if (nextPositions.isEmpty && nextToken == null) return;

    setState(() {
      if (nextToken != null) {
        _liveToken = nextToken;
      }
      if (nextPositions.isNotEmpty) {
        _positionsByItemId
          ..clear()
          ..addAll(nextPositions);
      }
    });
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.order,
    this.statusOverride,
    this.tokenOverride,
  });

  final OrderModel order;
  final String? statusOverride;
  final int? tokenOverride;

  @override
  Widget build(BuildContext context) {
    final status = statusOverride ?? order.status ?? 'CREATED';
    final token = tokenOverride?.toString() ?? order.tokenNumber?.toString() ?? '—';
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
  const _ItemStatusCard({required this.item, this.position});

  final OrderItem item;
  final QueuePosition? position;

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
                if (position != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Station ${position!.station} • Position ${position!.position}',
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

class QueuePosition {
  const QueuePosition({required this.station, required this.position});

  final String station;
  final int position;
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
        color: color.withValues(alpha: 0.12),
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
    case 'IN_PROGRESS':
      return const Color(0xFF1E6BD6);
    case 'DELAYED':
      return const Color(0xFFD97706);
    case 'REQUEUE':
      return const Color(0xFF7C3AED);
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
