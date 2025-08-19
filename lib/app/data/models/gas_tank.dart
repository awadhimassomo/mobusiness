class GasTank {
  final String id;
  final String gasType;  // e.g., 'LPG', 'Natural Gas'
  final double tankSize; // size in KG
  final double price;
  final int stockQuantity;
  final String businessId;

  GasTank({
    required this.id,
    required this.gasType,
    required this.tankSize,
    required this.price,
    required this.stockQuantity,
    required this.businessId,
  });

  factory GasTank.fromJson(Map<String, dynamic> json) {
    return GasTank(
      id: json['id'] as String,
      gasType: json['gasType'] as String,
      tankSize: (json['tankSize'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      businessId: json['businessId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gasType': gasType,
      'tankSize': tankSize,
      'price': price,
      'stockQuantity': stockQuantity,
      'businessId': businessId,
    };
  }
}
