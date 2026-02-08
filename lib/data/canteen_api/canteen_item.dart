class CanteenItem {
  final int id;
  final String name;
  final String? description;
  final num? price;

  CanteenItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
  });

  factory CanteenItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final description = json['description'] as String?;
    final price = json['price'] as num?;

    return CanteenItem(
      id: id,
      name: name,
      description: description,
      price: price,
    );
  }
}
