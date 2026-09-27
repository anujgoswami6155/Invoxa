import 'package:cloud_firestore/cloud_firestore.dart';

import 'invoice_item_model.dart';

enum InvoiceStatus {
  draft,
  pending,
  partiallyPaid,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  static InvoiceStatus fromString(String? value) {
    if (value == null) return InvoiceStatus.draft;
    final normalized = value.trim().toLowerCase();
    for (final status in InvoiceStatus.values) {
      if (status.name.toLowerCase() == normalized ||
          status.displayName.toLowerCase() == normalized) {
        return status;
      }
    }
    // Handle kebab/snake case variants
    if (normalized == 'partially-paid' || normalized == 'partially_paid') {
      return InvoiceStatus.partiallyPaid;
    }
    return InvoiceStatus.draft;
  }
}

class InvoicePaymentModel {
  final String id;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String notes;

  const InvoicePaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    this.paymentMethod = 'Bank Transfer',
    this.notes = '',
  });

  factory InvoicePaymentModel.fromMap(Map<String, dynamic> map) {
    return InvoicePaymentModel(
      id: map['id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: _parsePaymentDate(map['date']),
      paymentMethod: map['paymentMethod'] as String? ?? 'Bank Transfer',
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  static DateTime _parsePaymentDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class InvoiceModel {
  final String id;
  final String userId;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItemModel> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final InvoiceStatus status;
  final String notes;
  final List<InvoicePaymentModel> payments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InvoiceModel({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    this.customerEmail = '',
    this.customerPhone = '',
    this.customerAddress = '',
    required this.issueDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.status = InvoiceStatus.draft,
    this.notes = '',
    this.payments = const [],
    required this.createdAt,
    this.updatedAt,
  });

  double get balanceDue =>
      (totalAmount - paidAmount).clamp(0.0, double.infinity);

  bool get isPaid => paidAmount >= totalAmount && totalAmount > 0;

  bool get isOverdue =>
      status != InvoiceStatus.paid &&
      status != InvoiceStatus.cancelled &&
      dueDate.isBefore(DateTime.now());

  InvoiceStatus get effectiveStatus {
    if (status == InvoiceStatus.paid || status == InvoiceStatus.cancelled) {
      return status;
    }
    if (paidAmount >= totalAmount && totalAmount > 0) {
      return InvoiceStatus.paid;
    }
    if (paidAmount > 0 && paidAmount < totalAmount) {
      return InvoiceStatus.partiallyPaid;
    }
    if (isOverdue) {
      return InvoiceStatus.overdue;
    }
    return status;
  }

  List<InvoicePaymentModel> get effectivePayments {
    if (payments.isNotEmpty) return payments;
    if (paidAmount > 0) {
      return [
        InvoicePaymentModel(
          id: 'initial_payment',
          amount: paidAmount,
          date: updatedAt ?? issueDate,
          paymentMethod: 'Bank Transfer',
          notes: status == InvoiceStatus.paid
              ? 'Full Payment'
              : 'Advance IMPS transfer',
        ),
      ];
    }
    return const [];
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map, [String id = '']) {
    final rawItems = map['items'];
    final parsedItems = <InvoiceItemModel>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(InvoiceItemModel.fromMap(item));
        } else if (item is Map) {
          parsedItems.add(
            InvoiceItemModel.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final rawPayments = map['payments'];
    final parsedPayments = <InvoicePaymentModel>[];
    if (rawPayments is List) {
      for (final p in rawPayments) {
        if (p is Map<String, dynamic>) {
          parsedPayments.add(InvoicePaymentModel.fromMap(p));
        } else if (p is Map) {
          parsedPayments.add(
            InvoicePaymentModel.fromMap(Map<String, dynamic>.from(p)),
          );
        }
      }
    }

    return InvoiceModel(
      id: id.isNotEmpty ? id : (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerEmail: map['customerEmail'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      customerAddress: map['customerAddress'] as String? ?? '',
      issueDate: _parseDateTime(map['issueDate']),
      dueDate: _parseDateTime(map['dueDate']),
      items: parsedItems,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      status: InvoiceStatus.fromString(map['status'] as String?),
      notes: map['notes'] as String? ?? '',
      payments: parsedPayments,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? _parseDateTime(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'issueDate': Timestamp.fromDate(issueDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status.name,
      'notes': notes,
      'payments': payments.map((p) => p.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? userId,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItemModel>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    InvoiceStatus? status,
    String? notes,
    List<InvoicePaymentModel>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
