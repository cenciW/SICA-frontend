import '../entities/estufa.dart';

abstract class EstufaRepository {
  Future<List<Estufa>> getEstufas(String token);
  Future<Estufa> getEstufa(String id);
  Future<Estufa> createEstufa(Map<String, dynamic> data);
  Future<Estufa> updateEstufa(String id, Map<String, dynamic> data, String token);
  Future<void> deleteEstufa(String id, String token);
  Future<void> vincularEstufa(String codigo, String token);
  Future<Estufa> toggleDevice(String id, String device, bool state, String token);
}
