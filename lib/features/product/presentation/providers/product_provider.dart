import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
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

  /// Busca o produto atualizado no banco (findOne traz relay_state,
  /// *_last_action_at, etc.) e sincroniza a cópia em _products. Retorna o
  /// produto fresco, ou null em caso de erro.
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

  void _applyConfirmedState(
      String id, String device, Map<String, dynamic> relay) {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    if (device == 'led') {
      _products[idx] = _products[idx].copyWith(
        relayState: relay['relay_state'] as bool?,
        relayLastActionAt: relay['relay_last_action_at'] != null
            ? DateTime.parse(relay['relay_last_action_at'] as String).toLocal()
            : null,
      );
    } else {
      _products[idx] = _products[idx].copyWith(
        pumpState: relay['pump_state'] as bool?,
        pumpLastActionAt: relay['pump_last_action_at'] != null
            ? DateTime.parse(relay['pump_last_action_at'] as String).toLocal()
            : null,
      );
    }
  }

  /// Atualiza estado + última ação de AMBOS os devices a partir do GET /relay.
  void _applyRelaySnapshot(String id, Map<String, dynamic> relay) {
    _applyConfirmedState(id, 'led', relay);
    _applyConfirmedState(id, 'pump', relay);
  }

  Future<bool> setRelayCycle(String id, Map<String, dynamic> data) async {
    // Qual device esta config altera (o editor envia só as chaves de um device).
    final device = data.containsKey('led_on_seconds') ? 'led' : 'pump';
    final onSeconds = data['${device}_on_seconds'] as int?;
    final offSeconds = data['${device}_off_seconds'] as int?;
    final key = '$id:$device';

    _pendingToggles.add(key);
    _error = null;
    notifyListeners();

    try {
      await repository.setRelayCycle(id, data);

      // Aplica imediatamente a config (segundos) no produto local.
      final idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _products[idx] = _products[idx].copyWith(
          ledOnSeconds: data['led_on_seconds'] as int?,
          ledOffSeconds: data['led_off_seconds'] as int?,
          ledStartOn: data['led_start_on'] as bool?,
          pumpOnSeconds: data['pump_on_seconds'] as int?,
          pumpOffSeconds: data['pump_off_seconds'] as int?,
          pumpStartOn: data['pump_start_on'] as bool?,
        );
      }

      // Estado esperado quando o modo é determinístico:
      // sempre ligado (on>0,off==0)=>true; desligado (on==0)=>false.
      // Modo ciclo (on>0 && off>0) oscila => não há alvo fixo (expected=null).
      final bool? expected = (onSeconds != null && offSeconds != null)
          ? (onSeconds == 0
              ? false
              : (offSeconds == 0 ? true : null))
          : null;

      // Polling aguardando o firmware confirmar via {clientId}/state.
      for (var attempt = 0; attempt < 6; attempt++) {
        await Future.delayed(const Duration(seconds: 1));
        final relay = await repository.getRelayState(id);
        final confirmed = device == 'led'
            ? relay['relay_state'] as bool?
            : relay['pump_state'] as bool?;
        // Determinístico: espera o alvo. Ciclo: aceita a 1ª leitura.
        if (expected == null || confirmed == expected) {
          _applyRelaySnapshot(id, relay);
          _pendingToggles.remove(key);
          notifyListeners();
          return true;
        }
      }

      // Sem confirmação: mantém a config salva, mas sinaliza ausência de retorno.
      _error = 'Sem confirmação do dispositivo';
      _pendingToggles.remove(key);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _pendingToggles.remove(key);
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
}
