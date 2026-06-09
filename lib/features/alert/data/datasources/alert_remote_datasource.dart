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

  Future<({List<ProductAlert> items, int total, bool hasMore})> getAlerts(
    String productId, {
    bool onlyActive = true,
    int take = 5,
    int skip = 0,
  }) async {
    final params = <String, String>{
      if (onlyActive) 'resolved': 'false',
      'take': '$take',
      'skip': '$skip',
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}/products/$productId/alerts')
        .replace(queryParameters: params);
    final r = await client.get(uri, headers: _headers);
    if (r.statusCode == 200) {
      final body = json.decode(r.body);
      final data = body is Map && body.containsKey('data') ? body['data'] : body;
      final List items = data['items'] as List? ?? [];
      final int total = data['total'] as int? ?? 0;
      final bool hasMore = data['hasMore'] as bool? ?? false;
      return (
        items: items.map((j) => ProductAlert.fromJson(j as Map<String, dynamic>)).toList(),
        total: total,
        hasMore: hasMore,
      );
    }
    throw Exception('Failed to load alerts');
  }

  Future<int> resolveAll(String productId) async {
    final r = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/alerts/resolve-all'),
      headers: _headers,
    );
    if (r.statusCode == 200) {
      final body = json.decode(r.body);
      final data = body is Map && body.containsKey('data') ? body['data'] : body;
      return data['resolved'] as int? ?? 0;
    }
    throw Exception('Failed to resolve all alerts');
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
