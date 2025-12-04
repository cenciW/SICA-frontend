import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_remote_datasource.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioRemoteDataSource remoteDataSource;

  UsuarioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Usuario>> getUsuarios() async {
    return await remoteDataSource.getUsuarios();
  }

  @override
  Future<Usuario> getUsuario(String id) async {
    return await remoteDataSource.getUsuario(id);
  }

  @override
  Future<Usuario> createUsuario(Map<String, dynamic> data) async {
    return await remoteDataSource.createUsuario(data);
  }

  @override
  Future<Usuario> updateUsuario(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.updateUsuario(id, data);
  }

  @override
  Future<void> deleteUsuario(String id) async {
    await remoteDataSource.deleteUsuario(id);
  }
}
