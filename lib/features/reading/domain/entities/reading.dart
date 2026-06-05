enum SensorType { PH, PPM }

extension SensorTypeExt on SensorType {
  String get label => this == SensorType.PH ? 'pH' : 'PPM';
  String get unit => this == SensorType.PH ? 'pH' : 'ppm';
  String get apiValue => this == SensorType.PH ? 'PH' : 'PPM';

  static SensorType fromString(String s) =>
      s.toUpperCase() == 'PH' ? SensorType.PH : SensorType.PPM;
}

class Reading {
  final String id;
  final String productId;
  final SensorType sensorType;
  final double value;
  final String unit;
  final DateTime recordedAt;

  Reading({
    required this.id,
    required this.productId,
    required this.sensorType,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] as String,
      productId: (json['user_product_id'] ?? json['product_id']) as String,
      sensorType: SensorTypeExt.fromString(json['sensor_type'] as String),
      value: (json['value'] as num).toDouble(),
      unit: (json['unit'] as String?) ?? '',
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String).toLocal()
          : DateTime.now(),
    );
  }
}
