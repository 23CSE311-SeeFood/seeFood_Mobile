class ServerCart {
  ServerCart({
    required this.id,
    required this.studentId,
    required this.canteenId,
    required this.total,
    required this.items,
    this.canteen,
  });

  final int id;
  final int studentId;
  final int canteenId;
  final num total;
  final List<ServerCartItem> items;
  final ServerCanteen? canteen;

  factory ServerCart.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? []);
    return ServerCart(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      canteenId: json['canteenId'] as int,
      total: json['total'] as num,
      canteen: json['canteen'] is Map<String, dynamic>
          ? ServerCanteen.fromJson(json['canteen'] as Map<String, dynamic>)
          : null,
      items: itemsJson
          .map((item) =>
              ServerCartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServerCartItem {
  ServerCartItem({
    required this.id,
    required this.canteenItemId,
    required this.quantity,
    required this.canteenItem,
  });

  final int id;
  final int canteenItemId;
  final int quantity;
  final ServerCanteenItem canteenItem;

  factory ServerCartItem.fromJson(Map<String, dynamic> json) {
    return ServerCartItem(
      id: json['id'] as int,
      canteenItemId: json['canteenItemId'] as int,
      quantity: json['quantity'] as int,
      canteenItem: ServerCanteenItem.fromJson(
        json['canteenItem'] as Map<String, dynamic>,
      ),
    );
  }
}

class ServerCanteenItem {
  ServerCanteenItem({
    required this.id,
    required this.name,
    required this.price,
    this.rating,
    this.isVeg,
    this.canteenId,
  });

  final int id;
  final String name;
  final num price;
  final num? rating;
  final bool? isVeg;
  final int? canteenId;

  factory ServerCanteenItem.fromJson(Map<String, dynamic> json) {
    return ServerCanteenItem(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as num,
      rating: json['rating'] as num?,
      isVeg: json['isVeg'] as bool?,
      canteenId: json['canteenId'] as int?,
    );
  }
}

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
      name: json['name'] as String,
      ratings: json['ratings'] as num?,
    );
  }
}
