import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(String id);
  Future<Product> createProduct(Map<String, dynamic> data);
  Future<Product> linkProduct(String code);
  Future<Product> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
  Future<Map<String, dynamic>> getRelayState(String productId);
  Future<Map<String, dynamic>> setRelayCycle(
      String productId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateInstanceConfig(
      String productId, String instanceId, Map<String, dynamic> data);
}
