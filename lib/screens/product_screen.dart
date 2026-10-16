import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product_model.dart';

// services
import '../services/product_service.dart';
import '../services/cart_service.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;

  // Enhancement 1: Search bar
  // Holds the full list once loaded, and the filtered list shown on screen.
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadAllCarts();
  }

  Future<List<Product>> _loadAllCarts() async {
    final carts = await CartService().getAllCarts();
    final productService = ProductService();

    final productIds = carts
        .expand((cart) => cart.products)
        .map((item) => item.id)
        .toSet();

    final products = await Future.wait(
      productIds.map((id) async {
        try {
          return await productService.getProductById(id);
        } catch (_) {
          return null;
        }
      }),
    );

    return products.whereType<Product>().toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Enhancement 1: Search bar
  // Filters the product list by title based on the user's input.
  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts
          .where(
            (product) =>
                product.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhancement 1: Search bar
            // Allows the user to search products by title.
            Container(
              width: ScreenUtil().screenWidth,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterProducts('');
                          },
                        )
                      : const Icon(Icons.search),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: CustomText(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 14.sp,
                    ),
                  );
                }

                if (_allProducts.isEmpty && snapshot.data != null) {
                  _allProducts = snapshot.data!;
                  _filteredProducts = _allProducts;
                }

                final products = _filteredProducts;

                if (products.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: 'No products found.',
                      fontSize: 14.sp,
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.60,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    final discountedPrice =
                        product.price *
                        (1 - product.discountPercentage / 100);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 145.h,
                              width: double.infinity,
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F5FA),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.image_outlined,
                                      size: 30.sp,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            CustomText(
                              text: product.title,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              children: [
                                Text(
                                  '\$${discountedPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: const Color(0xFFE69B00),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (product.discountPercentage > 0) ...[
                                  SizedBox(width: 6.w),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${product.discountPercentage.toStringAsFixed(0)}% off  •  ${product.category}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}