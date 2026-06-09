import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import '../../data/datasources/alert_remote_datasource.dart';

class AlertProvider extends ChangeNotifier {
  final AlertRemoteDataSource dataSource;

  AlertProvider({required this.dataSource});

  void updateToken(String token) => dataSource.token = token;

  static const _pageSize = 5;

  List<ProductAlert> _alerts = [];
  List<ProductAlert> get alerts => _alerts;

  int _total = 0;
  int get total => _total;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  int get activeCount => _total;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  String? _currentProductId;

  Future<void> loadAlerts(String productId) async {
    _currentProductId = productId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await dataSource.getAlerts(
        productId,
        onlyActive: true,
        take: _pageSize,
        skip: 0,
      );
      _alerts = result.items;
      _total = result.total;
      _hasMore = result.hasMore;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _currentProductId == null) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await dataSource.getAlerts(
        _currentProductId!,
        onlyActive: true,
        take: _pageSize,
        skip: _alerts.length,
      );
      _alerts = [..._alerts, ...result.items];
      _total = result.total;
      _hasMore = result.hasMore;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> resolveAll(String productId) async {
    try {
      await dataSource.resolveAll(productId);
      _alerts = [];
      _total = 0;
      _hasMore = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resolveAlert(String productId, String alertId) async {
    try {
      final resolved = await dataSource.resolveAlert(productId, alertId);
      final idx = _alerts.indexWhere((a) => a.id == alertId);
      if (idx != -1) _alerts[idx] = resolved;
      _total = (_total - 1).clamp(0, 999999);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
