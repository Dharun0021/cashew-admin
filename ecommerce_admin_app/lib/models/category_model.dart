class CategoryModel {
  final String id;
  final String name;
  final String image;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.productCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Handle different API response formats
    final id = (json['_id'] ?? json['id'] ?? '')?.toString() ?? '';
    final name = (json['categoryName'] ?? json['name'] ?? '')?.toString() ?? '';
    final image = (json['image'] ?? '')?.toString() ?? '';
    final productCount = (json['productCount'] as num?)?.toInt() ?? 0;

    return CategoryModel(
      id: id,
      name: name,
      image: image,
      productCount: productCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': name,
      'image': image,
      'productCount': productCount,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    int? productCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      productCount: productCount ?? this.productCount,
    );
  }
}
