import 'package:flutter/material.dart';
import '../../domain/entities/user_product.dart';
import '../../data/datasources/user_product_remote_datasource.dart';

class UserProductProvider extends ChangeNotifier {
  final UserProductRemoteDataSource dataSource;

  UserProductProvider({required this.dataSource});

  void updateToken(String token) => dataSource.token = token;

  List<UserProduct> _members = [];
  List<UserProduct> get members => _members;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadMembers(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _members = await dataSource.getUsers(productId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addUser(String productId, String userId, String role) async {
    try {
      final m = await dataSource.addUser(productId, userId, role);
      _members.add(m);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> revokeAccess(String productId, String userId) async {
    try {
      await dataSource.revokeAccess(productId, userId);
      _members.removeWhere((m) => m.userId == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
