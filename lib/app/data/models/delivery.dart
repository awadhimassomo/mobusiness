import 'gas_tank.dart';

class Delivery {
  final String id;
  final String orderId;
  final String businessId;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String status; // assigned, in_progress, completed, cancelled
  final double currentLatitude;
  final double currentLongitude;
  final DateTime assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<DeliveryStatus> statusUpdates;
  final String customerName;
  final String deliveryAddress;
  final GasTank product;
  final int quantity;
  final double amount;

  Delivery({
    required this.id,
    required this.orderId,
    required this.businessId,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.status,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    required this.statusUpdates,
    required this.customerName,
    required this.deliveryAddress,
    required this.product,
    required this.quantity,
    required this.amount,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      businessId: json['businessId'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      driverPhone: json['driverPhone'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      status: json['status'] as String,
      currentLatitude: json['currentLatitude'] as double,
      currentLongitude: json['currentLongitude'] as double,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      statusUpdates: (json['statusUpdates'] as List)
          .map((status) => DeliveryStatus.fromJson(status))
          .toList(),
      customerName: json['customerName'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      product: GasTank.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'businessId': businessId,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'status': status,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'assignedAt': assignedAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'statusUpdates': statusUpdates.map((status) => status.toJson()).toList(),
      'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      'product': product.toJson(),
      'quantity': quantity,
      'amount': amount,
    };
  }
}

class DeliveryStatus {
  final String status;
  final String description;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;

  DeliveryStatus({
    required this.status,
    required this.description,
    required this.timestamp,
    this.latitude,
    this.longitude,
  });

  factory DeliveryStatus.fromJson(Map<String, dynamic> json) {
    return DeliveryStatus(
      status: json['status'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
