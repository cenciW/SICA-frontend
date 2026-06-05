import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  // For Android Emulator use 10.0.2.2, for Web/iOS use localhost
  // TODO: Move to config/env
  static const String baseUrl = 'http://192.168.1.103:3000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrap(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no login');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _unwrap(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no cadastro');
    }
  }

  Map<String, dynamic> _unwrap(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    if (decoded.containsKey('data') && decoded['data'] is Map) {
      return decoded['data'] as Map<String, dynamic>;
    }
    return decoded;
  }
}
