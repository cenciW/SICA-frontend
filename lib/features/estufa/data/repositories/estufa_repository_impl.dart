import '../../domain/entities/estufa.dart';
import '../../domain/repositories/estufa_repository.dart';
import '../datasources/estufa_remote_datasource.dart';

class EstufaRepositoryImpl implements EstufaRepository {
  final EstufaRemoteDataSource remoteDataSource;

  EstufaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Estufa>> getEstufas(String token) async {
    return await remoteDataSource.getEstufas(token);
  }

  @override
  Future<Estufa> getEstufa(String id) async {
    return await remoteDataSource.getEstufa(id);
  }

  @override
  Future<Estufa> createEstufa(Map<String, dynamic> data) async {
    return await remoteDataSource.createEstufa(data);
  }

  @override
  Future<Estufa> updateEstufa(String id, Map<String, dynamic> data, String token) async {
    return await remoteDataSource.updateEstufa(id, data, token);
  }

  @override
  Future<void> deleteEstufa(String id, String token) async {
    await remoteDataSource.deleteEstufa(id, token);
  }

  @override
  Future<void> vincularEstufa(String codigo, String token) async {
    await remoteDataSource.vincularEstufa(codigo, token);
  }

  @override
  Future<Estufa> toggleDevice(String id, String device, bool state, String token) async {
    return await remoteDataSource.toggleDevice(id, device, state, token);
  }
}
