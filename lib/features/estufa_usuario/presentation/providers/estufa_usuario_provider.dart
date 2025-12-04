import 'package:flutter/material.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/estufa_usuario.dart';
import '../../domain/repositories/estufa_usuario_repository.dart';

class EstufaUsuarioProvider extends ChangeNotifier {
  final EstufaUsuarioRepository repository;

  EstufaUsuarioProvider({required this.repository});

  List<EstufaUsuario> _estufaUsuarios = [];
  List<EstufaUsuario> get estufaUsuarios => _estufaUsuarios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadEstufaUsuarios(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _estufaUsuarios = await repository.getEstufaUsuarios(token);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEstufaUsuario(
      Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEstufaUsuario =
          await repository.createEstufaUsuario(data, token);
      _estufaUsuarios.add(newEstufaUsuario);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEstufaUsuario(
      String id, Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEstufaUsuario =
          await repository.updateEstufaUsuario(id, data, token);
      final index = _estufaUsuarios.indexWhere((eu) => eu.id == id);
      if (index != -1) {
        _estufaUsuarios[index] = updatedEstufaUsuario;
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

  Future<bool> deleteEstufaUsuario(String id, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteEstufaUsuario(id, token);
      _estufaUsuarios.removeWhere((eu) => eu.id == id);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
