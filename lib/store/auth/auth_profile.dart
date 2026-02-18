import 'dart:convert';

class AuthProfile {
  AuthProfile({
    this.id,
    required this.name,
    required this.email,
    this.number,
    this.branch,
    this.rollNumber,
  });

  final int? id;
  final String name;
  final String email;
  final String? number;
  final String? branch;
  final String? rollNumber;

  factory AuthProfile.fromJson(Map<String, dynamic> json) {
    return AuthProfile(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      number: json['number']?.toString(),
      branch: json['branch']?.toString(),
      rollNumber: json['rollNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'number': number,
      'branch': branch,
      'rollNumber': rollNumber,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static AuthProfile? fromJsonString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return AuthProfile.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
