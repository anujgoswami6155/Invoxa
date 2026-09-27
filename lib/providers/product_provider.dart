import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts({required String userId}) async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _productService.getProducts(userId);
    } on FirebaseException catch (e) {
      debugPrint('Fetch products Firebase error: ${e.code} - ${e.message}');
      _errorMessage = e.message ?? 'Failed to load products (${e.code}).';
    } catch (e) {
      debugPrint('Fetch products error: $e');
      _errorMessage = 'Failed to load products: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    _setLoading(true);
    _clearError();

    try {
      final productId = await _productService.createProduct(product);

      _products = [product.copyWith(id: productId), ..._products];

      return true;
    } on FirebaseException catch (e) {
      debugPrint('Add product Firebase error: ${e.code} - ${e.message}');
      _errorMessage = e.message ?? 'Failed to add product (${e.code}).';
      return false;
    } catch (e) {
      debugPrint('Add product error: $e');
      _errorMessage = 'Failed to add product: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    _clearError();

    try {
      await _productService.updateProduct(product);

      final index = _products.indexWhere((item) => item.id == product.id);

      if (index != -1) {
        final updatedProducts = [..._products];
        updatedProducts[index] = product;
        _products = updatedProducts;
      }

      return true;
    } on FirebaseException catch (e) {
      debugPrint('Update product Firebase error: ${e.code} - ${e.message}');
      _errorMessage = e.message ?? 'Failed to update product (${e.code}).';
      return false;
    } catch (e) {
      debugPrint('Update product error: $e');
      _errorMessage = 'Failed to update product: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProduct({
    required String productId,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _productService.deleteProduct(productId: productId, userId: userId);

      _products = _products
          .where((product) => product.id != productId)
          .toList();

      return true;
    } on FirebaseException catch (e) {
      debugPrint('Delete product Firebase error: ${e.code} - ${e.message}');
      _errorMessage = e.message ?? 'Failed to delete product (${e.code}).';
      return false;
    } catch (e) {
      debugPrint('Delete product error: $e');
      _errorMessage = 'Failed to delete product: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  ProductModel? getProductById(String productId) {
    for (final product in _products) {
      if (product.id == productId) {
        return product;
      }
    }

    return null;
  }

  void clearProducts() {
    _products = [];
    _clearError();
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
