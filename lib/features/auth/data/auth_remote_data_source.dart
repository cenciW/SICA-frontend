import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _unwrap(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Falha no login');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _unwrap(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Falha no cadastro');
      }
    } catch (e) {
      rethrow;
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
