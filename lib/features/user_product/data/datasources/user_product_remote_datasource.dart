import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/user_product.dart';
import '../../../../core/constants/api_constants.dart';

class UserProductRemoteDataSource {
  final http.Client client;
  String token;

  UserProductRemoteDataSource({required this.client, required this.token});

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

  Future<List<UserProduct>> getUsers(String productId) async {
    final r = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/users'),
      headers: _headers,
    );
    if (r.statusCode == 200) {
      return _unwrapList(r).map((j) => UserProduct.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load product users');
  }

  Future<UserProduct> addUser(String productId, String userId, String role) async {
    final r = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/users'),
      headers: _headers,
      body: json.encode({'userId': userId, 'role': role}),
    );
    if (r.statusCode == 201) return UserProduct.fromJson(_unwrap(r) as Map<String, dynamic>);
    throw Exception('Failed to add user');
  }

  Future<void> revokeAccess(String productId, String userId) async {
    final r = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/products/$productId/users/$userId'),
      headers: _headers,
    );
    if (r.statusCode != 200 && r.statusCode != 204) throw Exception('Failed to revoke access');
  }
}
