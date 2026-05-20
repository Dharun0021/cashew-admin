class OrderItemModel {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'],
      name: json['name'],
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String date;
  final String status; // Pending, Packed, Shipped, Delivered, Cancelled
  final String paymentStatus; // Paid, Refunded, Unpaid
  final String paymentMethod;
  final double total;
  final List<OrderItemModel> items;
  final String shippingAddress;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.date,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.total,
    required this.items,
    required this.shippingAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<OrderItemModel> orderItems = itemsList.map((i) => OrderItemModel.fromJson(i)).toList();

    return OrderModel(
      id: json['id'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'] ?? '',
      date: json['date'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      paymentMethod: json['paymentMethod'],
      total: (json['total'] as num).toDouble(),
      items: orderItems,
      shippingAddress: json['shippingAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'date': date,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'total': total,
      'items': items.map((i) => i.toJson()).toList(),
      'shippingAddress': shippingAddress,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? date,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    double? total,
    List<OrderItemModel>? items,
    String? shippingAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      date: date ?? this.date,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }
}
