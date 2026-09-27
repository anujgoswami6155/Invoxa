import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  Future<List<ProductModel>> getProducts(String userId) async {
    final snapshot = await _productsCollection
        .where('userId', isEqualTo: userId)
        .get();

    final products = snapshot.docs
        .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
        .toList();

    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  Future<ProductModel?> getProduct({
    required String productId,
    required String userId,
  }) async {
    final document = await _productsCollection.doc(productId).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null || data['userId'] != userId) {
      return null;
    }

    return ProductModel.fromMap({...data, 'id': document.id});
  }

  Future<String> createProduct(ProductModel product) async {
    if (product.userId.isEmpty) {
      throw ArgumentError('Product userId cannot be empty.');
    }

    final document = _productsCollection.doc();

    await document.set(product.copyWith(id: document.id).toMap());

    return document.id;
  }

  Future<void> updateProduct(ProductModel product) async {
    if (product.id.isEmpty) {
      throw ArgumentError('Product id cannot be empty for update.');
    }

    await _productsCollection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct({
    required String productId,
    required String userId,
  }) async {
    final product = await getProduct(productId: productId, userId: userId);

    if (product == null) {
      throw Exception('Product not found.');
    }

    await _productsCollection.doc(productId).delete();
  }
}
