import '../entities/modulo.dart';

abstract class ModuloRepository {
  Future<List<Modulo>> getModulosByEstufa(String estufaId, String token);
  Future<Modulo> getModulo(String id, String token);
  Future<Modulo> createModulo(Map<String, dynamic> data, String token);
  Future<Modulo> updateModulo(String id, Map<String, dynamic> data, String token);
  Future<void> deleteModulo(String id, String token);
  Future<Atuador> toggleAtuador(String moduloId, String atuadorId, bool estado, String token);
}
