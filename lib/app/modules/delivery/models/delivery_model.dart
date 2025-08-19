import '../../../../app/data/models/product.dart';

class Delivery {
  final String id;
  final String businessId;
  final Product product;
  final int quantity;
  final double amount;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  Delivery({
    required this.id,
    required this.businessId,
    required this.product,
    required this.quantity,
    required this.amount,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      amount: (json['amount'] as num).toDouble(),
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'product': product.toJson(),
      'quantity': quantity,
      'amount': amount,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
