class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalOrders;
  final double totalSpend;
  final String status; // Active, Inactive
  final String avatar;
  final String joinDate;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalOrders,
    required this.totalSpend,
    required this.status,
    required this.avatar,
    required this.joinDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      totalSpend: (json['totalSpend'] as num).toDouble(),
      status: json['status'] ?? 'Active',
      avatar: json['avatar'] ?? '',
      joinDate: json['joinDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'totalOrders': totalOrders,
      'totalSpend': totalSpend,
      'status': status,
      'avatar': avatar,
      'joinDate': joinDate,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? totalOrders,
    double? totalSpend,
    String? status,
    String? avatar,
    String? joinDate,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpend: totalSpend ?? this.totalSpend,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
