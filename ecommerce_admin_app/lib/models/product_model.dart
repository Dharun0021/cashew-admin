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
  final double kg;

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
    required this.kg,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '')?.toString() ?? '';
    final name = (json['productName'] ?? json['name'] ?? '')?.toString() ?? '';
    final sku = (json['productId'] ?? json['sku'] ?? '')?.toString() ?? '';
    final description = (json['description'] ?? '')?.toString() ?? '';
    final image = (json['image'] ?? '')?.toString() ?? '';
    
    double price = 0.0;
    if (json['amount'] != null) {
      price = (json['amount'] as num).toDouble();
    } else if (json['price'] != null) {
      price = (json['price'] as num).toDouble();
    }

    double? discountPrice;
    if (json['discountAmount'] != null) {
      discountPrice = (json['discountAmount'] as num).toDouble();
    } else if (json['discountPrice'] != null) {
      discountPrice = (json['discountPrice'] as num).toDouble();
    }

    final isFeatured = json['isFeatured'] == true;

    bool inStock = true;
    if (json['inStock'] != null) {
      inStock = json['inStock'] == true || json['inStock']?.toString() == 'true';
    }

    int stock = 0;
    if (json['stock'] != null) {
      stock = (json['stock'] as num).toInt();
    } else {
      stock = inStock ? 100 : 0;
    }

    String status = 'Active';
    if (json['status'] != null) {
      status = json['status'].toString();
    } else {
      status = inStock ? 'Active' : 'Out of Stock';
    }

    String categoryId = '';
    String categoryName = 'General';
    if (json['categoryId'] != null) {
      if (json['categoryId'] is Map) {
        final catMap = json['categoryId'] as Map<String, dynamic>;
        categoryId = (catMap['_id'] ?? catMap['id'] ?? '')?.toString() ?? '';
        categoryName = (catMap['categoryName'] ?? catMap['name'] ?? 'General')?.toString() ?? '';
      } else {
        categoryId = json['categoryId'].toString();
      }
    }
    if (json['category'] != null) {
      categoryName = json['category'].toString();
    }

    return ProductModel(
      id: id,
      name: name,
      sku: sku,
      category: categoryName,
      categoryId: categoryId,
      price: price,
      discountPrice: discountPrice,
      stock: stock,
      status: status,
      isFeatured: isFeatured,
      image: image,
      description: description,
      kg: (json['kg'] != null ? (json['kg'] as num).toDouble() : 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': name,
      'productId': sku,
      'categoryId': categoryId,
      'price': price,
      'discountPrice': discountPrice,
      'discountAmount': discountPrice ?? 0.0,
      'amount': price,
      'stock': stock,
      'inStock': stock > 0,
      'status': status,
      'isFeatured': isFeatured,
      'image': image,
      'description': description,
      'kg': kg,
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
    double? kg,
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
      kg: kg ?? this.kg,
    );
  }

  // Helper getters
  double get activePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  bool get isLowStock => stock > 0 && stock <= 10;
  bool get isOutOfStock => stock <= 0;
}
