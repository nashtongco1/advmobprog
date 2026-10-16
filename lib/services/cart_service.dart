import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';
import '../models/product_model.dart';

class CartService {
  static final Map<int, Cart> _cachedCarts = {};

  static int firebaseCartId(String firebaseUid) {
    if (firebaseUid.isEmpty) {
      return 0;
    }

    var hash = 0;

    for (final codeUnit in firebaseUid.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }

    return -(hash == 0 ? 1 : hash);
  }

  static int resolveUserId({
    required int userId,
    required String firebaseUid,
    required String loginType,
  }) {
    if (loginType == 'firebase') {
      return firebaseCartId(firebaseUid);
    }

    return userId;
  }

  static bool isFirebaseCart(int userId) {
    return userId < 0;
  }

  Future<List<Cart>> getAllCarts() async {
    final response = await http
        .get(
          Uri.parse('$host/carts'),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load carts',
      );
    }

    final decoded =
        jsonDecode(response.body);

    final cartsJson =
        decoded is Map<String, dynamic>
            ? (decoded['carts'] as List? ??
                <dynamic>[])
            : decoded is List
                ? decoded
                : <dynamic>[];

    return cartsJson
        .map(
          (json) => Cart.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Cart> getCartByUserId(
    int userId,
  ) async {
    final cachedCart =
        _cachedCarts[userId];

    if (cachedCart != null) {
      return cachedCart;
    }

    if (isFirebaseCart(userId)) {
      final emptyCart =
          _createEmptyCart(userId);

      _cachedCarts[userId] =
          emptyCart;

      return emptyCart;
    }

    final response = await http
        .get(
          Uri.parse(
            '$host/carts/user/$userId',
          ),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load cart for user $userId',
      );
    }

    final decoded =
        jsonDecode(response.body);

    final carts = decoded is List
        ? decoded
        : decoded is Map<String, dynamic> &&
                decoded['carts'] is List
            ? decoded['carts'] as List
            : decoded is Map<String, dynamic>
                ? [decoded]
                : <dynamic>[];

    if (carts.isEmpty) {
      final emptyCart =
          _createEmptyCart(userId);

      _cachedCarts[userId] =
          emptyCart;

      return emptyCart;
    }

    final cart = Cart.fromJson(
      carts.first
          as Map<String, dynamic>,
    );

    _cachedCarts[userId] = cart;

    return cart;
  }

  Future<Cart> addToCart({
    required int userId,
    required Product product,
    int quantity = 1,
  }) async {
    if (!isFirebaseCart(userId)) {
      final response = await http
          .post(
            Uri.parse(
              '$host/carts/add',
            ),
            headers: {
              'Content-Type':
                  'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'products': [
                {
                  'id': product.id,
                  'quantity': quantity,
                },
              ],
            }),
          )
          .timeout(
            const Duration(
              seconds: 10,
            ),
          );

      if (response.statusCode !=
          201) {
        throw Exception(
          'Unable to add product to cart',
        );
      }
    }

    final currentCart =
        _cachedCarts[userId] ??
            await getCartByUserId(
              userId,
            );

    final products =
        List<CartProduct>.from(
      currentCart.products,
    );

    final existingProductIndex =
        products.indexWhere(
      (item) =>
          item.id == product.id,
    );

    final currentQuantity =
        existingProductIndex >= 0
            ? products[
                    existingProductIndex]
                .quantity
            : 0;

    final newQuantity =
        currentQuantity + quantity;

    final discountPercentage =
        product.discountPercentage;

    final itemTotal =
        product.price * newQuantity;

    final discountedItemTotal =
        itemTotal *
            (1 -
                discountPercentage /
                    100);

    final cartProduct =
        CartProduct(
      id: product.id,
      title: product.title,
      price: product.price,
      quantity: newQuantity,
      total: itemTotal,
      discountPercentage:
          discountPercentage,
      discountedTotal:
          discountedItemTotal,
      thumbnail:
          product.thumbnail,
    );

    if (existingProductIndex >= 0) {
      products[
              existingProductIndex] =
          cartProduct;
    } else {
      products.add(
        cartProduct,
      );
    }

    final updatedCart =
        _buildUpdatedCart(
      currentCart:
          currentCart,
      products: products,
      userId: userId,
    );

    _cachedCarts[userId] =
        updatedCart;

    return updatedCart;
  }

  void updateCartQuantity({
    required int userId,
    required int productId,
    required int quantity,
  }) {
    final currentCart =
        _cachedCarts[userId];

    if (currentCart == null) {
      return;
    }

    final products =
        List<CartProduct>.from(
      currentCart.products,
    );

    final itemIndex =
        products.indexWhere(
      (item) =>
          item.id == productId,
    );

    if (itemIndex < 0) {
      return;
    }

    if (quantity <= 0) {
      products.removeAt(
        itemIndex,
      );

      _cachedCarts[userId] =
          _buildUpdatedCart(
        currentCart:
            currentCart,
        products: products,
        userId: userId,
      );

      return;
    }

    final item =
        products[itemIndex];

    final itemTotal =
        item.price * quantity;

    products[itemIndex] =
        CartProduct(
      id: item.id,
      title: item.title,
      price: item.price,
      quantity: quantity,
      total: itemTotal,
      discountPercentage:
          item.discountPercentage,
      discountedTotal:
          itemTotal *
              (1 -
                  item.discountPercentage /
                      100),
      thumbnail:
          item.thumbnail,
    );

    _cachedCarts[userId] =
        _buildUpdatedCart(
      currentCart:
          currentCart,
      products: products,
      userId: userId,
    );
  }

  Cart _createEmptyCart(
    int userId,
  ) {
    return Cart(
      id: 0,
      products: const [],
      total: 0,
      discountedTotal: 0,
      userId: userId,
      totalProducts: 0,
      totalQuantity: 0,
    );
  }

  Cart _buildUpdatedCart({
    required Cart currentCart,
    required List<CartProduct> products,
    required int userId,
  }) {
    return Cart(
      id: currentCart.id,
      products: products,
      total:
          products.fold<double>(
        0,
        (sum, item) =>
            sum + item.total,
      ),
      discountedTotal:
          products.fold<double>(
        0,
        (sum, item) =>
            sum +
            item.discountedTotal,
      ),
      userId: userId,
      totalProducts:
          products.length,
      totalQuantity:
          products.fold<int>(
        0,
        (sum, item) =>
            sum + item.quantity,
      ),
    );
  }
}