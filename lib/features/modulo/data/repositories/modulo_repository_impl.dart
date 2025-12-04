import '../../domain/entities/modulo.dart';
import '../../domain/repositories/modulo_repository.dart';
import '../datasources/modulo_remote_datasource.dart';

class ModuloRepositoryImpl implements ModuloRepository {
  final ModuloRemoteDataSource remoteDataSource;

  ModuloRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Modulo>> getModulosByEstufa(String estufaId, String token) async {
    return await remoteDataSource.getModulosByEstufa(estufaId, token);
  }

  @override
  Future<Modulo> getModulo(String id, String token) async {
    return await remoteDataSource.getModulo(id, token);
  }

  @override
  Future<Modulo> createModulo(Map<String, dynamic> data, String token) async {
    return await remoteDataSource.createModulo(data, token);
  }

  @override
  Future<Modulo> updateModulo(String id, Map<String, dynamic> data, String token) async {
    return await remoteDataSource.updateModulo(id, data, token);
  }

  @override
  Future<void> deleteModulo(String id, String token) async {
    await remoteDataSource.deleteModulo(id, token);
  }

  @override
  Future<Atuador> toggleAtuador(String moduloId, String atuadorId, bool estado, String token) async {
    return await remoteDataSource.toggleAtuador(moduloId, atuadorId, estado, token);
  }
}
