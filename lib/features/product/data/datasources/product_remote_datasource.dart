import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../../domain/entities/device_schedule.dart';
import '../../../../core/constants/api_constants.dart';

class ProductRemoteDataSource {
  final http.Client client;
  String token;

  ProductRemoteDataSource({required this.client, required this.token});

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
    if (body is Map && body.containsKey('items')) return body['items'] as List;
    return [];
  }

  Map<String, dynamic> _unwrapMap(http.Response r) {
    final body = _unwrap(r);
    if (body is Map<String, dynamic>) return body;
    return body as Map<String, dynamic>;
  }

  Future<List<Product>> getProducts() async {
    final r = await client.get(Uri.parse('${ApiConstants.baseUrl}/products'), headers: _headers);
    if (r.statusCode == 200) {
      return _unwrapList(r).map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<Product> getProduct(String id) async {
    final r = await client.get(Uri.parse('${ApiConstants.baseUrl}/products/$id'), headers: _headers);
    if (r.statusCode == 200) return Product.fromJson(_unwrapMap(r));
    throw Exception('Failed to load product');
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final r = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/products'),
      headers: _headers,
      body: json.encode(data),
    );
    if (r.statusCode == 201) return Product.fromJson(_unwrapMap(r));
    throw Exception('Failed to create product');
  }

  Future<Product> linkProduct(String code) async {
    final r = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/products/link'),
      headers: _headers,
      body: json.encode({'code': code}),
    );
    if (r.statusCode == 200 || r.statusCode == 201) return Product.fromJson(_unwrapMap(r));
    final err = _unwrap(r);
    throw Exception(err is Map ? err['message'] ?? 'Failed to link product' : 'Failed to link product');
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final r = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/products/$id'),
      headers: _headers,
      body: json.encode(data),
    );
    if (r.statusCode == 200) return Product.fromJson(_unwrapMap(r));
    throw Exception('Failed to update product');
  }

  Future<void> deleteProduct(String id) async {
    final r = await client.delete(Uri.parse('${ApiConstants.baseUrl}/products/$id'), headers: _headers);
    if (r.statusCode != 200 && r.statusCode != 204) throw Exception('Failed to delete product');
  }

  Future<Map<String, dynamic>> getRelayState(String productId) async {
    final r = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/relay'),
      headers: _headers,
    );
    if (r.statusCode == 200) return _unwrapMap(r);
    throw Exception('Failed to load relay state');
  }

  Future<Map<String, dynamic>> setRelayCycle(
      String productId, Map<String, dynamic> data) async {
    final r = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/relay/cycle'),
      headers: _headers,
      body: json.encode(data),
    );
    if (r.statusCode == 200) return _unwrapMap(r);
    throw Exception('Failed to set relay cycle');
  }

  Future<Map<String, dynamic>> updateInstanceConfig(
      String productId, String instanceId, Map<String, dynamic> data) async {
    final r = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/instances/$instanceId/config'),
      headers: _headers,
      body: json.encode(data),
    );
    if (r.statusCode == 200) return _unwrapMap(r);
    throw Exception('Failed to update instance config');
  }

  Future<List<DeviceSchedule>> getSchedules(String productId) async {
    final r = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/relay/schedules'),
      headers: _headers,
    );
    if (r.statusCode == 200) {
      return _unwrapList(r)
          .map((j) => DeviceSchedule.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load schedules');
  }

  Future<DeviceSchedule> createSchedule(
      String productId, Map<String, dynamic> data) async {
    final r = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/relay/schedules'),
      headers: _headers,
      body: json.encode(data),
    );
    if (r.statusCode == 200 || r.statusCode == 201) {
      return DeviceSchedule.fromJson(_unwrapMap(r));
    }
    throw Exception('Failed to create schedule');
  }

  Future<DeviceSchedule> updateSchedule(
      String productId, String scheduleId, Map<String, dynamic> data) async {
    final r = await client.patch(
      Uri.parse(
          '${ApiConstants.baseUrl}/products/$productId/relay/schedules/$scheduleId'),
      headers: _headers,
      body: json.encode(data),
    );
    if (r.statusCode == 200) return DeviceSchedule.fromJson(_unwrapMap(r));
    throw Exception('Failed to update schedule');
  }

  Future<void> deleteSchedule(String productId, String scheduleId) async {
    final r = await client.delete(
      Uri.parse(
          '${ApiConstants.baseUrl}/products/$productId/relay/schedules/$scheduleId'),
      headers: _headers,
    );
    if (r.statusCode != 200 && r.statusCode != 204) {
      throw Exception('Failed to delete schedule');
    }
  }

  // 'state': 'on' | 'off' | 'auto'
  Future<Map<String, dynamic>> setManual(
      String productId, String device, String state) async {
    final r = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/relay/manual'),
      headers: _headers,
      body: json.encode({'device': device, 'state': state}),
    );
    if (r.statusCode == 200) return _unwrapMap(r);
    throw Exception('Failed to set manual override');
  }
}
