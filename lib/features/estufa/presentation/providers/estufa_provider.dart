import 'package:flutter/material.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/estufa.dart';
import '../../domain/repositories/estufa_repository.dart';

class EstufaProvider extends ChangeNotifier {
  final EstufaRepository repository;

  EstufaProvider({required this.repository});

  List<Estufa> _estufas = [];
  List<Estufa> get estufas => _estufas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadEstufas(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _estufas = await repository.getEstufas(token);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEstufa(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEstufa = await repository.createEstufa(data, token);
      _estufas.add(newEstufa);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEstufa(
      String id, Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEstufa = await repository.updateEstufa(id, data, token);
      final index = _estufas.indexWhere((e) => e.id == id);
      if (index != -1) {
        _estufas[index] = updatedEstufa;
      }
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEstufa(String id, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteEstufa(id, token);
      _estufas.removeWhere((e) => e.id == id);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Estufa? _lastVinculada;
  Estufa? get lastVinculada => _lastVinculada;

  Future<Estufa?> vincularEstufa(String codigo, String token) async {
    _isLoading = true;
    _error = null;
    _lastVinculada = null;
    notifyListeners();

    try {
      final estufa = await repository.vincularEstufa(codigo, token);
      _estufas.add(estufa);
      _lastVinculada = estufa;
      return estufa;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleDevice(
      String id, String device, bool state, String token) async {
    try {
      final updatedEstufa =
          await repository.toggleDevice(id, device, state, token);
      final index = _estufas.indexWhere((e) => e.id == id);
      if (index != -1) {
        _estufas[index] = updatedEstufa;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    }
  }
}
