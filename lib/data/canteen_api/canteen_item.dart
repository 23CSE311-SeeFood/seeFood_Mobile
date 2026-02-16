class CanteenItem {
  final int id;
  final String name;
  final String? description;
  final num? price;
  final String? imageUrl;
  final num? rating;
  final int? canteenId;

  CanteenItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.rating,
    this.canteenId,
  });

  factory CanteenItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final description = json['description'] as String?;
    final price = json['price'] as num?;
    final imageUrl =
        (json['imageUrl'] as String?) ?? (json['image_url'] as String?);
    final rating = json['rating'] as num?;
    final canteenId = json['canteenId'] as int?;

    return CanteenItem(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      rating: rating,
      canteenId: canteenId,
    );
  }
}
