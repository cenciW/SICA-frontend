import '../entities/product.dart';
import '../entities/device_schedule.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(String id);
  Future<Product> createProduct(Map<String, dynamic> data);
  Future<Product> linkProduct(String code);
  Future<Product> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
  Future<Map<String, dynamic>> getRelayState(String productId);
  Future<Map<String, dynamic>> updateInstanceConfig(
      String productId, String instanceId, Map<String, dynamic> data);
  // Schedules
  Future<List<DeviceSchedule>> getSchedules(String productId);
  Future<DeviceSchedule> createSchedule(
      String productId, Map<String, dynamic> data);
  Future<DeviceSchedule> updateSchedule(
      String productId, String scheduleId, Map<String, dynamic> data);
  Future<void> deleteSchedule(String productId, String scheduleId);
  // Manual override
  Future<Map<String, dynamic>> setManual(
      String productId, String device, String state);
}
