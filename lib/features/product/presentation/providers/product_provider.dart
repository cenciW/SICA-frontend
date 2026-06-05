import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/datasources/product_remote_datasource.dart';
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

  Future<bool> toggleRelay(String id, bool state) async {
    try {
      final result = await repository.toggleRelay(id, 'led', state);
      final idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(
          relayState: result['relay_state'] as bool? ?? state,
          relayLastActionAt: result['relay_last_action_at'] != null
              ? DateTime.parse(result['relay_last_action_at'] as String).toLocal()
              : DateTime.now(),
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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

  Future<bool> togglePump(String id, bool state) async {
    try {
      final result = await repository.toggleRelay(id, 'pump', state);
      final idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(
          pumpState: result['pump_state'] as bool? ?? state,
          pumpLastActionAt: result['pump_last_action_at'] != null
              ? DateTime.parse(result['pump_last_action_at'] as String).toLocal()
              : DateTime.now(),
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
