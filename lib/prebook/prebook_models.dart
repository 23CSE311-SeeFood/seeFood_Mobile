class PrebookSlotResponse {
  PrebookSlotResponse({
    required this.date,
    required this.canteenId,
    required this.slotMinutes,
    required this.capacity,
    required this.openHour,
    required this.closeHour,
    required this.slots,
  });

  final String date;
  final int canteenId;
  final int slotMinutes;
  final int capacity;
  final int openHour;
  final int closeHour;
  final List<PrebookSlot> slots;

  factory PrebookSlotResponse.fromJson(Map<String, dynamic> json) {
    final slotsJson = json['slots'] as List<dynamic>? ?? const [];
    final working = json['workingHours'] as Map<String, dynamic>? ?? {};
    return PrebookSlotResponse(
      date: json['date']?.toString() ?? '',
      canteenId: (json['canteenId'] as num?)?.toInt() ?? 0,
      slotMinutes: (json['slotMinutes'] as num?)?.toInt() ?? 0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      openHour: (working['openHour'] as num?)?.toInt() ?? 0,
      closeHour: (working['closeHour'] as num?)?.toInt() ?? 0,
      slots: slotsJson
          .whereType<Map<String, dynamic>>()
          .map(PrebookSlot.fromJson)
          .toList(growable: false),
    );
  }
}

class PrebookSlot {
  PrebookSlot({
    required this.start,
    required this.end,
    required this.remaining,
  });

  final DateTime start;
  final DateTime end;
  final int remaining;

  factory PrebookSlot.fromJson(Map<String, dynamic> json) {
    return PrebookSlot(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
    );
  }
}

class PrebookCreateResponse {
  PrebookCreateResponse({
    required this.prebookId,
    required this.slotStart,
    required this.slotEnd,
    required this.expiresAt,
    required this.razorpay,
  });

  final int prebookId;
  final DateTime slotStart;
  final DateTime slotEnd;
  final DateTime expiresAt;
  final PrebookRazorpay razorpay;

  factory PrebookCreateResponse.fromJson(Map<String, dynamic> json) {
    return PrebookCreateResponse(
      prebookId: (json['prebookId'] as num?)?.toInt() ?? 0,
      slotStart: DateTime.parse(json['slotStart'] as String),
      slotEnd: DateTime.parse(json['slotEnd'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      razorpay: PrebookRazorpay.fromJson(
        json['razorpay'] as Map<String, dynamic>,
      ),
    );
  }
}

class PrebookRazorpay {
  PrebookRazorpay({
    required this.orderId,
    required this.key,
    required this.amount,
    required this.currency,
  });

  final String orderId;
  final String key;
  final int amount;
  final String currency;

  factory PrebookRazorpay.fromJson(Map<String, dynamic> json) {
    return PrebookRazorpay(
      orderId: json['orderId'] as String,
      key: json['key'] as String,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

class PrebookVerifyResponse {
  PrebookVerifyResponse({
    required this.status,
    required this.order,
  });

  final String status;
  final PrebookOrder order;

  factory PrebookVerifyResponse.fromJson(Map<String, dynamic> json) {
    return PrebookVerifyResponse(
      status: json['status']?.toString() ?? '',
      order: PrebookOrder.fromJson(json['order'] as Map<String, dynamic>),
    );
  }
}

class PrebookOrder {
  PrebookOrder({
    required this.id,
    required this.orderId,
    required this.status,
    required this.scheduledFor,
    required this.isPrebooked,
    this.tokenNumber,
  });

  final int id;
  final String orderId;
  final String status;
  final DateTime scheduledFor;
  final bool isPrebooked;
  final int? tokenNumber;

  factory PrebookOrder.fromJson(Map<String, dynamic> json) {
    return PrebookOrder(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: json['orderId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      isPrebooked: json['isPrebooked'] == true,
      tokenNumber: (json['tokenNumber'] as num?)?.toInt(),
    );
  }
}
