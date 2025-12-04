import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/estufa_usuario.dart';

class EstufaUsuarioRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  EstufaUsuarioRemoteDataSource({required this.baseUrl, required this.client});

  Future<List<EstufaUsuario>> getEstufaUsuarios() async {
    final response = await client.get(Uri.parse('$baseUrl/estufa-usuarios'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EstufaUsuario.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load estufa usuarios');
    }
  }

  Future<EstufaUsuario> getEstufaUsuario(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/estufa-usuarios/$id'));

    if (response.statusCode == 200) {
      return EstufaUsuario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load estufa usuario');
    }
  }

  Future<EstufaUsuario> createEstufaUsuario(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/estufa-usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return EstufaUsuario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create estufa usuario');
    }
  }

  Future<EstufaUsuario> updateEstufaUsuario(String id, Map<String, dynamic> data) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/estufa-usuarios/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return EstufaUsuario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update estufa usuario');
    }
  }

  Future<void> deleteEstufaUsuario(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/estufa-usuarios/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete estufa usuario');
    }
  }
}
