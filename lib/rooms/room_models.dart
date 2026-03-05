class RoomMember {
  RoomMember({
    required this.id,
    required this.studentId,
    required this.name,
    required this.status,
    required this.amount,
  });

  final int id;
  final int studentId;
  final String name;
  final String status;
  final num amount;

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      id: (json['id'] as num?)?.toInt() ?? 0,
      studentId: (json['studentId'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Member',
      status: json['status']?.toString() ?? 'PENDING',
      amount: (json['amount'] as num?) ?? 0,
    );
  }
}

class RoomModel {
  RoomModel({
    required this.id,
    required this.code,
    required this.status,
    required this.canteenId,
    required this.expiresAt,
    required this.members,
    required this.allPaid,
    this.orderId,
  });

  final int id;
  final String code;
  final String status;
  final int canteenId;
  final DateTime expiresAt;
  final List<RoomMember> members;
  final bool allPaid;
  final int? orderId;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? const [];
    return RoomModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      canteenId: (json['canteenId'] as num?)?.toInt() ?? 0,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      members: membersJson
          .whereType<Map<String, dynamic>>()
          .map(RoomMember.fromJson)
          .toList(growable: false),
      allPaid: json['allPaid'] == true,
      orderId: (json['orderId'] as num?)?.toInt(),
    );
  }
}

class RoomCreateResponse {
  RoomCreateResponse({
    required this.roomId,
    required this.code,
    required this.canteenId,
    required this.expiresAt,
  });

  final int roomId;
  final String code;
  final int canteenId;
  final DateTime expiresAt;

  factory RoomCreateResponse.fromJson(Map<String, dynamic> json) {
    return RoomCreateResponse(
      roomId: (json['roomId'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      canteenId: (json['canteenId'] as num?)?.toInt() ?? 0,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

class RoomPayCreateResponse {
  RoomPayCreateResponse({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.key,
  });

  final String orderId;
  final int amount;
  final String currency;
  final String? key;

  factory RoomPayCreateResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['razorpay'] is Map<String, dynamic>
        ? json['razorpay'] as Map<String, dynamic>
        : json;
    final rawOrderId =
        payload['orderId'] ?? payload['id'] ?? payload['razorpayOrderId'];
    return RoomPayCreateResponse(
      orderId: rawOrderId?.toString() ?? '',
      amount: (payload['amount'] as num?)?.toInt() ?? 0,
      currency: payload['currency']?.toString() ?? 'INR',
      key: payload['key']?.toString(),
    );
  }
}
