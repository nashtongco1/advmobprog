import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';

import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final Future<_CartData> _cartFuture;

  final Map<int, int> _quantities = {};
  final Set<int> _removedProductIds = {};

  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<_CartData> _loadCart() async {
    final user =
        await UserService().getUser();

    _userId =
        CartService.resolveUserId(
      userId: user.id,
      firebaseUid: user.firebaseUid,
      loginType: user.loginType,
    );

    if (_userId == 0) {
      throw Exception(
        'Invalid logged-in user.',
      );
    }

    final cart =
        await CartService()
            .getCartByUserId(
      _userId,
    );

    final random = Random();

    final items =
        await Future.wait<_CartItem>(
      cart.products.map(
        (item) async {
          final product =
              await ProductService()
                  .getProductById(
            item.id,
          );

          return _CartItem(
            product: product,
            discountPercentage:
                (5 +
                        random.nextInt(
                          21,
                        ))
                    .toDouble(),
            quantity: item.quantity,
          );
        },
      ),
    );

    return _CartData(
      cart: cart,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: CustomText(
          text: 'Cart',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: FutureBuilder<_CartData>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    EdgeInsets.all(24.r),
                child: Text(
                  'Unable to load cart: ${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data!;

          final visibleItems =
              data.items
                  .where(
                    (item) =>
                        !_removedProductIds
                            .contains(
                      item.product.id,
                    ),
                  )
                  .toList();

          for (final item
              in visibleItems) {
            _quantities.putIfAbsent(
              item.product.id,
              () => item.quantity,
            );
          }

          if (visibleItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88.w,
                    height: 88.w,
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      shape:
                          BoxShape.circle,
                    ),
                    child: Icon(
                      Icons
                          .shopping_bag_outlined,
                      size: 44.sp,
                      color:
                          const Color(
                        0xFFE69B00,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color:
                          Colors.black87,
                      fontSize: 18.sp,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    'Add something you love from the shop.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final subtotal =
              visibleItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                item.product.price *
                    _quantityFor(
                      item,
                    ),
          );

          final discountedSubtotal =
              visibleItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                _discountedUnitPrice(
                      item,
                    ) *
                    _quantityFor(
                      item,
                    ),
          );

          final discount =
              subtotal -
              discountedSubtotal;

          const shipping = 25.00;

          final total =
              discountedSubtotal +
              shipping;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                      EdgeInsets.fromLTRB(
                    12.r,
                    14.r,
                    12.r,
                    8.r,
                  ),
                  children: [
                    ...visibleItems.map(
                      (item) =>
                          _buildCartItem(
                        item,
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    _buildSummary(
                      subtotal: subtotal,
                      discount: discount,
                      shipping: shipping,
                      total: total,
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(
                      12.r,
                      10.r,
                      12.r,
                      10.r,
                    ),
                    child: SizedBox(
                      width:
                          double.infinity,
                      height: 50.h,
                      child:
                          ElevatedButton(
                        onPressed: () =>
                            _showConfirmDialog(
                          total: total,
                          discount:
                              discount,
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFFFB91F,
                          ),
                          foregroundColor:
                              Colors.black,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12.r,
                            ),
                          ),
                        ),
                        child: Text(
                          'Confirm Order  •  \$${total.toStringAsFixed(2)}',
                          style:
                              TextStyle(
                            fontSize:
                                14.sp,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _quantityFor(
    _CartItem item,
  ) {
    return _quantities[
            item.product.id] ??
        item.quantity;
  }

  double _discountedUnitPrice(
    _CartItem item,
  ) {
    return item.product.price *
        (1 -
            item.discountPercentage /
                100);
  }

  Widget _buildCartItem(
    _CartItem item,
  ) {
    final quantity =
        _quantityFor(item);

    final discountedPrice =
        _discountedUnitPrice(
      item,
    );

    void openProduct() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailsScreen(
            product: item.product,
          ),
        ),
      );
    }

    return Container(
      margin:
          EdgeInsets.only(
        bottom: 10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFEDEDF1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x0D000000),
            blurRadius: 8,
            offset:
                Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
        clipBehavior:
            Clip.antiAlias,
        child: InkWell(
          onTap: openProduct,
          borderRadius:
              BorderRadius.circular(
            14.r,
          ),
          child: Padding(
            padding:
                EdgeInsets.all(
              10.r,
            ),
            child: Row(
              children: [
                Container(
                  width: 76.w,
                  height: 76.w,
                  padding:
                      EdgeInsets.all(
                    6.r,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF6F5FA,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10.r,
                    ),
                  ),
                  child:
                      Image.network(
                    item.product
                        .thumbnail,
                    fit:
                        BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Icon(
                        Icons
                            .image_outlined,
                        size: 30.sp,
                        color:
                            Colors.grey,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.product
                                  .title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  TextStyle(
                                color: Colors
                                    .black87,
                                fontSize:
                                    13.sp,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Icon(
                            Icons
                                .chevron_right_rounded,
                            size: 19.sp,
                            color: Colors
                                .grey
                                .shade500,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Row(
                        children: [
                          Text(
                            '\$${discountedPrice.toStringAsFixed(2)}',
                            style:
                                TextStyle(
                              color:
                                  const Color(
                                0xFFE69B00,
                              ),
                              fontSize:
                                  13.sp,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                          if (item
                                  .discountPercentage >
                              0) ...[
                            SizedBox(
                              width: 6.w,
                            ),
                            Text(
                              '\$${item.product.price.toStringAsFixed(2)}',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                                fontSize:
                                    10.sp,
                                decoration:
                                    TextDecoration
                                        .lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Text(
                        '${item.discountPercentage.toStringAsFixed(0)}% off  •  \$${(discountedPrice * quantity).toStringAsFixed(2)} total',
                        style:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                          fontSize:
                              10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 8.w,
                ),
                Column(
                  children: [
                    _stepperButton(
                      Icons.add,
                      () =>
                          _changeQuantity(
                        item,
                        1,
                      ),
                      true,
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      '$quantity',
                      style:
                          TextStyle(
                        color:
                            Colors.black87,
                        fontSize:
                            12.sp,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    _stepperButton(
                      Icons.remove,
                      () =>
                          _changeQuantity(
                        item,
                        -1,
                      ),
                      false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepperButton(
    IconData icon,
    VoidCallback onPressed,
    bool active,
  ) {
    return SizedBox(
      width: 28.w,
      height: 28.w,
      child: IconButton(
        padding:
            EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16.sp,
        ),
        style:
            IconButton.styleFrom(
          backgroundColor: active
              ? const Color(
                  0xFFFFB91F,
                )
              : const Color(
                  0xFFE9E9EF,
                ),
          foregroundColor: active
              ? Colors.black
              : Colors
                  .grey.shade700,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              8.r,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary({
    required double subtotal,
    required double discount,
    required double shipping,
    required double total,
  }) {
    return Container(
      margin:
          EdgeInsets.only(
        top: 2.h,
        bottom: 4.h,
      ),
      padding:
          EdgeInsets.fromLTRB(
        14.r,
        14.r,
        14.r,
        14.r,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14.r,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFEDEDF1,
          ),
        ),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Subtotal',
            subtotal,
          ),
          _summaryRow(
            'Discount',
            -discount,
            valueColor:
                const Color(
              0xFF159B62,
            ),
          ),
          _summaryRow(
            'Delivery Fee',
            shipping,
          ),
          Divider(
            height: 20.h,
            color:
                const Color(
              0xFFE9E9ED,
            ),
          ),
          _summaryRow(
            'Total',
            total,
            bold: true,
            valueColor:
                const Color(
              0xFFE69B00,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 4.h,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold
                  ? 15.sp
                  : 12.sp,
              fontWeight: bold
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: bold
                  ? Colors.black87
                  : Colors
                      .grey.shade700,
            ),
          ),
          Text(
            '${value < 0 ? '-' : ''}\$${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: bold
                  ? 16.sp
                  : 12.sp,
              fontWeight:
                  FontWeight.w700,
              color: valueColor ??
                  Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _changeQuantity(
    _CartItem item,
    int change,
  ) {
    final currentQuantity =
        _quantityFor(item);

    final nextQuantity =
        currentQuantity +
        change;

    if (nextQuantity <= 0) {
      _removeItem(item);
      return;
    }

    setState(() {
      _quantities[
              item.product.id] =
          nextQuantity;
    });

    CartService()
        .updateCartQuantity(
      userId: _userId,
      productId:
          item.product.id,
      quantity: nextQuantity,
    );
  }

  void _removeItem(
    _CartItem item,
  ) {
    setState(() {
      _quantities.remove(
        item.product.id,
      );

      _removedProductIds.add(
        item.product.id,
      );
    });

    CartService()
        .updateCartQuantity(
      userId: _userId,
      productId:
          item.product.id,
      quantity: 0,
    );

    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          '${item.product.title} removed from cart.',
        ),
        duration:
            const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog({
    required double total,
    required double discount,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          backgroundColor:
              Colors.white,
          title: const Text(
            'Confirm Order',
            style: TextStyle(
              color:
                  Colors.black87,
            ),
          ),
          content: Text(
            'Your order total is \$${total.toStringAsFixed(2)}.\n'
            'You saved \$${discount.toStringAsFixed(2)} with your discounts.',
            style:
                const TextStyle(
              color:
                  Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                ScaffoldMessenger
                        .of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Order confirmed successfully.',
                    ),
                  ),
                );
              },
              child:
                  const Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CartData {
  final Cart cart;
  final List<_CartItem> items;

  const _CartData({
    required this.cart,
    required this.items,
  });
}

class _CartItem {
  final Product product;
  final double discountPercentage;
  final int quantity;

  const _CartItem({
    required this.product,
    required this.discountPercentage,
    required this.quantity,
  });
}
