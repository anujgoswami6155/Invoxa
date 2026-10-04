import 'package:flutter_test/flutter_test.dart';
import 'package:invoxa/models/customer_model.dart';
import 'package:invoxa/models/invoice_item_model.dart';
import 'package:invoxa/models/invoice_model.dart';
import 'package:invoxa/models/product_model.dart';
import 'package:invoxa/models/user_model.dart';

void main() {
  group('InvoiceItemModel Tests', () {
    test('Calculates total price correctly upon creation', () {
      final item = InvoiceItemModel.create(
        id: 'item_1',
        productId: 'prod_1',
        productName: 'Consulting Service',
        quantity: 5,
        unitPrice: 1500,
        unitType: 'hr',
      );

      expect(item.id, equals('item_1'));
      expect(item.productName, equals('Consulting Service'));
      expect(item.quantity, equals(5));
      expect(item.unitPrice, equals(1500));
      expect(item.unitType, equals('hr'));
      expect(item.totalPrice, equals(7500));
    });

    test('Serializes to map and deserializes from map correctly', () {
      final original = InvoiceItemModel(
        id: 'item_2',
        productId: 'prod_2',
        productName: 'Cloud Architecture Audit',
        quantity: 2,
        unitPrice: 10000,
        unitType: 'service',
        totalPrice: 20000,
      );

      final map = original.toMap();
      final reconstructed = InvoiceItemModel.fromMap(map);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.productId, equals(original.productId));
      expect(reconstructed.productName, equals(original.productName));
      expect(reconstructed.quantity, equals(original.quantity));
      expect(reconstructed.unitPrice, equals(original.unitPrice));
      expect(reconstructed.totalPrice, equals(original.totalPrice));
    });

    test('copyWith updates fields and recomputes total price', () {
      final item = InvoiceItemModel.create(
        id: 'item_3',
        productId: 'prod_3',
        productName: 'Design System',
        quantity: 1,
        unitPrice: 5000,
      );

      final updated = item.copyWith(quantity: 3);
      expect(updated.quantity, equals(3));
      expect(updated.unitPrice, equals(5000));
      expect(updated.totalPrice, equals(15000));
    });
  });

  group('InvoiceStatus Enum Tests', () {
    test('Parses various status string variants correctly', () {
      expect(InvoiceStatus.fromString('draft'), equals(InvoiceStatus.draft));
      expect(InvoiceStatus.fromString('Draft'), equals(InvoiceStatus.draft));
      expect(InvoiceStatus.fromString('pending'), equals(InvoiceStatus.pending));
      expect(InvoiceStatus.fromString('Pending'), equals(InvoiceStatus.pending));
      expect(InvoiceStatus.fromString('paid'), equals(InvoiceStatus.paid));
      expect(InvoiceStatus.fromString('Paid'), equals(InvoiceStatus.paid));
      expect(InvoiceStatus.fromString('overdue'), equals(InvoiceStatus.overdue));
      expect(InvoiceStatus.fromString('cancelled'), equals(InvoiceStatus.cancelled));
      expect(
        InvoiceStatus.fromString('partiallyPaid'),
        equals(InvoiceStatus.partiallyPaid),
      );
      expect(
        InvoiceStatus.fromString('Partially Paid'),
        equals(InvoiceStatus.partiallyPaid),
      );
      expect(
        InvoiceStatus.fromString('partially_paid'),
        equals(InvoiceStatus.partiallyPaid),
      );
      expect(
        InvoiceStatus.fromString('partially-paid'),
        equals(InvoiceStatus.partiallyPaid),
      );
      expect(InvoiceStatus.fromString(null), equals(InvoiceStatus.draft));
      expect(InvoiceStatus.fromString('unknown_status'), equals(InvoiceStatus.draft));
    });

    test('Provides clean human-readable display names', () {
      expect(InvoiceStatus.draft.displayName, equals('Draft'));
      expect(InvoiceStatus.pending.displayName, equals('Pending'));
      expect(InvoiceStatus.partiallyPaid.displayName, equals('Partially Paid'));
      expect(InvoiceStatus.paid.displayName, equals('Paid'));
      expect(InvoiceStatus.overdue.displayName, equals('Overdue'));
      expect(InvoiceStatus.cancelled.displayName, equals('Cancelled'));
    });
  });

  group('InvoiceModel Financial Calculations & Effective Status Tests', () {
    final testItem = InvoiceItemModel.create(
      id: 'it1',
      productId: 'p1',
      productName: 'Software Development',
      quantity: 10,
      unitPrice: 1000,
      unitType: 'hr',
    );

    test('Calculates balance due accurately', () {
      final invoice = InvoiceModel(
        id: 'inv_1',
        userId: 'user_1',
        invoiceNumber: 'INV-0001',
        customerId: 'cust_1',
        customerName: 'Acme Corp',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        items: [testItem],
        subtotal: 10000,
        taxRate: 18,
        taxAmount: 1800,
        discountAmount: 800,
        totalAmount: 11000,
        paidAmount: 5000,
        status: InvoiceStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(invoice.balanceDue, equals(6000));
      expect(invoice.isPaid, isFalse);
      expect(invoice.effectiveStatus, equals(InvoiceStatus.partiallyPaid));
    });

    test('Recognizes fully paid invoice status', () {
      final invoice = InvoiceModel(
        id: 'inv_2',
        userId: 'user_1',
        invoiceNumber: 'INV-0002',
        customerId: 'cust_1',
        customerName: 'Acme Corp',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        items: [testItem],
        subtotal: 10000,
        totalAmount: 10000,
        paidAmount: 10000,
        status: InvoiceStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(invoice.balanceDue, equals(0));
      expect(invoice.isPaid, isTrue);
      expect(invoice.effectiveStatus, equals(InvoiceStatus.paid));
    });

    test('Identifies overdue invoices past due date', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final invoice = InvoiceModel(
        id: 'inv_3',
        userId: 'user_1',
        invoiceNumber: 'INV-0003',
        customerId: 'cust_1',
        customerName: 'Acme Corp',
        issueDate: pastDate.subtract(const Duration(days: 14)),
        dueDate: pastDate,
        items: [testItem],
        subtotal: 10000,
        totalAmount: 10000,
        paidAmount: 0,
        status: InvoiceStatus.pending,
        createdAt: pastDate,
      );

      expect(invoice.isOverdue, isTrue);
      expect(invoice.effectiveStatus, equals(InvoiceStatus.overdue));
    });

    test('Preserves explicit cancelled status even if overdue', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final invoice = InvoiceModel(
        id: 'inv_4',
        userId: 'user_1',
        invoiceNumber: 'INV-0004',
        customerId: 'cust_1',
        customerName: 'Acme Corp',
        issueDate: pastDate.subtract(const Duration(days: 14)),
        dueDate: pastDate,
        items: [testItem],
        subtotal: 10000,
        totalAmount: 10000,
        paidAmount: 0,
        status: InvoiceStatus.cancelled,
        createdAt: pastDate,
      );

      expect(invoice.isOverdue, isFalse);
      expect(invoice.effectiveStatus, equals(InvoiceStatus.cancelled));
    });
  });

  group('CustomerModel Tests', () {
    test('Constructs and creates copy with updated properties', () {
      const customer = CustomerModel(
        id: 'cust_10',
        userId: 'user_1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '+91 9876543210',
        address: '123 Tech Park, Bengaluru',
      );

      final updated = customer.copyWith(phone: '+91 9999988888');
      expect(updated.id, equals('cust_10'));
      expect(updated.name, equals('Jane Doe'));
      expect(updated.phone, equals('+91 9999988888'));
      expect(updated.email, equals('jane@example.com'));
    });
  });

  group('ProductModel Tests', () {
    test('Constructs and creates copy with updated properties', () {
      final product = ProductModel(
        id: 'prod_10',
        userId: 'user_1',
        name: 'Mobile App Wireframing',
        description: 'Comprehensive UI/UX blueprint',
        unitPrice: 15000,
        itemType: 'Hourly Service',
        unitType: 'service',
        createdAt: DateTime.now(),
      );

      final updated = product.copyWith(unitPrice: 18000);
      expect(updated.id, equals('prod_10'));
      expect(updated.name, equals('Mobile App Wireframing'));
      expect(updated.unitPrice, equals(18000));
      expect(updated.unitType, equals('service'));
    });
  });

  group('UserModel Tests', () {
    test('toMap and fromMap retain user properties', () {
      const user = UserModel(
        uid: 'uid_123',
        name: 'Invoxa Founder',
        email: 'founder@invoxa.com',
      );

      final map = user.toMap();
      final restored = UserModel.fromMap('uid_123', map);

      expect(restored.uid, equals('uid_123'));
      expect(restored.name, equals('Invoxa Founder'));
      expect(restored.email, equals('founder@invoxa.com'));
    });
  });
}
