import 'package:http/http.dart' as http;
import '../../../../core/network/api_response.dart';
import '../../domain/entities/usuario.dart';

class UsuarioRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  UsuarioRemoteDataSource({required this.baseUrl, required this.client});

  Future<List<Usuario>> getUsuarios(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processListResponse<Usuario>(
        response,
        (json) => Usuario.fromJson(json),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Usuario> getUsuario(String id, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processResponse<Usuario>(
        response,
        (data) => Usuario.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Usuario> createUsuario(Map<String, dynamic> data, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<Usuario>(
        response,
        (data) => Usuario.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Usuario> updateUsuario(
      String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<Usuario>(
        response,
        (data) => Usuario.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<void> deleteUsuario(String id, String token) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      ApiHelper.processResponse(response, null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }
}
