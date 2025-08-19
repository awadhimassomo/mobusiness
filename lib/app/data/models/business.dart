import 'package:mobussiness/app/data/models/product.dart';

class Business {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final List<Product> products;
  final DateTime createdAt;
  final String? logo;
  final BusinessStatus status;
  final BusinessType type;

  Business({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.products,
    required this.createdAt,
    this.logo,
    this.status = BusinessStatus.active,
    this.type = BusinessType.retailer,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      products: (json['products'] as List?)
          ?.map((p) => Product.fromJson(p))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      logo: json['logo'],
      status: BusinessStatus.values.firstWhere(
        (e) => e.toString() == 'BusinessStatus.${json['status']}',
        orElse: () => BusinessStatus.active,
      ),
      type: BusinessType.values.firstWhere(
        (e) => e.toString() == 'BusinessType.${json['type']}',
        orElse: () => BusinessType.retailer,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'products': products.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'logo': logo,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
    };
  }

  Business copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    List<Product>? products,
    DateTime? createdAt,
    String? logo,
    BusinessStatus? status,
    BusinessType? type,
  }) {
    return Business(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      logo: logo ?? this.logo,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}

class GasTank {
  final String id;
  final String name;
  final double size; // in KG
  final GasType type;
  final double price;
  final int stockQuantity;
  final String? description;
  final String? image;

  GasTank({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.price,
    required this.stockQuantity,
    this.description,
    this.image,
  });

  factory GasTank.fromJson(Map<String, dynamic> json) {
    return GasTank(
      id: json['id'],
      name: json['name'],
      size: json['size'].toDouble(),
      type: GasType.values.firstWhere(
        (e) => e.toString() == 'GasType.${json['type']}',
        orElse: () => GasType.lpg,
      ),
      price: json['price'].toDouble(),
      stockQuantity: json['stock_quantity'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'type': type.toString().split('.').last,
      'price': price,
      'stock_quantity': stockQuantity,
      'description': description,
      'image': image,
    };
  }

  GasTank copyWith({
    String? id,
    String? name,
    double? size,
    GasType? type,
    double? price,
    int? stockQuantity,
    String? description,
    String? image,
  }) {
    return GasTank(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      type: type ?? this.type,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}

enum BusinessStatus {
  active,
  inactive,
  suspended,
  pending
}

enum BusinessType {
  retailer,
  wholesaler,
  distributor,
  manufacturer
}

enum GasType {
  lpg,
  natural,
  propane,
  butane
}
