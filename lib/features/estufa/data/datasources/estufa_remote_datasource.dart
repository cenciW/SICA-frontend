import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/estufa.dart';

class EstufaRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  EstufaRemoteDataSource({required this.baseUrl, required this.client});

  Future<List<Estufa>> getEstufas(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/estufas'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Estufa.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load estufas');
    }
  }

  Future<Estufa> getEstufa(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/estufas/$id'));

    if (response.statusCode == 200) {
      return Estufa.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load estufa');
    }
  }

  Future<Estufa> createEstufa(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/estufas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return Estufa.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create estufa');
    }
  }

  Future<Estufa> updateEstufa(String id, Map<String, dynamic> data, String token) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/estufas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return Estufa.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update estufa');
    }
  }

  Future<void> deleteEstufa(String id, String token) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/estufas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete estufa');
    }
  }

  Future<void> vincularEstufa(String codigo, String token) async {
    final response = await client.post(
      Uri.parse('$baseUrl/estufas/vincular'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'codigo': codigo}),
    );

    if (response.statusCode != 201) {
      throw Exception(json.decode(response.body)['message'] ?? 'Falha ao vincular estufa');
    }
  }

  Future<Estufa> toggleDevice(String id, String device, bool state, String token) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/estufas/$id/device'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'device': device, 'state': state}),
    );

    if (response.statusCode == 200) {
      return Estufa.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to toggle device');
    }
  }
}
