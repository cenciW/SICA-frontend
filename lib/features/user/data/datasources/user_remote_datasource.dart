import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import '../../../../core/constants/api_constants.dart';

class UserRemoteDataSource {
  final http.Client client;
  String token;

  UserRemoteDataSource({required this.client, required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<User>> getUsers() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> list = body is List ? body : body['data'] ?? [];
      return list.map((j) => User.fromJson(j)).toList();
    }
    throw Exception('Failed to load users');
  }

  Future<User> getUser(String id) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return User.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to load user');
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/users'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      return User.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to create user');
  }

  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/users/$id'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return User.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to update user');
  }

  Future<void> deleteUser(String id) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/users/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
