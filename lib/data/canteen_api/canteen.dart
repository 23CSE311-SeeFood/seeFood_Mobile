class Canteen {
  final int id;
  final String name;
  // Add other fields as needed, e.g., final String description;

  Canteen({
    required this.id,
    required this.name,
    // required this.description,
  });

  factory Canteen.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    return Canteen(
      id: id,
      name: name,
      // description: json['description'],
    );
  }
}
