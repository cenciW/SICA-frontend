import 'package:flutter/material.dart';
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
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEstufa(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEstufa = await repository.createEstufa(data);
      _estufas.add(newEstufa);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEstufa(String id, Map<String, dynamic> data, String token) async {
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
      _error = e.toString();
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
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> vincularEstufa(String codigo, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.vincularEstufa(codigo, token);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleDevice(String id, String device, bool state, String token) async {
    try {
      final updatedEstufa = await repository.toggleDevice(id, device, state, token);
      final index = _estufas.indexWhere((e) => e.id == id);
      if (index != -1) {
        _estufas[index] = updatedEstufa;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
