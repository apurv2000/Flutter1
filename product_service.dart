import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/product.dart';

class ProductService {
  static const String _productsKey = 'products';

  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_productsKey);
    if (productsJson == null) return [];
    
    final List<dynamic> decoded = json.decode(productsJson);
    return decoded.map((item) => Product.fromJson(item)).toList();
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    if (products.any((p) => p.name.toLowerCase() == product.name.toLowerCase())) {
      throw Exception('Product already exists');
    }
    
    products.add(product);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, json.encode(products.map((p) => p.toJson()).toList()));
  }

  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, json.encode(products.map((p) => p.toJson()).toList()));
  }

  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    if (query.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}