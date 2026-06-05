import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource dataSource;

  UserRepositoryImpl({required this.dataSource});

  @override
  Future<List<User>> getUsers() => dataSource.getUsers();

  @override
  Future<User> getUser(String id) => dataSource.getUser(id);

  @override
  Future<User> createUser(Map<String, dynamic> data) => dataSource.createUser(data);

  @override
  Future<User> updateUser(String id, Map<String, dynamic> data) => dataSource.updateUser(id, data);

  @override
  Future<void> deleteUser(String id) => dataSource.deleteUser(id);
}
