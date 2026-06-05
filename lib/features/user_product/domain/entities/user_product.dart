enum ProductRole { OWNER, VIEWER }

class UserProduct {
  final String id;
  final String productId;
  final String userId;
  final ProductRole role;
  final DateTime accessStart;
  final DateTime? accessEnd;
  final String? userEmail;
  final String? userName;
  final String? userFullName;

  UserProduct({
    required this.id,
    required this.productId,
    required this.userId,
    required this.role,
    required this.accessStart,
    this.accessEnd,
    this.userEmail,
    this.userName,
    this.userFullName,
  });

  factory UserProduct.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return UserProduct(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] == 'OWNER' ? ProductRole.OWNER : ProductRole.VIEWER,
      accessStart: json['access_start'] != null
          ? DateTime.parse(json['access_start'] as String).toLocal()
          : DateTime.now(),
      accessEnd: json['access_end'] != null
          ? DateTime.parse(json['access_end'] as String).toLocal()
          : null,
      userEmail: user?['email'] as String?,
      userName: user?['username'] as String?,
      userFullName: user?['full_name'] as String?,
    );
  }
}
