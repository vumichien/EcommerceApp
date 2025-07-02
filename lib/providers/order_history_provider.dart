import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/Product.dart';
import '../constants.dart';
import 'product_provider.dart';

class OrderHistoryNotifier extends StateNotifier<List<Order>> {
  OrderHistoryNotifier() : super([]);

  void addOrder(List<CartItem> items, double totalAmount, double discountAmount,
      String? voucherCode) {
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
    return state
        .where((order) => order.status == OrderStatus.completed)
        .toList();
  }

  double get totalSpent {
    return completedOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  int get totalOrders {
    return completedOrders.length;
  }
}

// Provider for fake orders using real products
final fakeOrdersProvider = Provider<List<Order>>((ref) {
  final products = ref.watch(productsProvider);
  if (products.isEmpty) {
    // Return some basic orders even without products loaded
    final now = DateTime.now();
    return [
      Order(
        id: 20241201001,
        items: [],
        totalAmount: 0.0,
        discountAmount: 0.0,
        orderDate: now.subtract(const Duration(days: 2)),
        status: OrderStatus.completed,
      ),
    ];
  }

  final now = DateTime.now();

  // Ensure we have enough products for our orders
  final availableProducts = products.take(10).toList();

  // Create items for each order with safe indexing
  final order1Items = [
    CartItem(product: availableProducts[0], quantity: 2),
    if (availableProducts.length > 1)
      CartItem(product: availableProducts[1], quantity: 1),
    if (availableProducts.length > 2)
      CartItem(product: availableProducts[2], quantity: 1),
  ];

  final order2Items = [
    if (availableProducts.length > 3)
      CartItem(product: availableProducts[3], quantity: 1),
    if (availableProducts.length > 4)
      CartItem(product: availableProducts[4], quantity: 2),
    if (availableProducts.length <= 4)
      CartItem(product: availableProducts[0], quantity: 1),
  ];

  final order3Items = [
    if (availableProducts.length > 5)
      CartItem(product: availableProducts[5], quantity: 1)
    else
      CartItem(product: availableProducts[0], quantity: 1),
  ];

  final order4Items = [
    if (availableProducts.length > 6)
      CartItem(product: availableProducts[6], quantity: 3)
    else
      CartItem(product: availableProducts[0], quantity: 3),
    if (availableProducts.length > 7)
      CartItem(product: availableProducts[7], quantity: 1)
    else if (availableProducts.length > 1)
      CartItem(product: availableProducts[1], quantity: 1),
  ];

  final order5Items = [
    if (availableProducts.length > 8)
      CartItem(product: availableProducts[8], quantity: 1)
    else
      CartItem(product: availableProducts[0], quantity: 1),
    if (availableProducts.length > 9)
      CartItem(product: availableProducts[9], quantity: 2)
    else if (availableProducts.length > 1)
      CartItem(product: availableProducts[1], quantity: 2),
    if (availableProducts.length > 2)
      CartItem(product: availableProducts[2], quantity: 1),
  ];

  // Calculate total amounts based on actual product prices
  final order1Total =
      order1Items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  final order2Total =
      order2Items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  final order3Total =
      order3Items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  final order4Total =
      order4Items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  final order5Total =
      order5Items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  return [
    // Order 1 - Yesterday's order with multiple items
    Order(
      id: 20241201001,
      items: order1Items,
      totalAmount: order1Total - 500.0, // Apply discount
      discountAmount: 500.0,
      voucherCode: 'NEWCUSTOMER500',
      orderDate: now.subtract(const Duration(days: 1)),
      status: OrderStatus.completed,
    ),

    // Order 2 - 3 days ago order
    Order(
      id: 20241128002,
      items: order2Items,
      totalAmount: order2Total,
      discountAmount: 0.0,
      orderDate: now.subtract(const Duration(days: 3)),
      status: OrderStatus.completed,
    ),

    // Order 3 - Last week's single item order
    Order(
      id: 20241120003,
      items: order3Items,
      totalAmount: order3Total - 200.0, // Apply discount
      discountAmount: 200.0,
      voucherCode: 'SAVE200',
      orderDate: now.subtract(const Duration(days: 11)),
      status: OrderStatus.completed,
    ),

    // Order 4 - 2 weeks ago large order
    Order(
      id: 20241115004,
      items: order4Items,
      totalAmount: order4Total - 800.0, // Apply discount
      discountAmount: 800.0,
      voucherCode: 'BULK800',
      orderDate: now.subtract(const Duration(days: 16)),
      status: OrderStatus.completed,
    ),

    // Order 5 - Last month's order
    Order(
      id: 20241101005,
      items: order5Items,
      totalAmount: order5Total - 300.0, // Apply discount
      discountAmount: 300.0,
      voucherCode: 'MONTHLY300',
      orderDate: now.subtract(const Duration(days: 30)),
      status: OrderStatus.completed,
    ),
  ];
});

final orderHistoryProvider =
    StateNotifierProvider<OrderHistoryNotifier, List<Order>>((ref) {
  final notifier = OrderHistoryNotifier();

  // Initialize with fake orders when products are available
  ref.listen(productsProvider, (previous, next) {
    if (next.isNotEmpty && notifier.state.isEmpty) {
      final fakeOrders = ref.read(fakeOrdersProvider);
      notifier.state = fakeOrders;
    }
  });

  // Also try to initialize immediately
  final products = ref.read(productsProvider);
  if (products.isNotEmpty) {
    final fakeOrders = ref.read(fakeOrdersProvider);
    notifier.state = fakeOrders;
  }

  return notifier;
});
