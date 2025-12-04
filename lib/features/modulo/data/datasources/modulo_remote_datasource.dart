import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/modulo.dart';

class ModuloRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://localhost:3000';

  ModuloRemoteDataSource(this.client);

  Future<List<Modulo>> getModulosByEstufa(String estufaId, String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/modulos/estufa/$estufaId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Modulo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load modules');
    }
  }

  Future<Modulo> getModulo(String id, String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/modulos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Modulo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load module');
    }
  }

  Future<Modulo> createModulo(Map<String, dynamic> data, String token) async {
    final response = await client.post(
      Uri.parse('$baseUrl/modulos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return Modulo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create module');
    }
  }

  Future<Modulo> updateModulo(String id, Map<String, dynamic> data, String token) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/modulos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return Modulo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update module');
    }
  }

  Future<void> deleteModulo(String id, String token) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/modulos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete module');
    }
  }

  Future<Atuador> toggleAtuador(
      String moduloId, String atuadorId, bool estado, String token) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/modulos/$moduloId/atuadores/$atuadorId/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'estado': estado}),
    );

    if (response.statusCode == 200) {
      return Atuador.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to toggle actuator');
    }
  }
}
