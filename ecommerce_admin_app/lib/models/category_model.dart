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
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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
