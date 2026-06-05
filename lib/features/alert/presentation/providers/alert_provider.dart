import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import '../../data/datasources/alert_remote_datasource.dart';

class AlertProvider extends ChangeNotifier {
  final AlertRemoteDataSource dataSource;

  AlertProvider({required this.dataSource});

  void updateToken(String token) => dataSource.token = token;

  List<ProductAlert> _alerts = [];
  List<ProductAlert> get alerts => _alerts;
  int get activeCount => _alerts.where((a) => !a.resolved).length;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadAlerts(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _alerts = await dataSource.getAlerts(productId, onlyActive: true);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resolveAlert(String productId, String alertId) async {
    try {
      final resolved = await dataSource.resolveAlert(productId, alertId);
      final idx = _alerts.indexWhere((a) => a.id == alertId);
      if (idx != -1) _alerts[idx] = resolved;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
