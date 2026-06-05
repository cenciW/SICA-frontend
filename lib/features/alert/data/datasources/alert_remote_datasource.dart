import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/alert.dart';
import '../../../../core/constants/api_constants.dart';

class AlertRemoteDataSource {
  final http.Client client;
  String token;

  AlertRemoteDataSource({required this.client, required this.token});

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

  Future<List<ProductAlert>> getAlerts(String productId, {bool onlyActive = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/$productId/alerts')
        .replace(queryParameters: onlyActive ? {'resolved': 'false'} : null);
    final r = await client.get(uri, headers: _headers);
    if (r.statusCode == 200) {
      return _unwrapList(r).map((j) => ProductAlert.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load alerts');
  }

  Future<ProductAlert> resolveAlert(String productId, String alertId) async {
    final r = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/alerts/$alertId/resolve'),
      headers: _headers,
    );
    if (r.statusCode == 200) return ProductAlert.fromJson(_unwrap(r) as Map<String, dynamic>);
    throw Exception('Failed to resolve alert');
  }
}
