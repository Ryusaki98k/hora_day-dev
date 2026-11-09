class Consultation {
  final String id;
  final String customerId;
  final DateTime consultationDate;
  final String? content;
  final double? fee;
  final String? notes;
  final DateTime createdAt;

  Consultation({
    required this.id,
    required this.customerId,
    required this.consultationDate,
    this.content,
    this.fee,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toSupabaseMap({bool isInsert = false}) {
    final map = <String, dynamic>{
      'customer_id': int.tryParse(customerId) ?? customerId,
      'consultation_date': consultationDate.toUtc().toIso8601String(),
      'content': content ?? '',
      'fee': fee,
      'notes': notes ?? '',
    };
    if (!isInsert && int.tryParse(id) != null) {
      map['id'] = int.parse(id);
    }
    return map;
  }

  Map<String, dynamic> toMap() => toSupabaseMap();

  factory Consultation.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawDate = map['consultation_date'] ?? map['consultationDate'];
    DateTime parsedDate = DateTime.now();
    if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    }

    final rawCreated = map['created_at'] ?? map['createdAt'];
    DateTime parsedCreated = DateTime.now();
    if (rawCreated != null) {
      parsedCreated = DateTime.tryParse(rawCreated.toString()) ?? DateTime.now();
    }

    return Consultation(
      id: docId ?? map['id']?.toString() ?? '',
      customerId: (map['customer_id'] ?? map['customerId'] ?? '').toString(),
      consultationDate: parsedDate.toLocal(),
      content: map['content']?.toString(),
      fee: map['fee'] != null ? double.tryParse(map['fee'].toString()) : null,
      notes: map['notes']?.toString(),
      createdAt: parsedCreated.toLocal(),
    );
  }

  Consultation copyWith({
    String? id,
    String? customerId,
    DateTime? consultationDate,
    String? content,
    double? fee,
    String? notes,
    DateTime? createdAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      consultationDate: consultationDate ?? this.consultationDate,
      content: content ?? this.content,
      fee: fee ?? this.fee,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
