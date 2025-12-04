import 'package:http/http.dart' as http;
import '../../../../core/network/api_response.dart';
import '../../domain/entities/estufa.dart';

class EstufaRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  EstufaRemoteDataSource({required this.baseUrl, required this.client});

  Future<List<Estufa>> getEstufas(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/estufas'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processListResponse<Estufa>(
        response,
        (json) => Estufa.fromJson(json),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Estufa> getEstufa(String id, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/estufas/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final apiResponse = ApiHelper.processResponse<Estufa>(
        response,
        (data) => Estufa.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Estufa> createEstufa(Map<String, dynamic> data, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/estufas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<Estufa>(
        response,
        (data) => Estufa.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Estufa> updateEstufa(
      String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/estufas/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody(data),
      );

      final apiResponse = ApiHelper.processResponse<Estufa>(
        response,
        (data) => Estufa.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<void> deleteEstufa(String id, String token) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/estufas/$id'),
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

  Future<Estufa> vincularEstufa(String codigo, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/estufas/vincular'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody({'codigo': codigo}),
      );

      final apiResponse = ApiHelper.processResponse<Estufa>(
        response,
        (data) => Estufa.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }

  Future<Estufa> toggleDevice(
      String id, String device, bool state, String token) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/estufas/$id/device'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ApiHelper.encodeBody({'device': device, 'state': state}),
      );

      final apiResponse = ApiHelper.processResponse<Estufa>(
        response,
        (data) => Estufa.fromJson(data),
      );

      return apiResponse.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ApiHelper.internalServerError);
    }
  }
}
