import 'package:flutter_test/flutter_test.dart';
import 'package:seefood/store/auth/auth_profile.dart';

void main() {
  group('AuthProfile', () {
    test('fromJson creates AuthProfile correctly', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'number': '1234567890',
        'branch': 'Computer Science',
        'rollNumber': 'CS001',
      };

      final profile = AuthProfile.fromJson(json);

      expect(profile.id, 1);
      expect(profile.name, 'John Doe');
      expect(profile.email, 'john@example.com');
      expect(profile.number, '1234567890');
      expect(profile.branch, 'Computer Science');
      expect(profile.rollNumber, 'CS001');
    });

    test('toJson returns correct map', () {
      final profile = AuthProfile(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        number: '1234567890',
        branch: 'Computer Science',
        rollNumber: 'CS001',
      );

      final json = profile.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['number'], '1234567890');
      expect(json['branch'], 'Computer Science');
      expect(json['rollNumber'], 'CS001');
    });

    test('fromJsonString and toJsonString work correctly', () {
      final originalProfile = AuthProfile(
        id: 2,
        name: 'Jane Smith',
        email: 'jane@example.com',
      );

      final jsonString = originalProfile.toJsonString();
      final restoredProfile = AuthProfile.fromJsonString(jsonString);

      expect(restoredProfile?.id, 2);
      expect(restoredProfile?.name, 'Jane Smith');
      expect(restoredProfile?.email, 'jane@example.com');
    });

    test('fromJsonString returns null for invalid string', () {
      final profile = AuthProfile.fromJsonString('invalid json');
      expect(profile, isNull);
    });
  });
}