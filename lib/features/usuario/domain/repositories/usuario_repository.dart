import '../entities/usuario.dart';

abstract class UsuarioRepository {
  Future<List<Usuario>> getUsuarios();
  Future<Usuario> getUsuario(String id);
  Future<Usuario> createUsuario(Map<String, dynamic> data);
  Future<Usuario> updateUsuario(String id, Map<String, dynamic> data);
  Future<void> deleteUsuario(String id);
}
