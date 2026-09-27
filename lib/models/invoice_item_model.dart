class InvoiceItemModel {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final String unitType;
  final double totalPrice;

  const InvoiceItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.unitType = 'unit',
    required this.totalPrice,
  });

  factory InvoiceItemModel.create({
    required String id,
    required String productId,
    required String productName,
    required double quantity,
    required double unitPrice,
    String unitType = 'unit',
  }) {
    return InvoiceItemModel(
      id: id,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      unitType: unitType,
      totalPrice: quantity * unitPrice,
    );
  }

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    final quantity = (map['quantity'] as num?)?.toDouble() ?? 1.0;
    final unitPrice = (map['unitPrice'] as num?)?.toDouble() ?? 0.0;
    final totalPrice =
        (map['totalPrice'] as num?)?.toDouble() ?? (quantity * unitPrice);

    return InvoiceItemModel(
      id: map['id'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      quantity: quantity,
      unitPrice: unitPrice,
      unitType: map['unitType'] as String? ?? 'unit',
      totalPrice: totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'unitType': unitType,
      'totalPrice': totalPrice,
    };
  }

  InvoiceItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    double? quantity,
    double? unitPrice,
    String? unitType,
    double? totalPrice,
  }) {
    final effectiveQuantity = quantity ?? this.quantity;
    final effectiveUnitPrice = unitPrice ?? this.unitPrice;

    return InvoiceItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: effectiveQuantity,
      unitPrice: effectiveUnitPrice,
      unitType: unitType ?? this.unitType,
      totalPrice: totalPrice ?? (effectiveQuantity * effectiveUnitPrice),
    );
  }
}
