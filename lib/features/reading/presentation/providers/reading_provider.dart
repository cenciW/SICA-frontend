import 'package:flutter/material.dart';
import '../../domain/entities/reading.dart';
import '../../data/datasources/reading_remote_datasource.dart';

class ReadingProvider extends ChangeNotifier {
  final ReadingRemoteDataSource dataSource;

  ReadingProvider({required this.dataSource});

  void updateToken(String token) => dataSource.token = token;

  List<Reading> _readings = [];
  List<Reading> get readings => _readings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadReadings(String productId, {SensorType? sensorType, int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _readings = await dataSource.getReadings(productId, sensorType: sensorType, limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReading(String productId, SensorType sensorType, double value) async {
    try {
      final reading = await dataSource.createReading(productId, {
        'sensor_type': sensorType.apiValue,
        'value': value,
        'unit': sensorType.unit,
      });
      _readings.insert(0, reading);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
