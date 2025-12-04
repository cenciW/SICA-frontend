import '../entities/usuario.dart';

abstract class UsuarioRepository {
  Future<List<Usuario>> getUsuarios(String token);
  Future<Usuario> getUsuario(String id, String token);
  Future<Usuario> createUsuario(Map<String, dynamic> data, String token);
  Future<Usuario> updateUsuario(
      String id, Map<String, dynamic> data, String token);
  Future<void> deleteUsuario(String id, String token);
}
