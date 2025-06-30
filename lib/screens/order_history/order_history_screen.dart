import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../utils/app_localizations.dart';
import '../../providers/order_history_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order.dart';
import '../cart/cart_screen.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderHistoryProvider);
    final completedOrders = _getFilteredOrders(orders
        .where((order) => order.status == OrderStatus.completed)
        .toList());

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Text(
          ref.tr('order_history'),
          style: const TextStyle(
            color: kTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: kTextColor),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: completedOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: kTextLightColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ref.tr('no_orders_found'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: kTextLightColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.tr('try_adjusting_filters'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: kTextLightColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Filter Summary (if filters are active)
                if (_hasActiveFilters())
                  Container(
                    margin: const EdgeInsets.all(kDefaultPaddin),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: kPrimaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list,
                            color: kPrimaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getFilterSummary(),
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Orders List
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
                    itemCount: completedOrders.length,
                    itemBuilder: (context, index) {
                      final order = completedOrders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => _reorderItems(context, ref, order),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _reorderItems(BuildContext context, WidgetRef ref, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ref.tr('reorder_items')),
          content: Text(ref.tr('add_all_items_to_cart',
              params: {'orderId': order.id.toString()})),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(ref.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                // Add all items to cart
                for (final item in order.items) {
                  ref.read(cartProvider.notifier).addToCart(
                        item.product,
                        quantity: item.quantity,
                      );
                }
                Navigator.of(context).pop();

                // Navigate to cart
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ref.tr('items_added_to_cart',
                        params: {'count': order.items.length.toString()})),
                    backgroundColor: kSuccessColor,
                  ),
                );
              },
              child: Text(ref.tr('add_to_cart')),
            ),
          ],
        );
      },
    );
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    return orders.where((order) {
      // Filter by date range
      if (_selectedDateRange != null) {
        final orderDate = order.orderDate;
        if (orderDate.isBefore(_selectedDateRange!.start) ||
            orderDate.isAfter(
                _selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _hasActiveFilters() {
    return _selectedDateRange != null;
  }

  String _getFilterSummary() {
    if (_selectedDateRange != null) {
      final start = _selectedDateRange!.start;
      final end = _selectedDateRange!.end;
      return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
    }
    return '';
  }

  void _clearFilters() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Range Filter
              const Text(
                'Date Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: kTextLightColor.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () => _selectDateRange(context, setModalState),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDateRange == null
                            ? 'Select date range'
                            : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                        style: TextStyle(
                          color: _selectedDateRange == null
                              ? kTextLightColor
                              : kTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.calendar_today,
                          color: kPrimaryColor, size: 20),
                    ],
                  ),
                ),
              ),
              if (_selectedDateRange != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () => setModalState(() {
                      _selectedDateRange = null;
                    }),
                    child: const Text('Clear date filter'),
                  ),
                ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedDateRange = null;
                        });
                      },
                      child: const Text('Clear Filter'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Filters are already updated in the modal state
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply Filter'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange(
      BuildContext context, StateSetter setModalState) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kPrimaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setModalState(() {
        _selectedDateRange = picked;
      });
    }
  }
}

class OrderCard extends ConsumerStatefulWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final Order order;
  final VoidCallback onTap;

  @override
  ConsumerState<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<OrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final hasMoreThanTwoItems = order.items.length > 2;
    final itemsToShow =
        _isExpanded ? order.items : order.items.take(2).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('order_number',
                          params: {'id': order.id.toString()}),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: kTextLightColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kSuccessColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ref.tr('completed_status'),
                    style: const TextStyle(
                      color: kSuccessColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order Items Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.totalItems} ${ref.tr('items')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: kTextLightColor,
                      ),
                    ),
                    Text(
                      '¥${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Items list (expandable)
                AnimatedCrossFade(
                  firstChild: Column(
                    children: [
                      // Show first 2 items
                      ...itemsToShow.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildItemRow(item),
                          )),

                      // Show expand button if more than 2 items
                      if (hasMoreThanTwoItems && !_isExpanded)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ref.tr('show_more_items', params: {
                                    'count': (order.items.length - 2).toString()
                                  }),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.expand_more,
                                  color: kPrimaryColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  secondChild: Column(
                    children: [
                      // Show all items
                      ...itemsToShow.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildItemRow(item),
                          )),

                      // Show collapse button
                      if (hasMoreThanTwoItems && _isExpanded)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Show less',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.expand_less,
                                  color: kPrimaryColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),

          // Reorder Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                ref.tr('reorder_all_items'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(item) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.image.startsWith('http')
                ? Image.network(
                    item.product.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 1,
                            color: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.medical_services,
                        color: Colors.grey[400],
                        size: 20,
                      );
                    },
                  )
                : Image.asset(
                    item.product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.medical_services,
                        color: Colors.grey[400],
                        size: 20,
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '¥${item.product.price.toStringAsFixed(0)} ${ref.tr('each')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextLightColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'x${item.quantity}',
              style: const TextStyle(
                fontSize: 14,
                color: kTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '¥${item.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
