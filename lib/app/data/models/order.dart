class Order {
  final String id;
  final String businessId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double customerLatitude;
  final double customerLongitude;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // pending, confirmed, delivering, delivered, cancelled
  final DateTime createdAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLatitude,
    required this.customerLongitude,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerAddress: json['customerAddress'] as String,
      customerLatitude: json['customerLatitude'] as double,
      customerLongitude: json['customerLongitude'] as double,
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: json['totalAmount'] as double,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerLatitude': customerLatitude,
      'customerLongitude': customerLongitude,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? businessId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    double? customerLatitude,
    double? customerLongitude,
    List<OrderItem>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}

class OrderItem {
  final String productId;
  final String gasType;
  final int tankSize;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.gasType,
    required this.tankSize,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      gasType: json['gasType'] as String,
      tankSize: json['tankSize'] as int,
      quantity: json['quantity'] as int,
      pricePerUnit: json['pricePerUnit'] as double,
      totalPrice: json['totalPrice'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'gasType': gasType,
      'tankSize': tankSize,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
    };
  }
}
