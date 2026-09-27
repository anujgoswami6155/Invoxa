import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Root-level collection: /customers/{customerId}
  CollectionReference<Map<String, dynamic>> get _customersCollection =>
      _firestore.collection('customers');

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final document = _customersCollection.doc();

    final customerWithId = CustomerModel(
      id: document.id,
      userId: customer.userId,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      address: customer.address,
      createdAt: customer.createdAt ?? DateTime.now(),
    );

    debugPrint(
      '[CustomerService] Writing customer to root collection: ${document.path}',
    );
    await document.set(customerWithId.toMap());
    debugPrint(
      '[CustomerService] Successfully written to Firestore: ${document.path}',
    );

    return customerWithId;
  }

  Future<List<CustomerModel>> getCustomers(String userId) async {
    debugPrint(
      '[CustomerService] Fetching customers from root collection: customers where userId == $userId',
    );
    final snapshot = await _customersCollection
        .where('userId', isEqualTo: userId)
        .get();

    final customers = snapshot.docs.map((document) {
      return CustomerModel.fromMap(document.id, document.data());
    }).toList();

    // Sort descending by creation date in memory (avoids requiring a manual composite index)
    customers.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    debugPrint(
      '[CustomerService] Loaded ${customers.length} customers from Firestore.',
    );
    return customers;
  }

  Future<CustomerModel?> getCustomer(String userId, String customerId) async {
    final document = await _customersCollection.doc(customerId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return CustomerModel.fromMap(document.id, document.data()!);
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _customersCollection.doc(customer.id).update(customer.toMap());
  }

  Future<void> deleteCustomer(String userId, String customerId) async {
    await _customersCollection.doc(customerId).delete();
  }
}
