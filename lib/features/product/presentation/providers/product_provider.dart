import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/device_schedule.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  void updateToken(String token) {
    final impl = repository as ProductRepositoryImpl;
    impl.dataSource.token = token;
  }

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Toggles aguardando confirmação do firmware (chave: '$productId:$device').
  final Set<String> _pendingToggles = {};
  bool isTogglePending(String productId, String device) =>
      _pendingToggles.contains('$productId:$device');

  // Schedules: cache por productId
  final Map<String, List<DeviceSchedule>> _schedulesCache = {};
  bool _schedulesLoading = false;
  bool get schedulesLoading => _schedulesLoading;

  List<DeviceSchedule> getSchedules(String productId, String device) =>
      (_schedulesCache[productId] ?? [])
          .where((s) => s.device == device)
          .toList();

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await repository.getProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> refreshProduct(String id) async {
    try {
      final fresh = await repository.getProduct(id);
      final idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _products[idx] = fresh;
      } else {
        _products.add(fresh);
      }
      notifyListeners();
      return fresh;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final p = await repository.createProduct(data);
      _products.insert(0, p);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> linkProduct(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final p = await repository.linkProduct(code);
      final idx = _products.indexWhere((x) => x.id == p.id);
      if (idx == -1) _products.insert(0, p);
      return p;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await repository.updateProduct(id, data);
      final idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) _products[idx] = updated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await repository.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInstanceConfig(
      String productId, String instanceId, Map<String, dynamic> data) async {
    try {
      await repository.updateInstanceConfig(productId, instanceId, data);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Schedules ──────────────────────────────────────────────────────────────

  Future<void> loadSchedules(String productId) async {
    _schedulesLoading = true;
    notifyListeners();
    try {
      final list = await repository.getSchedules(productId);
      _schedulesCache[productId] = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _schedulesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSchedule(String productId, Map<String, dynamic> data) async {
    _error = null;
    try {
      final created = await repository.createSchedule(productId, data);
      final list = List<DeviceSchedule>.from(_schedulesCache[productId] ?? []);
      list.add(created);
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _schedulesCache[productId] = list;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchedule(
      String productId, String scheduleId, Map<String, dynamic> data) async {
    _error = null;
    try {
      final updated = await repository.updateSchedule(productId, scheduleId, data);
      final list = List<DeviceSchedule>.from(_schedulesCache[productId] ?? []);
      final idx = list.indexWhere((s) => s.id == scheduleId);
      if (idx != -1) list[idx] = updated;
      _schedulesCache[productId] = list;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(String productId, String scheduleId) async {
    _error = null;
    try {
      await repository.deleteSchedule(productId, scheduleId);
      _schedulesCache[productId]?.removeWhere((s) => s.id == scheduleId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Manual override ────────────────────────────────────────────────────────

  // state: 'on' | 'off' | 'auto'
  Future<bool> setManual(String productId, String device, String state) async {
    _error = null;
    try {
      final result = await repository.setManual(productId, device, state);
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        final bool? ledManual = result['led_manual'] as bool?;
        final bool? pumpManual = result['pump_manual'] as bool?;
        _products[idx] = _products[idx].copyWith(
          ledManual: ledManual,
          pumpManual: pumpManual,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
