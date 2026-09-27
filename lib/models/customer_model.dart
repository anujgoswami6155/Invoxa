import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime? createdAt;

  const CustomerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.createdAt,
  });

  factory CustomerModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime? parsedCreatedAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    return CustomerModel(
      id: id.isNotEmpty ? id : (data['id'] ?? ''),
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
