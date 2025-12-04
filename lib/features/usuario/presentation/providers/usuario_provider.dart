import 'package:flutter/material.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioRepository repository;

  UsuarioProvider({required this.repository});

  List<Usuario> _usuarios = [];
  List<Usuario> get usuarios => _usuarios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadUsuarios(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuarios = await repository.getUsuarios(token);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUsuario(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await repository.createUsuario(data, token);
      _usuarios.add(newUser);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUsuario(
      String id, Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await repository.updateUsuario(id, data, token);
      final index = _usuarios.indexWhere((u) => u.id == id);
      if (index != -1) {
        _usuarios[index] = updatedUser;
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

  Future<bool> deleteUsuario(String id, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteUsuario(id, token);
      _usuarios.removeWhere((u) => u.id == id);
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
