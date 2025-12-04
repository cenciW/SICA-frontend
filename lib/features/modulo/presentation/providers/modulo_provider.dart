import 'package:flutter/material.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/modulo.dart';
import '../../domain/repositories/modulo_repository.dart';

class ModuloProvider with ChangeNotifier {
  final ModuloRepository repository;

  ModuloProvider({required this.repository});

  List<Modulo> _modulos = [];
  bool _isLoading = false;
  String? _error;

  List<Modulo> get modulos => _modulos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadModulosByEstufa(String estufaId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newModulos = await repository.getModulosByEstufa(estufaId, token);

      // Remove old modules from this estufa and add new ones
      _modulos.removeWhere((m) => m.estufaId == estufaId);
      _modulos.addAll(newModulos);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Modulo?> getModulo(String id, String token) async {
    try {
      return await repository.getModulo(id, token);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createModulo(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newModulo = await repository.createModulo(data, token);
      _modulos.add(newModulo);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAtuador(
      String moduloId, String atuadorId, bool estado, String token) async {
    try {
      final updatedAtuador =
          await repository.toggleAtuador(moduloId, atuadorId, estado, token);

      // Update local state
      final moduloIndex = _modulos.indexWhere((m) => m.id == moduloId);
      if (moduloIndex != -1) {
        final modulo = _modulos[moduloIndex];
        final atuadorIndex =
            modulo.atuadores.indexWhere((a) => a.id == atuadorId);
        if (atuadorIndex != -1) {
          modulo.atuadores[atuadorIndex] = updatedAtuador;
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteModulo(String id, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteModulo(id, token);
      _modulos.removeWhere((m) => m.id == id);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllModulos(List<String> estufaIds, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modulos.clear();
      for (final estufaId in estufaIds) {
        final newModulos = await repository.getModulosByEstufa(estufaId, token);
        _modulos.addAll(newModulos);
      }
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
