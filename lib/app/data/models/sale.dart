class Sale {
  final String id;
  final String businessId;
  final String productId;
  final int quantity;
  final double amount;
  final String? notes;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.businessId,
    required this.productId,
    required this.quantity,
    required this.amount,
    this.notes,
    required this.createdAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'productId': productId,
      'quantity': quantity,
      'amount': amount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
