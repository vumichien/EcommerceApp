import 'cart_item.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  completed,
  cancelled,
}

class Order {
  final int id;
  final List<CartItem> items;
  final double totalAmount;
  final double discountAmount;
  final String? voucherCode;
  final DateTime orderDate;
  final OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    this.voucherCode,
    required this.orderDate,
    required this.status,
  });

  double get subtotal => totalAmount + discountAmount;
  
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    int? id,
    List<CartItem>? items,
    double? totalAmount,
    double? discountAmount,
    String? voucherCode,
    DateTime? orderDate,
    OrderStatus? status,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      voucherCode: voucherCode ?? this.voucherCode,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
    );
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}