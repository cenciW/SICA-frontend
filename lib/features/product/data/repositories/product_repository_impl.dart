import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource dataSource;

  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> getProducts() => dataSource.getProducts();

  @override
  Future<Product> getProduct(String id) => dataSource.getProduct(id);

  @override
  Future<Product> createProduct(Map<String, dynamic> data) => dataSource.createProduct(data);

  @override
  Future<Product> linkProduct(String code) => dataSource.linkProduct(code);

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> data) =>
      dataSource.updateProduct(id, data);

  @override
  Future<void> deleteProduct(String id) => dataSource.deleteProduct(id);

  @override
  Future<Map<String, dynamic>> toggleRelay(String id, String device, bool state) =>
      dataSource.toggleRelay(id, device, state);

  @override
  Future<Map<String, dynamic>> updateInstanceConfig(
          String productId, String instanceId, Map<String, dynamic> data) =>
      dataSource.updateInstanceConfig(productId, instanceId, data);
}
