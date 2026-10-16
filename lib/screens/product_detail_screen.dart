import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen
    extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight:
              FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  12.r,
                ),
                child: Image.network(
                  product.thumbnail,
                  width:
                      double.infinity,
                  height: 220.h,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) =>
                      Icon(
                    Icons.image,
                    size: 48.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              if (product
                      .images.length >
                  1)
                SizedBox(
                  height: 70.h,
                  child:
                      ListView.separated(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount: product
                        .images.length,
                    separatorBuilder:
                        (
                      context,
                      index,
                    ) =>
                            SizedBox(
                      width: 8.w,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          8.r,
                        ),
                        child:
                            Image.network(
                          product.images[
                              index],
                          width: 70.w,
                          height: 70.h,
                          fit:
                              BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) =>
                              Icon(
                            Icons.image,
                            size: 24.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 16.h),
              CustomText(
                text: product.title,
                fontSize: 20.sp,
                fontWeight:
                    FontWeight.bold,
              ),
              SizedBox(height: 4.h),
              CustomText(
                text: product.brand,
                fontSize: 14.sp,
                fontWeight:
                    FontWeight.w400,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  CustomText(
                    text:
                        '\$${product.price.toStringAsFixed(2)}',
                    fontSize: 18.sp,
                    fontWeight:
                        FontWeight.w700,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  if (product
                          .discountPercentage >
                      0)
                    CustomText(
                      text:
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                      fontSize: 14.sp,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  const Spacer(),
                  Icon(
                    Icons.star,
                    size: 16.sp,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  CustomText(
                    text: product.rating
                        .toStringAsFixed(
                      1,
                    ),
                    fontSize: 14.sp,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: 'Description',
                fontSize: 16.sp,
                fontWeight:
                    FontWeight.bold,
              ),
              SizedBox(height: 4.h),
              CustomText(
                text:
                    product.description,
                fontSize: 14.sp,
                fontWeight:
                    FontWeight.w400,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  icon: const Icon(
                    Icons
                        .add_shopping_cart,
                  ),
                  label: const Text(
                    'Add to cart',
                  ),
                  onPressed: () =>
                      _addToCart(
                    context,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _infoRow(
                'Category',
                product.category,
              ),
              _infoRow(
                'Stock',
                '${product.stock} available',
              ),
              _infoRow(
                'Availability',
                product
                    .availabilityStatus,
              ),
              _infoRow(
                'Minimum Order',
                '${product.minimumOrderQuantity}',
              ),
              _infoRow(
                'Warranty',
                product
                    .warrantyInformation,
              ),
              _infoRow(
                'Shipping',
                product
                    .shippingInformation,
              ),
              _infoRow(
                'Return Policy',
                product.returnPolicy,
              ),
              _infoRow(
                'Dimensions',
                '${product.dimensions.width} x ${product.dimensions.height} x ${product.dimensions.depth} cm',
              ),
              _infoRow(
                'Weight',
                '${product.weight} kg',
              ),
              SizedBox(height: 16.h),
              if (product
                  .reviews.isNotEmpty) ...[
                CustomText(
                  text:
                      'Reviews (${product.reviews.length})',
                  fontSize: 16.sp,
                  fontWeight:
                      FontWeight.bold,
                ),
                SizedBox(height: 8.h),
                ...product.reviews.map(
                  (review) =>
                      Padding(
                    padding:
                        EdgeInsets.only(
                      bottom: 10.h,
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.all(
                        10.r,
                      ),
                      decoration:
                          BoxDecoration(
                        border:
                            Border.all(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          8.r,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              CustomText(
                                text: review
                                    .reviewerName,
                                fontSize:
                                    13.sp,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.star,
                                size: 14.sp,
                              ),
                              CustomText(
                                text:
                                    '${review.rating}',
                                fontSize:
                                    12.sp,
                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          CustomText(
                            text: review
                                .comment,
                            fontSize:
                                13.sp,
                            fontWeight:
                                FontWeight
                                    .w400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
  ) async {
    try {
      final user =
          await UserService()
              .getUser();

      final userId =
          CartService.resolveUserId(
        userId: user.id,
        firebaseUid:
            user.firebaseUid,
        loginType:
            user.loginType,
      );

      if (userId == 0) {
        throw Exception(
          'Invalid logged-in user.',
        );
      }

      await CartService()
          .addToCart(
        userId: userId,
        product: product,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Product added to cart.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Could not add product: $error',
          ),
        ),
      );
    }
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          EdgeInsets.only(
        bottom: 6.h,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: CustomText(
              text: label,
              fontSize: 13.sp,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 13.sp,
              fontWeight:
                  FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}