import 'package:http/http.dart' as http;
import '../../../../core/network/api_response.dart';
import '../../domain/entities/estufa_usuario.dart';

class EstufaUsuarioRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  EstufaUsuarioRemoteDataSource({required this.baseUrl, required this.client});

  Future<List<EstufaUsuario>> getEstufaUsuarios(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/estufa-usuarios'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processListResponse<EstufaUsuario>(
        response,
        (json) => EstufaUsuario.fromJson(json),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<EstufaUsuario> getEstufaUsuario(String id, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/estufa-usuarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processResponse<EstufaUsuario>(
        response,
        (data) => EstufaUsuario.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<EstufaUsuario> createEstufaUsuario(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/estufa-usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<EstufaUsuario>(
        response,
        (data) => EstufaUsuario.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<EstufaUsuario> updateEstufaUsuario(
      String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/estufa-usuarios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<EstufaUsuario>(
        response,
        (data) => EstufaUsuario.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<void> deleteEstufaUsuario(String id, String token) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/estufa-usuarios/$id'),
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
