class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String businessId;
  final String? imageUrl;
  final Map<String, dynamic>? attributes; // For any additional product-specific attributes

  Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.stockQuantity,
    required this.businessId,
    this.imageUrl,
    this.attributes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      businessId: json['businessId'] as String,
      imageUrl: json['imageUrl'] as String?,
      attributes: json['attributes'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity,
      'businessId': businessId,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (attributes != null) 'attributes': attributes,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? businessId,
    String? imageUrl,
    Map<String, dynamic>? attributes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      businessId: businessId ?? this.businessId,
      imageUrl: imageUrl ?? this.imageUrl,
      attributes: attributes ?? this.attributes,
    );
  }
}
