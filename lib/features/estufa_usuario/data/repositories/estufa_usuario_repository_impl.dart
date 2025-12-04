import '../../domain/entities/estufa_usuario.dart';
import '../../domain/repositories/estufa_usuario_repository.dart';
import '../datasources/estufa_usuario_remote_datasource.dart';

class EstufaUsuarioRepositoryImpl implements EstufaUsuarioRepository {
  final EstufaUsuarioRemoteDataSource remoteDataSource;

  EstufaUsuarioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EstufaUsuario>> getEstufaUsuarios() async {
    return await remoteDataSource.getEstufaUsuarios();
  }

  @override
  Future<EstufaUsuario> getEstufaUsuario(String id) async {
    return await remoteDataSource.getEstufaUsuario(id);
  }

  @override
  Future<EstufaUsuario> createEstufaUsuario(Map<String, dynamic> data) async {
    return await remoteDataSource.createEstufaUsuario(data);
  }

  @override
  Future<EstufaUsuario> updateEstufaUsuario(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.updateEstufaUsuario(id, data);
  }

  @override
  Future<void> deleteEstufaUsuario(String id) async {
    await remoteDataSource.deleteEstufaUsuario(id);
  }
}
