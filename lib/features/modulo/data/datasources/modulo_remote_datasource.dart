import 'package:http/http.dart' as http;
import '../../../../core/network/api_response.dart';
import '../../domain/entities/modulo.dart';

class ModuloRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://192.168.1.104:3000';

  ModuloRemoteDataSource(this.client);

  Future<List<Modulo>> getModulosByEstufa(String estufaId, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/modulos/estufa/$estufaId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processListResponse<Modulo>(
        response,
        (json) => Modulo.fromJson(json),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Modulo> getModulo(String id, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/modulos/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processResponse<Modulo>(
        response,
        (data) => Modulo.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Modulo> createModulo(Map<String, dynamic> data, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/modulos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<Modulo>(
        response,
        (data) => Modulo.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Modulo> updateModulo(
      String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/modulos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<Modulo>(
        response,
        (data) => Modulo.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<void> deleteModulo(String id, String token) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/modulos/$id'),
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

  Future<Atuador> toggleAtuador(
      String moduloId, String atuadorId, bool estado, String token) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/modulos/$moduloId/atuadores/$atuadorId/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody({'estado': estado}),
      );

      final apiResponse = ApiHelper.processResponse<Atuador>(
        response,
        (data) => Atuador.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }
}
