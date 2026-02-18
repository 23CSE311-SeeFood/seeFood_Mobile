class ServerCanteen {
  ServerCanteen({
    required this.id,
    required this.name,
    this.ratings,
  });

  final int id;
  final String name;
  final num? ratings;

  factory ServerCanteen.fromJson(Map<String, dynamic> json) {
    return ServerCanteen(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString(),
      ratings: json['ratings'] as num?,
    );
  }
}

class ServerCanteenItem {
  ServerCanteenItem({
    required this.id,
    required this.name,
    this.price,
    this.rating,
    this.isVeg,
    this.canteenId,
    this.imageUrl,
  });

  final int id;
  final String name;
  final num? price;
  final num? rating;
  final bool? isVeg;
  final int? canteenId;
  final String? imageUrl;

  factory ServerCanteenItem.fromJson(Map<String, dynamic> json) {
    return ServerCanteenItem(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString(),
      price: json['price'] as num?,
      rating: json['rating'] as num?,
      isVeg: json['isVeg'] as bool?,
      canteenId: json['canteenId'] as int? ?? json['canteen_id'] as int?,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
    );
  }
}

class ServerCartItem {
  ServerCartItem({
    required this.id,
    required this.cartId,
    required this.canteenItemId,
    required this.quantity,
    this.canteenItem,
  });

  final int id;
  final int cartId;
  final int canteenItemId;
  final int quantity;
  final ServerCanteenItem? canteenItem;

  factory ServerCartItem.fromJson(Map<String, dynamic> json) {
    final canteenItemJson =
        json['canteenItem'] ?? json['canteen_item'] ?? json['item'];
    return ServerCartItem(
      id: json['id'] as int,
      cartId: json['cartId'] as int? ?? json['cart_id'] as int? ?? 0,
      canteenItemId:
          json['canteenItemId'] as int? ?? json['canteen_item_id'] as int? ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      canteenItem: canteenItemJson is Map<String, dynamic>
          ? ServerCanteenItem.fromJson(canteenItemJson)
          : null,
    );
  }
}

class ServerCart {
  ServerCart({
    required this.id,
    required this.studentId,
    required this.canteenId,
    this.total,
    this.canteen,
    required this.items,
  });

  final int id;
  final int studentId;
  final int? canteenId;
  final num? total;
  final ServerCanteen? canteen;
  final List<ServerCartItem> items;

  factory ServerCart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    final canteenJson = json['canteen'];

    return ServerCart(
      id: json['id'] as int,
      studentId: json['studentId'] as int? ?? json['student_id'] as int? ?? 0,
      canteenId: json['canteenId'] as int? ?? json['canteen_id'] as int?,
      total: json['total'] as num?,
      canteen: canteenJson is Map<String, dynamic>
          ? ServerCanteen.fromJson(canteenJson)
          : null,
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(ServerCartItem.fromJson)
          .toList(growable: false),
    );
  }
}
