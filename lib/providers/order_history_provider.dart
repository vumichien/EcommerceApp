import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/Product.dart';
import '../constants.dart';

class OrderHistoryNotifier extends StateNotifier<List<Order>> {
  OrderHistoryNotifier() : super(_generateFakeOrders());

  void addOrder(List<CartItem> items, double totalAmount, double discountAmount, String? voucherCode) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch,
      items: items,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      voucherCode: voucherCode,
      orderDate: DateTime.now(),
      status: OrderStatus.completed,
    );
    
    state = [order, ...state];
  }

  void updateOrderStatus(int orderId, OrderStatus status) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: status);
      }
      return order;
    }).toList();
  }

  List<Order> get completedOrders {
    return state.where((order) => order.status == OrderStatus.completed).toList();
  }

  double get totalSpent {
    return completedOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  int get totalOrders {
    return completedOrders.length;
  }

  static List<Order> _generateFakeOrders() {
    final now = DateTime.now();
    
    return [
      // Order 1 - Recent order with multiple items
      Order(
        id: 20241201001,
        items: [
          CartItem(product: products[0], quantity: 2), // NMN 10000mg Ultra
          CartItem(product: products[2], quantity: 1), // Broccoli Sprout Extract
          CartItem(product: products[4], quantity: 1), // Glutathione Complex
        ],
        totalAmount: 11200.0, // (4400*2) + 3600 + 2800 - 400 discount
        discountAmount: 400.0,
        voucherCode: 'SAVE400',
        orderDate: now.subtract(const Duration(days: 2)),
        status: OrderStatus.completed,
      ),
      
      // Order 2 - Last week's order
      Order(
        id: 20241125002,
        items: [
          CartItem(product: products[1], quantity: 1), // Arginine & Citrulline
          CartItem(product: products[3], quantity: 2), // Sun Protection Plus
        ],
        totalAmount: 9900.0, // 5200 + (4200*2) + 200 tax
        discountAmount: 0.0,
        orderDate: now.subtract(const Duration(days: 8)),
        status: OrderStatus.completed,
      ),
      
      // Order 3 - Last month's single item order
      Order(
        id: 20241110003,
        items: [
          CartItem(product: products[5], quantity: 1), // Magnesium Glycinate
        ],
        totalAmount: 3100.0,
        discountAmount: 100.0,
        voucherCode: 'FIRST100',
        orderDate: now.subtract(const Duration(days: 20)),
        status: OrderStatus.completed,
      ),
    ];
  }
}

final orderHistoryProvider = StateNotifierProvider<OrderHistoryNotifier, List<Order>>((ref) {
  return OrderHistoryNotifier();
});