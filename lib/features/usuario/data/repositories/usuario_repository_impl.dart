import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_remote_datasource.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioRemoteDataSource remoteDataSource;

  UsuarioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Usuario>> getUsuarios(String token) async {
    return await remoteDataSource.getUsuarios(token);
  }

  @override
  Future<Usuario> getUsuario(String id, String token) async {
    return await remoteDataSource.getUsuario(id, token);
  }

  @override
  Future<Usuario> createUsuario(Map<String, dynamic> data, String token) async {
    return await remoteDataSource.createUsuario(data, token);
  }

  @override
  Future<Usuario> updateUsuario(
      String id, Map<String, dynamic> data, String token) async {
    return await remoteDataSource.updateUsuario(id, data, token);
  }

  @override
  Future<void> deleteUsuario(String id, String token) async {
    await remoteDataSource.deleteUsuario(id, token);
  }
}
