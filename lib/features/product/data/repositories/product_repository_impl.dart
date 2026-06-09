import '../../domain/entities/product.dart';
import '../../domain/entities/device_schedule.dart';
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
  Future<Product> createProduct(Map<String, dynamic> data) =>
      dataSource.createProduct(data);

  @override
  Future<Product> linkProduct(String code) => dataSource.linkProduct(code);

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> data) =>
      dataSource.updateProduct(id, data);

  @override
  Future<void> deleteProduct(String id) => dataSource.deleteProduct(id);

  @override
  Future<Map<String, dynamic>> getRelayState(String productId) =>
      dataSource.getRelayState(productId);

  @override
  Future<Map<String, dynamic>> updateInstanceConfig(
          String productId, String instanceId, Map<String, dynamic> data) =>
      dataSource.updateInstanceConfig(productId, instanceId, data);

  @override
  Future<List<DeviceSchedule>> getSchedules(String productId) =>
      dataSource.getSchedules(productId);

  @override
  Future<DeviceSchedule> createSchedule(
          String productId, Map<String, dynamic> data) =>
      dataSource.createSchedule(productId, data);

  @override
  Future<DeviceSchedule> updateSchedule(
          String productId, String scheduleId, Map<String, dynamic> data) =>
      dataSource.updateSchedule(productId, scheduleId, data);

  @override
  Future<void> deleteSchedule(String productId, String scheduleId) =>
      dataSource.deleteSchedule(productId, scheduleId);

  @override
  Future<Map<String, dynamic>> setManual(
          String productId, String device, String state) =>
      dataSource.setManual(productId, device, state);
}
