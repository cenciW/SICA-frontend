class Product {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? linkCode;
  final String status;
  final String? firmwareVersion;
  // Campos operacionais vindos do UserProduct via findOne
  final double? phMin;
  final double? phMax;
  final double? ppmMin;
  final double? ppmMax;
  final double? phCurrent;
  final double? ppmCurrent;
  final DateTime? lastReadingAt;
  final bool relayState;
  final DateTime? relayLastActionAt;
  final bool pumpState;
  final DateTime? pumpLastActionAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Metadados da instância (UserProduct)
  final String? userRole;
  final String? instanceId;
  final String? clientId;
  final String? instanceName;
  final int? userProductsCount;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.linkCode,
    required this.status,
    this.firmwareVersion,
    this.phMin,
    this.phMax,
    this.ppmMin,
    this.ppmMax,
    this.phCurrent,
    this.ppmCurrent,
    this.lastReadingAt,
    required this.relayState,
    this.relayLastActionAt,
    required this.pumpState,
    this.pumpLastActionAt,
    required this.createdAt,
    required this.updatedAt,
    this.userRole,
    this.instanceId,
    this.clientId,
    this.instanceName,
    this.userProductsCount,
  });

  bool get isRelayOn => relayState;

  bool get phNormal =>
      phCurrent != null &&
      phMin != null &&
      phMax != null &&
      phCurrent! >= phMin! &&
      phCurrent! <= phMax!;

  bool get ppmNormal =>
      ppmCurrent != null &&
      ppmMin != null &&
      ppmMax != null &&
      ppmCurrent! >= ppmMin! &&
      ppmCurrent! <= ppmMax!;

  bool get isOwner => userRole == 'OWNER';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      linkCode: json['link_code'] as String?,
      status: (json['status'] as String?) ?? 'active',
      firmwareVersion: json['firmware_version'] as String?,
      phMin: (json['ph_min'] as num?)?.toDouble(),
      phMax: (json['ph_max'] as num?)?.toDouble(),
      ppmMin: (json['ppm_min'] as num?)?.toDouble(),
      ppmMax: (json['ppm_max'] as num?)?.toDouble(),
      phCurrent: (json['ph_current'] as num?)?.toDouble(),
      ppmCurrent: (json['ppm_current'] as num?)?.toDouble(),
      lastReadingAt: json['last_reading_at'] != null
          ? DateTime.parse(json['last_reading_at'] as String).toLocal()
          : null,
      relayState: (json['relay_state'] as bool?) ?? false,
      relayLastActionAt: json['relay_last_action_at'] != null
          ? DateTime.parse(json['relay_last_action_at'] as String).toLocal()
          : null,
      pumpState: (json['pump_state'] as bool?) ?? false,
      pumpLastActionAt: json['pump_last_action_at'] != null
          ? DateTime.parse(json['pump_last_action_at'] as String).toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : DateTime.now(),
      userRole: json['userRole'] as String?,
      instanceId: json['instanceId'] as String?,
      clientId: json['clientId'] as String?,
      instanceName: json['instanceName'] as String?,
      userProductsCount:
          (json['_count'] as Map<String, dynamic>?)?['userProducts'] as int?,
    );
  }

  Product copyWith({
    bool? relayState,
    DateTime? relayLastActionAt,
    bool? pumpState,
    DateTime? pumpLastActionAt,
    double? phCurrent,
    double? ppmCurrent,
    double? phMin,
    double? phMax,
    double? ppmMin,
    double? ppmMax,
  }) {
    return Product(
      id: id,
      userId: userId,
      name: name,
      description: description,
      linkCode: linkCode,
      status: status,
      firmwareVersion: firmwareVersion,
      phMin: phMin ?? this.phMin,
      phMax: phMax ?? this.phMax,
      ppmMin: ppmMin ?? this.ppmMin,
      ppmMax: ppmMax ?? this.ppmMax,
      phCurrent: phCurrent ?? this.phCurrent,
      ppmCurrent: ppmCurrent ?? this.ppmCurrent,
      lastReadingAt: lastReadingAt,
      relayState: relayState ?? this.relayState,
      relayLastActionAt: relayLastActionAt ?? this.relayLastActionAt,
      pumpState: pumpState ?? this.pumpState,
      pumpLastActionAt: pumpLastActionAt ?? this.pumpLastActionAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userRole: userRole,
      instanceId: instanceId,
      clientId: clientId,
      instanceName: instanceName,
      userProductsCount: userProductsCount,
    );
  }
}
