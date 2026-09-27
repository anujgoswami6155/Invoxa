import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  // Emerald Dark Theme Tokens
  static const Color _bgDark = Color(0xFF060D0A);
  static const Color _cardBg = Color(0xFF0B1612);
  static const Color _cardBorder = Color(0xFF14291F);
  static const Color _primaryAccent = Color(0xFF00D07E);
  static const Color _primaryAccentLight = Color(0xFF34D399);
  static const Color _inputFill = Color(0xFF07120D);
  static const Color _inputBorder = Color(0xFF152A1F);
  static const Color _textMuted = Color(0xFF98ACA2);
  static const Color _textSubtle = Color(0xFF5A7568);
  static const Color _danger = Color(0xFFFB7185);
  static const Color _dangerBg = Color(0xFF2D141E);
  static const Color _dangerBorder = Color(0xFF9F1239);
  static const Color _warning = Color(0xFFFBBF24);
  static const Color _warningBg = Color(0xFF2D2310);
  static const Color _warningBorder = Color(0xFF573D0F);
  static const Color _info = Color(0xFF38BDF8);
  static const Color _infoBg = Color(0xFF0B2538);
  static const Color _infoBorder = Color(0xFF0C4A6E);

  late InvoiceModel _currentInvoice;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Color _statusTextColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return _primaryAccentLight;
      case InvoiceStatus.partiallyPaid:
        return _info;
      case InvoiceStatus.overdue:
        return _danger;
      case InvoiceStatus.pending:
        return _warning;
      case InvoiceStatus.draft:
      case InvoiceStatus.cancelled:
        return _textMuted;
    }
  }

  Color _statusBgColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFF0E2419);
      case InvoiceStatus.partiallyPaid:
        return _infoBg;
      case InvoiceStatus.overdue:
        return _dangerBg;
      case InvoiceStatus.pending:
        return _warningBg;
      case InvoiceStatus.draft:
        return const Color(0xFF14241D);
      case InvoiceStatus.cancelled:
        return _dangerBg;
    }
  }

  Color _statusBorderColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFF18422E);
      case InvoiceStatus.partiallyPaid:
        return _infoBorder;
      case InvoiceStatus.overdue:
        return _dangerBorder;
      case InvoiceStatus.pending:
        return _warningBorder;
      case InvoiceStatus.draft:
        return _cardBorder;
      case InvoiceStatus.cancelled:
        return _dangerBorder;
    }
  }

  void _showRecordPaymentDialog() {
    final amountController = TextEditingController(
      text: _currentInvoice.balanceDue.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _cardBorder),
          ),
          title: Row(
            children: const [
              Icon(Icons.payment_rounded, color: _primaryAccent, size: 22),
              SizedBox(width: 8),
              Text(
                'Record Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance Due: ₹ ${_currentInvoice.balanceDue.toStringAsFixed(2)}',
                style: const TextStyle(color: _textMuted, fontSize: 14),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Payment Amount (₹)',
                  labelStyle: const TextStyle(color: _textMuted),
                  prefixIcon: const Icon(
                    Icons.currency_rupee_rounded,
                    color: _primaryAccent,
                  ),
                  filled: true,
                  fillColor: _inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _inputBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    backgroundColor: const Color(0xFF0E2419),
                    side: const BorderSide(color: Color(0xFF18422E)),
                    label: const Text(
                      'Full Amount',
                      style: TextStyle(
                        color: _primaryAccentLight,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      amountController.text = _currentInvoice.balanceDue
                          .toStringAsFixed(2);
                    },
                  ),
                  if (_currentInvoice.balanceDue > 1)
                    ActionChip(
                      backgroundColor: const Color(0xFF0E2419),
                      side: const BorderSide(color: Color(0xFF18422E)),
                      label: const Text(
                        '50%',
                        style: TextStyle(
                          color: _primaryAccentLight,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () {
                        amountController.text = (_currentInvoice.balanceDue / 2)
                            .toStringAsFixed(2);
                      },
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: const Text('Cancel', style: TextStyle(color: _textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryAccent,
                foregroundColor: const Color(0xFF060D0A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final amt =
                    double.tryParse(amountController.text.trim()) ?? 0.0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid payment amount.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dlgContext);

                final user = context.read<AuthProvider>().firebaseUser;
                if (user == null) return;

                final success = await context
                    .read<InvoiceProvider>()
                    .recordPayment(
                      invoiceId: _currentInvoice.id,
                      userId: user.uid,
                      paymentAmount: amt,
                    );

                if (success && mounted) {
                  final updated = context
                      .read<InvoiceProvider>()
                      .getInvoiceById(_currentInvoice.id);
                  if (updated != null) {
                    setState(() {
                      _currentInvoice = updated;
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0E2419),
                      content: Text(
                        'Payment of ₹ ${amt.toStringAsFixed(2)} recorded!',
                        style: const TextStyle(color: Color(0xFFA7F3D0)),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Confirm Payment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(InvoiceStatus newStatus) async {
    final user = context.read<AuthProvider>().firebaseUser;
    if (user == null) return;

    final success = await context.read<InvoiceProvider>().updateInvoiceStatus(
      invoiceId: _currentInvoice.id,
      userId: user.uid,
      status: newStatus,
    );

    if (success && mounted) {
      final updated = context.read<InvoiceProvider>().getInvoiceById(
        _currentInvoice.id,
      );
      if (updated != null) {
        setState(() {
          _currentInvoice = updated;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0E2419),
          content: Text(
            'Invoice status updated to ${newStatus.displayName}',
            style: const TextStyle(color: Color(0xFFA7F3D0)),
          ),
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _cardBorder),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: _danger, size: 22),
              SizedBox(width: 8),
              Text(
                'Delete Invoice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete invoice ${_currentInvoice.invoiceNumber}?',
            style: const TextStyle(color: _textMuted, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: const Text('Cancel', style: TextStyle(color: _textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dlgContext);
                final user = context.read<AuthProvider>().firebaseUser;
                if (user == null) return;

                final success = await context
                    .read<InvoiceProvider>()
                    .deleteInvoice(
                      invoiceId: _currentInvoice.id,
                      userId: user.uid,
                    );

                if (success && mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentInvoice.effectiveStatus;

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentInvoice.invoiceNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: _cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _cardBorder),
            ),
            itemBuilder: (context) => [
              if (status != InvoiceStatus.paid)
                const PopupMenuItem(
                  value: 'mark_paid',
                  child: Text(
                    'Mark as Paid',
                    style: TextStyle(color: _primaryAccentLight),
                  ),
                ),
              if (status != InvoiceStatus.pending)
                const PopupMenuItem(
                  value: 'mark_pending',
                  child: Text(
                    'Mark as Pending',
                    style: TextStyle(color: _warning),
                  ),
                ),
              if (status != InvoiceStatus.cancelled)
                const PopupMenuItem(
                  value: 'mark_cancelled',
                  child: Text(
                    'Void / Cancel',
                    style: TextStyle(color: _textMuted),
                  ),
                ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Invoice', style: TextStyle(color: _danger)),
              ),
            ],
            onSelected: (val) {
              if (val == 'mark_paid') {
                _updateStatus(InvoiceStatus.paid);
              } else if (val == 'mark_pending') {
                _updateStatus(InvoiceStatus.pending);
              } else if (val == 'mark_cancelled') {
                _updateStatus(InvoiceStatus.cancelled);
              } else if (val == 'delete') {
                _confirmDelete();
              }
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: _cardBorder, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Status Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusBgColor(status),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusBorderColor(status),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATUS',
                        style: TextStyle(
                          color: _statusTextColor(
                            status,
                          ).withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.displayName.toUpperCase(),
                        style: TextStyle(
                          color: _statusTextColor(status),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'BALANCE DUE',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${_currentInvoice.balanceDue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _currentInvoice.balanceDue > 0
                              ? Colors.white
                              : _primaryAccentLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Dates & Customer Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Issue Date',
                            style: TextStyle(color: _textSubtle, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(_currentInvoice.issueDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Due Date',
                            style: TextStyle(color: _textSubtle, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(_currentInvoice.dueDate),
                            style: TextStyle(
                              color: _currentInvoice.isOverdue
                                  ? _danger
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: _cardBorder, height: 1),
                  const SizedBox(height: 16),
                  const Text(
                    'Billed To',
                    style: TextStyle(color: _textSubtle, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentInvoice.customerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (_currentInvoice.customerEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _currentInvoice.customerEmail,
                      style: const TextStyle(color: _textMuted, fontSize: 13),
                    ),
                  ],
                  if (_currentInvoice.customerPhone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _currentInvoice.customerPhone,
                      style: const TextStyle(color: _textSubtle, fontSize: 13),
                    ),
                  ],
                  if (_currentInvoice.customerAddress.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _currentInvoice.customerAddress,
                      style: const TextStyle(color: _textSubtle, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Line Items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Line Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentInvoice.items.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: _cardBorder, height: 16),
                    itemBuilder: (context, index) {
                      final item = _currentInvoice.items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unitType} × ₹ ${item.unitPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹ ${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. Financial Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    '₹ ${_currentInvoice.subtotal.toStringAsFixed(2)}',
                  ),
                  if (_currentInvoice.taxRate > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Tax (${_currentInvoice.taxRate}%)',
                      '+ ₹ ${_currentInvoice.taxAmount.toStringAsFixed(2)}',
                    ),
                  ],
                  if (_currentInvoice.discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Discount',
                      '- ₹ ${_currentInvoice.discountAmount.toStringAsFixed(2)}',
                      valueColor: _danger,
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: _cardBorder, height: 1),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Total Amount',
                    '₹ ${_currentInvoice.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                    valueColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Amount Paid',
                    '₹ ${_currentInvoice.paidAmount.toStringAsFixed(2)}',
                    valueColor: _primaryAccentLight,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Balance Due',
                    '₹ ${_currentInvoice.balanceDue.toStringAsFixed(2)}',
                    isBold: true,
                    valueColor: _currentInvoice.balanceDue > 0
                        ? _warning
                        : _primaryAccentLight,
                  ),
                ],
              ),
            ),

            // 5. Notes (if any)
            if (_currentInvoice.notes.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes & Terms',
                      style: TextStyle(color: _textSubtle, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentInvoice.notes,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // 6. Action Button (Record Payment)
            if (_currentInvoice.balanceDue > 0)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryAccent,
                  foregroundColor: const Color(0xFF060D0A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showRecordPaymentDialog,
                icon: const Icon(Icons.add_card_rounded, size: 20),
                label: const Text(
                  'Record Payment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : _textMuted,
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
