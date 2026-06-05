import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUser(String id);
  Future<User> createUser(Map<String, dynamic> data);
  Future<User> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
}
