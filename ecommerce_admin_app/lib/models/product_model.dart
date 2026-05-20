class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String categoryId;
  final double price;
  final double? discountPrice;
  final int stock;
  final String status; // Active, Inactive, Out of Stock
  final bool isFeatured;
  final String image;
  final String description;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.categoryId,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.status,
    required this.isFeatured,
    required this.image,
    required this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      category: json['category'],
      categoryId: json['categoryId'],
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      stock: json['stock'] as int,
      status: json['status'],
      isFeatured: json['isFeatured'] as bool,
      image: json['image'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'categoryId': categoryId,
      'price': price,
      'discountPrice': discountPrice,
      'stock': stock,
      'status': status,
      'isFeatured': isFeatured,
      'image': image,
      'description': description,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    String? categoryId,
    double? price,
    double? discountPrice,
    int? stock,
    String? status,
    bool? isFeatured,
    String? image,
    String? description,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      discountPrice: discountPrice != null ? discountPrice : this.discountPrice, // Let it be null-friendly if not updated
      stock: stock ?? this.stock,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }

  // Helper getters
  double get activePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  bool get isLowStock => stock > 0 && stock <= 10;
  bool get isOutOfStock => stock <= 0;
}
