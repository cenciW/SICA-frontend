import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/usuario.dart';

class UsuarioRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  UsuarioRemoteDataSource({required this.baseUrl, required this.client});

  Future<List<Usuario>> getUsuarios() async {
    final response = await client.get(Uri.parse('$baseUrl/usuarios'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load usuarios');
    }
  }

  Future<Usuario> getUsuario(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/usuarios/$id'));

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load usuario');
    }
  }

  Future<Usuario> createUsuario(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create usuario');
    }
  }

  Future<Usuario> updateUsuario(String id, Map<String, dynamic> data) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update usuario');
    }
  }

  Future<void> deleteUsuario(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/usuarios/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete usuario');
    }
  }
}
