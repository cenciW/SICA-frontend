import '../entities/estufa_usuario.dart';

abstract class EstufaUsuarioRepository {
  Future<List<EstufaUsuario>> getEstufaUsuarios();
  Future<EstufaUsuario> getEstufaUsuario(String id);
  Future<EstufaUsuario> createEstufaUsuario(Map<String, dynamic> data);
  Future<EstufaUsuario> updateEstufaUsuario(String id, Map<String, dynamic> data);
  Future<void> deleteEstufaUsuario(String id);
}
