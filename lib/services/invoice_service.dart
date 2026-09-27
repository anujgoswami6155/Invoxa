import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/invoice_model.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _invoicesCollection =>
      _firestore.collection('invoices');

  /// Creates a new invoice document in the root collection /invoices/{invoiceId}.
  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    if (invoice.userId.trim().isEmpty) {
      throw ArgumentError('Invoice userId cannot be empty.');
    }

    final docRef = invoice.id.isNotEmpty
        ? _invoicesCollection.doc(invoice.id)
        : _invoicesCollection.doc();

    String finalInvoiceNumber = invoice.invoiceNumber.trim();
    if (finalInvoiceNumber.isEmpty) {
      finalInvoiceNumber = await getNextInvoiceNumber(invoice.userId);
    }

    final invoiceToSave = invoice.copyWith(
      id: docRef.id,
      invoiceNumber: finalInvoiceNumber,
      createdAt: invoice.createdAt,
    );

    debugPrint(
      '[InvoiceService] Creating invoice ${invoiceToSave.invoiceNumber} at ${docRef.path}',
    );

    await docRef.set(invoiceToSave.toMap());

    debugPrint(
      '[InvoiceService] Invoice ${invoiceToSave.invoiceNumber} saved successfully.',
    );

    return invoiceToSave;
  }

  /// Automatically generates the next formatted invoice number (e.g. INV-0001).
  Future<String> getNextInvoiceNumber(String userId) async {
    try {
      final snapshot = await _invoicesCollection
          .where('userId', isEqualTo: userId)
          .get();

      int highestNumber = 0;
      final regex = RegExp(r'INV-(\d+)', caseSensitive: false);

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final numStr = data['invoiceNumber'] as String? ?? '';
        final match = regex.firstMatch(numStr);
        if (match != null) {
          final val = int.tryParse(match.group(1) ?? '0') ?? 0;
          if (val > highestNumber) {
            highestNumber = val;
          }
        }
      }

      if (highestNumber == 0) {
        highestNumber = snapshot.docs.length;
      }

      final nextNumber = highestNumber + 1;
      return 'INV-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      debugPrint(
        '[InvoiceService] Failed to calculate next invoice number: $e',
      );
      return 'INV-0001';
    }
  }

  /// Fetches all invoices belonging to a specific user, sorted in-memory.
  Future<List<InvoiceModel>> getInvoices(String userId) async {
    if (userId.trim().isEmpty) {
      return [];
    }

    debugPrint('[InvoiceService] Fetching invoices for userId: $userId');

    final snapshot = await _invoicesCollection
        .where('userId', isEqualTo: userId)
        .get();

    final invoices = snapshot.docs.map((doc) {
      return InvoiceModel.fromMap(doc.data(), doc.id);
    }).toList();

    // Sort descending by issueDate / createdAt in memory
    invoices.sort((a, b) {
      final dateCompare = b.issueDate.compareTo(a.issueDate);
      if (dateCompare != 0) return dateCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    debugPrint(
      '[InvoiceService] Loaded ${invoices.length} invoices from Firestore.',
    );
    return invoices;
  }

  /// Real-time stream of invoices for a user.
  Stream<List<InvoiceModel>> streamInvoices(String userId) {
    if (userId.trim().isEmpty) {
      return const Stream.empty();
    }

    return _invoicesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final invoices = snapshot.docs.map((doc) {
            return InvoiceModel.fromMap(doc.data(), doc.id);
          }).toList();

          invoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));
          return invoices;
        });
  }

  /// Fetches a single invoice by its document ID with user validation.
  Future<InvoiceModel?> getInvoice({
    required String invoiceId,
    required String userId,
  }) async {
    final doc = await _invoicesCollection.doc(invoiceId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    if (data['userId'] != userId) {
      debugPrint(
        '[InvoiceService] Security check failed: unauthorized access attempt.',
      );
      return null;
    }

    return InvoiceModel.fromMap(data, doc.id);
  }

  /// Updates an existing invoice.
  Future<void> updateInvoice(InvoiceModel invoice) async {
    if (invoice.id.trim().isEmpty) {
      throw ArgumentError('Invoice id cannot be empty for update.');
    }

    final updated = invoice.copyWith(updatedAt: DateTime.now());
    await _invoicesCollection.doc(invoice.id).update(updated.toMap());

    debugPrint('[InvoiceService] Updated invoice ${invoice.id}');
  }

  /// Updates status of an existing invoice.
  Future<void> updateInvoiceStatus({
    required String invoiceId,
    required String userId,
    required InvoiceStatus status,
  }) async {
    final invoice = await getInvoice(invoiceId: invoiceId, userId: userId);
    if (invoice == null) {
      throw Exception('Invoice not found or unauthorized.');
    }

    final updateData = <String, dynamic>{
      'status': status.name,
      'updatedAt': Timestamp.now(),
    };

    if (status == InvoiceStatus.paid && invoice.paidAmount < invoice.totalAmount) {
      updateData['paidAmount'] = invoice.totalAmount;
      final remaining = invoice.totalAmount - invoice.paidAmount;
      if (remaining > 0) {
        final payment = InvoicePaymentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: remaining,
          date: DateTime.now(),
          paymentMethod: 'Manual Settlement',
          notes: 'Marked as paid',
        );
        final updatedPayments = List<InvoicePaymentModel>.from(invoice.payments)
          ..add(payment);
        updateData['payments'] = updatedPayments.map((p) => p.toMap()).toList();
      }
    }

    await _invoicesCollection.doc(invoiceId).update(updateData);

    debugPrint(
      '[InvoiceService] Updated invoice $invoiceId status to ${status.name}',
    );
  }

  /// Records payment amount against an invoice and updates balance & status.
  /// Enforces validation: rejects overpayments and zero/negative amounts.
  Future<InvoiceModel> recordPayment({
    required String invoiceId,
    required String userId,
    required double paymentAmount,
    String paymentMethod = 'Bank Transfer',
    String notes = '',
  }) async {
    final invoice = await getInvoice(invoiceId: invoiceId, userId: userId);
    if (invoice == null) {
      throw Exception('Invoice not found or unauthorized.');
    }

    if (paymentAmount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    final balanceDue = invoice.balanceDue;
    if (paymentAmount > balanceDue + 0.001) {
      throw ArgumentError(
        'Payment amount cannot exceed the pending balance of ₹${balanceDue.toStringAsFixed(2)}.',
      );
    }

    final newPaidAmount = (invoice.paidAmount + paymentAmount).clamp(
      0.0,
      invoice.totalAmount,
    );

    final newStatus = (invoice.totalAmount - newPaidAmount) <= 0.001
        ? InvoiceStatus.paid
        : InvoiceStatus.partiallyPaid;

    final newPayment = InvoicePaymentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: paymentAmount,
      date: DateTime.now(),
      paymentMethod: paymentMethod.trim().isNotEmpty
          ? paymentMethod.trim()
          : 'Bank Transfer',
      notes: notes.trim().isNotEmpty ? notes.trim() : 'Payment received',
    );

    final currentPayments = List<InvoicePaymentModel>.from(invoice.payments);
    if (currentPayments.isEmpty && invoice.paidAmount > 0) {
      currentPayments.add(
        InvoicePaymentModel(
          id: 'prev_${invoice.id}',
          amount: invoice.paidAmount,
          date: invoice.issueDate,
          paymentMethod: 'Bank Transfer',
          notes: 'Advance IMPS transfer',
        ),
      );
    }
    currentPayments.add(newPayment);

    final updatedInvoice = invoice.copyWith(
      paidAmount: newPaidAmount,
      status: newStatus,
      payments: currentPayments,
      updatedAt: DateTime.now(),
    );

    await _invoicesCollection.doc(invoiceId).update({
      'paidAmount': newPaidAmount,
      'status': newStatus.name,
      'payments': currentPayments.map((p) => p.toMap()).toList(),
      'updatedAt': Timestamp.now(),
    });

    debugPrint(
      '[InvoiceService] Recorded payment of $paymentAmount on $invoiceId. New status: ${newStatus.name}',
    );

    return updatedInvoice;
  }

  /// Deletes an invoice document.
  Future<void> deleteInvoice({
    required String invoiceId,
    required String userId,
  }) async {
    final invoice = await getInvoice(invoiceId: invoiceId, userId: userId);
    if (invoice == null) {
      throw Exception('Invoice not found or unauthorized.');
    }

    await _invoicesCollection.doc(invoiceId).delete();
    debugPrint('[InvoiceService] Deleted invoice $invoiceId');
  }
}
