import '../entities/estufa.dart';

abstract class EstufaRepository {
  Future<List<Estufa>> getEstufas(String token);
  Future<Estufa> getEstufa(String id, String token);
  Future<Estufa> createEstufa(Map<String, dynamic> data, String token);
  Future<Estufa> updateEstufa(
      String id, Map<String, dynamic> data, String token);
  Future<void> deleteEstufa(String id, String token);
  Future<Estufa> vincularEstufa(String codigo, String token);
  Future<Estufa> toggleDevice(
      String id, String device, bool state, String token);
}
