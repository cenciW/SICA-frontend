import '../entities/estufa_usuario.dart';

abstract class EstufaUsuarioRepository {
  Future<List<EstufaUsuario>> getEstufaUsuarios(String token);
  Future<EstufaUsuario> getEstufaUsuario(String id, String token);
  Future<EstufaUsuario> createEstufaUsuario(
      Map<String, dynamic> data, String token);
  Future<EstufaUsuario> updateEstufaUsuario(
      String id, Map<String, dynamic> data, String token);
  Future<void> deleteEstufaUsuario(String id, String token);
}
