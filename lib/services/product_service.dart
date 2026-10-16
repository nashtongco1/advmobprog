import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product_model.dart';

class ProductService {
  Future<Product> getProductById(int id) async {
    final response = await http
        .get(Uri.parse('$host/products/$id'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load product $id',
      );
    }

    return Product.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$host/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(response.body);

        final List productsJson;

        if (decoded is List) {
          productsJson = decoded;
        } else if (decoded
            is Map<String, dynamic>) {
          productsJson =
              decoded['products'] ?? [];
        } else {
          productsJson = [];
        }

        return productsJson
            .cast<Map<String, dynamic>>()
            .map(
              (json) =>
                  Product.fromJson(json),
            )
            .toList();
      }
    } catch (error) {
      error.toString();
    }

    const sampleJson = '''
[
  {
    "id": 1,
    "title": "Sample Product A",
    "description": "This is a sample product shown when network fails.",
    "price": 9.99,
    "category": "general",
    "image": "https://via.placeholder.com/300.png/09f/fff",
    "rating": {
      "rate": 4.2,
      "count": 12
    }
  },
  {
    "id": 2,
    "title": "Sample Product B",
    "description": "Offline fallback product.",
    "price": 19.99,
    "category": "general",
    "image": "https://via.placeholder.com/300.png/021/fff",
    "rating": {
      "rate": 4.7,
      "count": 8
    }
  }
]
''';

    final List fallback =
        jsonDecode(sampleJson) as List;

    return fallback
        .cast<Map<String, dynamic>>()
        .map(
          (json) =>
              Product.fromJson(json),
        )
        .toList();
  }
}