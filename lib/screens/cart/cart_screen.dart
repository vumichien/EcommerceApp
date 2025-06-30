import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../utils/app_localizations.dart';
import '../../providers/cart_provider.dart';
import '../../providers/voucher_provider.dart';
import '../../models/cart_item.dart';
import '../order/order_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartTotalProvider);
    final voucher = ref.watch(voucherProvider);
    final finalTotal = ref.watch(finalTotalProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: Column(
          children: [
            Text(
              ref.tr('your_cart'),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ref.tr('items_count',
                  params: {'count': cartItems.length.toString()}),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: kTextLightColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ref.tr('empty_cart'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: kTextLightColor,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return SwipeToDeleteItem(
                        cartItem: cartItems[index],
                        onDelete: () {
                          ref.read(cartProvider.notifier).removeFromCart(
                                cartItems[index].product.id,
                              );
                        },
                      );
                    },
                  ),
                ),

                // Voucher Code Section
                const VoucherCodeSection(),

                const SizedBox(height: 20),

                // Bottom Section with Total and Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ref.tr('subtotal'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      // Discount (if applied)
                      if (voucher.isValid && voucher.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ref.tr('discount',
                                  params: {'code': voucher.appliedCode}),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '-\$${voucher.discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ref.tr('total'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '\$${finalTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            ref.tr('check_out'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class VoucherCodeSection extends ConsumerStatefulWidget {
  const VoucherCodeSection({super.key});

  @override
  ConsumerState<VoucherCodeSection> createState() => _VoucherCodeSectionState();
}

class _VoucherCodeSectionState extends ConsumerState<VoucherCodeSection> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voucher = ref.watch(voucherProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          // Main voucher section
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      voucher.isValid
                          ? ref.tr('voucher_applied',
                              params: {'code': voucher.appliedCode})
                          : ref.tr('add_voucher_code'),
                      style: TextStyle(
                        fontSize: 16,
                        color: voucher.isValid ? Colors.green : Colors.black87,
                        fontWeight: voucher.isValid
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (voucher.isValid)
                    IconButton(
                      onPressed: () {
                        ref.read(voucherProvider.notifier).removeVoucher();
                        _controller.clear();
                      },
                      icon:
                          const Icon(Icons.close, color: Colors.grey, size: 20),
                    )
                  else
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.chevron_right,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),

          // Expanded input section
          if (_isExpanded && !voucher.isValid)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: ref.tr('enter_voucher_code'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: kPrimaryColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            ref
                                .read(voucherProvider.notifier)
                                .applyVoucher(_controller.text);
                            final voucherState = ref.read(voucherProvider);
                            if (voucherState.isValid) {
                              setState(() {
                                _isExpanded = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ref.tr('voucher_success',
                                      params: {
                                        'amount':
                                            '\$${voucherState.discountAmount.toStringAsFixed(2)}'
                                      })),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ref.tr('invalid_voucher')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text(ref.tr('apply')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ref.tr('voucher_suggestions'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SwipeToDeleteItem extends ConsumerStatefulWidget {
  const SwipeToDeleteItem({
    super.key,
    required this.cartItem,
    required this.onDelete,
  });

  final CartItem cartItem;
  final VoidCallback onDelete;

  @override
  ConsumerState<SwipeToDeleteItem> createState() => _SwipeToDeleteItemState();
}

class _SwipeToDeleteItemState extends ConsumerState<SwipeToDeleteItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ref.tr('delete_item')),
          content: Text(ref.tr('delete_item_confirm',
              params: {'item': widget.cartItem.product.title})),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(ref.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(ref.tr('delete'),
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      widget.onDelete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.cartItem.product.title} removed from cart'),
            backgroundColor: kSuccessColor,
          ),
        );
      }
    }

    // Reset the swipe state
    _animationController.reverse();
    setState(() {
      _isRevealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isRevealed) {
          _animationController.reverse();
          setState(() {
            _isRevealed = false;
          });
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -2 && !_isRevealed) {
          _animationController.forward();
          setState(() {
            _isRevealed = true;
          });
        } else if (details.delta.dx > 2 && _isRevealed) {
          _animationController.reverse();
          setState(() {
            _isRevealed = false;
          });
        }
      },
      child: Stack(
        children: [
          // Delete button background
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_animation.value > 0.3)
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: _handleDelete,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // Cart item
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-60 * _animation.value, 0),
                child: CartItemWidget(cartItem: widget.cartItem),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.cartItem,
  });

  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
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
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: cartItem.product.image.startsWith('http')
                  ? Image.network(
                      cartItem.product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.medical_services,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      cartItem.product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.medical_services,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(width: 15),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      cartItem.product.priceString,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'x${cartItem.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
