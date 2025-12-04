import 'package:flutter/material.dart';
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

  Future<void> loadEstufaUsuarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _estufaUsuarios = await repository.getEstufaUsuarios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEstufaUsuario(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEstufaUsuario = await repository.createEstufaUsuario(data);
      _estufaUsuarios.add(newEstufaUsuario);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEstufaUsuario(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEstufaUsuario = await repository.updateEstufaUsuario(id, data);
      final index = _estufaUsuarios.indexWhere((eu) => eu.id == id);
      if (index != -1) {
        _estufaUsuarios[index] = updatedEstufaUsuario;
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

  Future<bool> deleteEstufaUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteEstufaUsuario(id);
      _estufaUsuarios.removeWhere((eu) => eu.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
