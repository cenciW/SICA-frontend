import '../../domain/entities/estufa_usuario.dart';
import '../../domain/repositories/estufa_usuario_repository.dart';
import '../datasources/estufa_usuario_remote_datasource.dart';

class EstufaUsuarioRepositoryImpl implements EstufaUsuarioRepository {
  final EstufaUsuarioRemoteDataSource remoteDataSource;

  EstufaUsuarioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EstufaUsuario>> getEstufaUsuarios(String token) async {
    return await remoteDataSource.getEstufaUsuarios(token);
  }

  @override
  Future<EstufaUsuario> getEstufaUsuario(String id, String token) async {
    return await remoteDataSource.getEstufaUsuario(id, token);
  }

  @override
  Future<EstufaUsuario> createEstufaUsuario(
      Map<String, dynamic> data, String token) async {
    return await remoteDataSource.createEstufaUsuario(data, token);
  }

  @override
  Future<EstufaUsuario> updateEstufaUsuario(
      String id, Map<String, dynamic> data, String token) async {
    return await remoteDataSource.updateEstufaUsuario(id, data, token);
  }

  @override
  Future<void> deleteEstufaUsuario(String id, String token) async {
    await remoteDataSource.deleteEstufaUsuario(id, token);
  }
}
