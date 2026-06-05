import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/reading.dart';
import '../../../../core/constants/api_constants.dart';

class ReadingRemoteDataSource {
  final http.Client client;
  String token;

  ReadingRemoteDataSource({required this.client, required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  dynamic _unwrap(http.Response r) {
    final decoded = json.decode(r.body);
    if (decoded is Map && decoded.containsKey('data')) return decoded['data'];
    return decoded;
  }

  List<dynamic> _unwrapList(http.Response r) {
    final body = _unwrap(r);
    if (body is List) return body;
    return [];
  }

  Future<List<Reading>> getReadings(
    String productId, {
    SensorType? sensorType,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final params = <String, String>{};
    if (sensorType != null) params['sensor_type'] = sensorType.apiValue;
    if (from != null) params['from'] = from.toIso8601String();
    if (to != null) params['to'] = to.toIso8601String();
    if (limit != null) params['limit'] = limit.toString();

    final uri = Uri.parse('${ApiConstants.baseUrl}/products/$productId/readings')
        .replace(queryParameters: params.isNotEmpty ? params : null);
    final r = await client.get(uri, headers: _headers);
    if (r.statusCode == 200) {
      return _unwrapList(r).map((j) => Reading.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load readings');
  }

  Future<Map<String, dynamic>> getLatest(String productId) async {
    final r = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/readings/latest'),
      headers: _headers,
    );
    if (r.statusCode == 200) {
      final body = _unwrap(r);
      return body as Map<String, dynamic>;
    }
    throw Exception('Failed to load latest readings');
  }

  Future<Reading> createReading(String productId, Map<String, dynamic> data) async {
    final r = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/readings'),
      headers: _headers,
      body: json.encode(data),
    );
    if (r.statusCode == 201) {
      final body = _unwrap(r);
      return Reading.fromJson(body as Map<String, dynamic>);
    }
    throw Exception('Failed to create reading');
  }
}
