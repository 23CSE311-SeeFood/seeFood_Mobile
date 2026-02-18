class OrderItem {
  OrderItem({
    required this.id,
    required this.quantity,
    this.canteenItemId,
    this.name,
    this.price,
    this.total,
    this.canteenItemName,
  });

  final int id;
  final int quantity;
  final int? canteenItemId;
  final String? name;
  final num? price;
  final num? total;
  final String? canteenItemName;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final canteenItem = json['canteenItem'] as Map<String, dynamic>?;
    final itemName =
        json['name']?.toString() ?? canteenItem?['name']?.toString();
    return OrderItem(
      id: json['id'] as int,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      canteenItemId:
          json['canteenItemId'] as int? ?? json['canteen_item_id'] as int?,
      name: itemName,
      canteenItemName: canteenItem?['name']?.toString(),
      price: json['price'] as num? ?? canteenItem?['price'] as num?,
      total: json['total'] as num?,
    );
  }
}

class OrderModel {
  OrderModel({
    required this.id,
    this.orderId,
    this.status,
    this.total,
    this.currency,
    this.studentId,
    this.canteenId,
    this.canteenName,
    this.createdAt,
    required this.items,
  });

  final int id;
  final String? orderId;
  final String? status;
  final num? total;
  final String? currency;
  final int? studentId;
  final int? canteenId;
  final String? canteenName;
  final DateTime? createdAt;
  final List<OrderItem> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    final canteenJson = json['canteen'] as Map<String, dynamic>?;
    final createdAtValue = json['createdAt']?.toString();
    return OrderModel(
      id: json['id'] as int,
      orderId: json['orderId']?.toString(),
      status: json['status']?.toString(),
      total: json['total'] as num?,
      currency: json['currency']?.toString(),
      studentId: json['studentId'] as int? ?? json['student_id'] as int?,
      canteenId: json['canteenId'] as int? ?? json['canteen_id'] as int?,
      canteenName: canteenJson?['name']?.toString(),
      createdAt: createdAtValue != null ? DateTime.tryParse(createdAtValue) : null,
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(OrderItem.fromJson)
          .toList(growable: false),
    );
  }
}
