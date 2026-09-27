import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _customersCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('customers');
  }

  Future<void> createCustomer(CustomerModel customer) async {
    await _customersCollection(customer.userId)
        .doc(customer.id)
        .set(customer.toMap());
  }

  Future<List<CustomerModel>> getCustomers(String userId) async {
    final snapshot = await _customersCollection(userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((document) {
      return CustomerModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  Future<CustomerModel?> getCustomer(
    String userId,
    String customerId,
  ) async {
    final document = await _customersCollection(userId)
        .doc(customerId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return CustomerModel.fromMap(
      document.id,
      document.data()!,
    );
  }

  Future<void> updateCustomer(
    CustomerModel customer,
  ) async {
    await _customersCollection(customer.userId)
        .doc(customer.id)
        .update(customer.toMap());
  }

  Future<void> deleteCustomer(
    String userId,
    String customerId,
  ) async {
    await _customersCollection(userId)
        .doc(customerId)
        .delete();
  }
}
