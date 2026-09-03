import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to users collection
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // Create or update a user profile
  Future<void> createUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(
      user.toMap(),
    );
  }

  // Get a user profile
  Future<UserModel?> getUser(String uid) async {
    final document = await _usersCollection.doc(uid).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return UserModel.fromMap(
      document.id,
      document.data()!,
    );
  }

  // Update a user profile
  Future<void> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _usersCollection.doc(uid).update(data);
  }
}