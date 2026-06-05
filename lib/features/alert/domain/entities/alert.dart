import '../../../reading/domain/entities/reading.dart';

enum AlertSeverity { WARNING, CRITICAL }

class ProductAlert {
  final String id;
  final String productId;
  final SensorType sensorType;
  final AlertSeverity severity;
  final double value;
  final double threshold;
  final String message;
  final bool resolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ProductAlert({
    required this.id,
    required this.productId,
    required this.sensorType,
    required this.severity,
    required this.value,
    required this.threshold,
    required this.message,
    required this.resolved,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ProductAlert.fromJson(Map<String, dynamic> json) {
    return ProductAlert(
      id: json['id'] as String,
      productId: (json['user_product_id'] ?? json['product_id']) as String,
      sensorType: SensorTypeExt.fromString(json['sensor_type'] as String),
      severity: json['severity'] == 'CRITICAL' ? AlertSeverity.CRITICAL : AlertSeverity.WARNING,
      value: (json['value'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      message: (json['message'] as String?) ?? '',
      resolved: (json['resolved'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String).toLocal()
          : null,
    );
  }
}
