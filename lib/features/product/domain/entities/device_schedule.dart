class DeviceSchedule {
  final String id;
  final String userProductId;
  final String device; // 'led' | 'pump'
  final String startTime; // "HH:MM" horário local
  final String endTime;   // "HH:MM" horário local
  final bool enabled;
  final int sortOrder;
  final DateTime createdAt;

  const DeviceSchedule({
    required this.id,
    required this.userProductId,
    required this.device,
    required this.startTime,
    required this.endTime,
    required this.enabled,
    required this.sortOrder,
    required this.createdAt,
  });

  factory DeviceSchedule.fromJson(Map<String, dynamic> json) {
    return DeviceSchedule(
      id: json['id'] as String,
      userProductId: json['user_product_id'] as String,
      device: json['device'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      enabled: (json['enabled'] as bool?) ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  DeviceSchedule copyWith({bool? enabled, String? startTime, String? endTime}) {
    return DeviceSchedule(
      id: id,
      userProductId: userProductId,
      device: device,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enabled: enabled ?? this.enabled,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  /// Retorna true se o horário atual (local) cai dentro desta janela.
  bool get isActiveNow {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final s = _parseMinutes(startTime);
    final e = _parseMinutes(endTime);
    if (s <= e) return nowMin >= s && nowMin < e;
    return nowMin >= s || nowMin < e; // cruza meia-noite
  }

  static int _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
