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
    this.kg = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '')?.toString() ?? '';
    final name = (json['productName'] ?? json['name'] ?? '')?.toString() ?? '';
    final sku = (json['productId'] ?? json['sku'] ?? '')?.toString() ?? '';
    final description = (json['description'] ?? '')?.toString() ?? '';
    final image = (json['image'] ?? '')?.toString() ?? '';
    
    // Parse price safely
    double price = 0.0;
    try {
      if (json['amount'] != null && json['amount'] != '') {
        price = (json['amount'] as num).toDouble();
      } else if (json['price'] != null && json['price'] != '') {
        price = (json['price'] as num).toDouble();
      }
    } catch (e) {
      price = 0.0;
    }

    // Parse discount price safely
    double? discountPrice;
    try {
      if (json['discountAmount'] != null && json['discountAmount'] != '') {
        discountPrice = (json['discountAmount'] as num).toDouble();
      } else if (json['discountPrice'] != null && json['discountPrice'] != '') {
        discountPrice = (json['discountPrice'] as num).toDouble();
      }
    } catch (e) {
      discountPrice = null;
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

    // Parse kg safely
    double kg = 0.0;
    try {
      if (json['kg'] != null && json['kg'] != '') {
        kg = (json['kg'] as num).toDouble();
      }
    } catch (e) {
      kg = 0.0;
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
      kg: kg,
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
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      image: image ?? this.image,
      description: description ?? this.description,
      kg: kg ?? this.kg,
    );
  }

  // Helper getters
  double get activePrice {
    if (discountPrice != null && discountPrice! > 0) {
      return discountPrice!;
    }
    return price > 0 ? price : 0.0;
  }
  
  bool get hasDiscount => discountPrice != null && discountPrice! > 0 && discountPrice! < price;
  bool get isLowStock => stock > 0 && stock <= 10;
  bool get isOutOfStock => stock <= 0;
}
