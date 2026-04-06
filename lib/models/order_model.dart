import 'restaurant_model.dart';

class OrderItemModel {
  final String menuItemName;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.menuItemName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuItemName: json['menuItem'] ?? 'Unknown Item',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'menuItem': menuItemName, 'quantity': quantity, 'price': price};
  }
}

class OrderModel {
  final String id;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final RestaurantModel? restaurant;

  OrderModel({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.restaurant,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'PENDING',
      paymentStatus: json['paymentStatus'] ?? 'UNPAID',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      restaurant:
          json['restaurant'] != null &&
              json['restaurant'] is Map<String, dynamic>
          ? RestaurantModel.fromJson(json['restaurant'])
          : null,
    );
  }
}
