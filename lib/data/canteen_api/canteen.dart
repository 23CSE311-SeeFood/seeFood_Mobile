class Canteen {
  final int id;
  final String name;
  final String? imageUrl;
  // Add other fields as needed, e.g., final String description;

  Canteen({
    required this.id,
    required this.name,
    this.imageUrl,
    // required this.description,
  });

  factory Canteen.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final imageUrl =
        (json['imageUrl'] as String?) ?? (json['image_url'] as String?);
    return Canteen(
      id: id,
      name: name,
      imageUrl: imageUrl,
      // description: json['description'],
    );
  }
}
