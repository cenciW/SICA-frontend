import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_response.dart';

class AuthRemoteDataSource {
  static const String baseUrl = 'http://192.168.1.104:3000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final apiResponse = ApiHelper.processResponse<Map<String, dynamic>>(
        response,
        (data) => data as Map<String, dynamic>,
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      final apiResponse = ApiHelper.processResponse<Map<String, dynamic>>(
        response,
        (data) => data as Map<String, dynamic>,
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }
}
