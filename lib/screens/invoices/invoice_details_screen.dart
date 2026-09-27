import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/invoice_pdf_service.dart';
import '../customers/customers_screen.dart';
import '../products/products_screen.dart';
import 'create_invoice_screen.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  // Palette matching Image 1
  static const Color _pageBg = Color(
    0xFFF1F5F9,
  ); // Crisp light slate background
  static const Color _cardWhite = Colors.white;
  static const Color _borderSubtle = Color(0xFFE2E8F0);
  static const Color _emeraldPrimary = Color(
    0xFF00875A,
  ); // Deep emerald in image 1
  static const Color _emeraldLightBg = Color(0xFFF0FDF4);
  static const Color _emeraldBorder = Color(0xFFBBF7D0);
  static const Color _emeraldText = Color(0xFF059669);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSlate = Color(0xFF334155);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _textSubtle = Color(0xFF94A3B8);
  static const Color _danger = Color(0xFFE11D48);
  static const Color _dangerBg = Color(0xFFFFF1F2);
  static const Color _dangerBorder = Color(0xFFFECDD3);
  static const Color _amberText = Color(0xFFD97706);
  static const Color _amberBg = Color(0xFFFFFBEB);
  static const Color _amberBorder = Color(0xFFFDE68A);

  late InvoiceModel _currentInvoice;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
  }

  String _formatDateIso(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    final isWhole = (amount.abs() % 1) == 0;
    final intPart = amount.toInt().abs().toString();
    String formattedInt = '';

    if (intPart.length > 3) {
      final lastThree = intPart.substring(intPart.length - 3);
      final rest = intPart.substring(0, intPart.length - 3);
      final restFormatted = rest.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      formattedInt = '$restFormatted,$lastThree';
    } else {
      formattedInt = intPart;
    }

    if (amount < 0) formattedInt = '-$formattedInt';

    if (isWhole) {
      return '₹$formattedInt';
    } else {
      final decimals = (amount.abs() % 1).toStringAsFixed(2).substring(2);
      return '₹$formattedInt.$decimals';
    }
  }

  void _showRecordPaymentDialog() {
    final balanceDue = _currentInvoice.balanceDue;
    if (balanceDue <= 0.001) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _emeraldPrimary,
          content: Text('This invoice is already paid in full!'),
        ),
      );
      return;
    }

    final amountController = TextEditingController(
      text: balanceDue % 1 == 0
          ? balanceDue.toInt().toString()
          : balanceDue.toStringAsFixed(2),
    );
    final notesController = TextEditingController(
      text: 'Advance IMPS transfer',
    );
    String selectedMethod = 'Bank Transfer';
    String? validationError;

    showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (sbContext, setDlgState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _borderSubtle),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _emeraldLightBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _emeraldBorder),
                    ),
                    child: const Icon(
                      Icons.payment_rounded,
                      color: _emeraldPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Record Payment',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pending Balance info box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pending Balance:',
                              style: TextStyle(color: _textMuted, fontSize: 13),
                            ),
                            Text(
                              _formatCurrency(balanceDue),
                              style: const TextStyle(
                                color: _amberText,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Amount Input
                      const Text(
                        'Payment Amount (₹)',
                        style: TextStyle(
                          color: _textSlate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixIcon: const Icon(
                            Icons.currency_rupee_rounded,
                            color: _emeraldPrimary,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: validationError != null
                                  ? _danger
                                  : _borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: validationError != null
                                  ? _danger
                                  : _emeraldPrimary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          final amt = double.tryParse(val.trim()) ?? 0.0;
                          setDlgState(() {
                            if (amt <= 0) {
                              validationError =
                                  'Amount must be greater than ₹0';
                            } else if (amt > balanceDue + 0.001) {
                              validationError =
                                  'Amount cannot exceed pending balance of ${_formatCurrency(balanceDue)}';
                            } else {
                              validationError = null;
                            }
                          });
                        },
                      ),

                      // Validation Error Message
                      if (validationError != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: _danger,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                validationError!,
                                style: const TextStyle(
                                  color: _danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Quick selection chips
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            backgroundColor: _emeraldLightBg,
                            side: const BorderSide(color: _emeraldBorder),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            label: Text(
                              'Full Amount (${_formatCurrency(balanceDue)})',
                              style: const TextStyle(
                                color: _emeraldText,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              setDlgState(() {
                                amountController.text = balanceDue % 1 == 0
                                    ? balanceDue.toInt().toString()
                                    : balanceDue.toStringAsFixed(2);
                                validationError = null;
                              });
                            },
                          ),
                          if (balanceDue > 1)
                            ActionChip(
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: const BorderSide(color: _borderSubtle),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              label: Text(
                                '50% (${_formatCurrency(balanceDue / 2)})',
                                style: const TextStyle(
                                  color: _textSlate,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                final half = balanceDue / 2;
                                setDlgState(() {
                                  amountController.text = half % 1 == 0
                                      ? half.toInt().toString()
                                      : half.toStringAsFixed(2);
                                  validationError = null;
                                });
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Payment Method
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          color: _textSlate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedMethod,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: _textDark, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _borderSubtle),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Bank Transfer',
                            child: Text('Bank Transfer (NEFT/RTGS/IMPS)'),
                          ),
                          DropdownMenuItem(
                            value: 'UPI / Online',
                            child: Text('UPI / Online Payment'),
                          ),
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(
                            value: 'Cheque',
                            child: Text('Cheque / DD'),
                          ),
                          DropdownMenuItem(
                            value: 'Card',
                            child: Text('Credit / Debit Card'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDlgState(() => selectedMethod = val);
                          }
                        },
                      ),

                      const SizedBox(height: 14),

                      // Notes / Reference
                      const Text(
                        'Notes / Reference Note',
                        style: TextStyle(
                          color: _textSlate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesController,
                        style: const TextStyle(color: _textDark, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'e.g. Advance IMPS transfer / UTR #12345',
                          hintStyle: const TextStyle(color: _textSubtle),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _borderSubtle),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emeraldPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final amt =
                        double.tryParse(amountController.text.trim()) ?? 0.0;

                    // Strict validation: amount must be > 0 and <= balanceDue
                    if (amt <= 0) {
                      setDlgState(() {
                        validationError =
                            'Please enter an amount greater than zero.';
                      });
                      return;
                    }

                    if (amt > balanceDue + 0.001) {
                      setDlgState(() {
                        validationError =
                            'Cannot record ₹${amt.toStringAsFixed(2)}. Pending balance is only ${_formatCurrency(balanceDue)}.';
                      });
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
                          paymentMethod: selectedMethod,
                          notes: notesController.text.trim(),
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
                          backgroundColor: const Color(0xFF064E3B),
                          content: Text(
                            'Payment of ${_formatCurrency(amt)} recorded successfully!',
                            style: const TextStyle(color: Color(0xFFA7F3D0)),
                          ),
                        ),
                      );
                    } else if (mounted) {
                      final errMsg = context
                          .read<InvoiceProvider>()
                          .errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _danger,
                          content: Text(errMsg ?? 'Failed to record payment.'),
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
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _borderSubtle),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: _danger, size: 24),
              SizedBox(width: 8),
              Text(
                'Delete Invoice',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete invoice ${_currentInvoice.invoiceNumber}? This action cannot be undone.',
            style: const TextStyle(color: _textMuted, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                elevation: 0,
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

  Future<void> _handlePrintOrDownloadPdf({
    bool downloadDirectly = false,
  }) async {
    final authUser = context.read<AuthProvider>().user;
    final businessName = (authUser?.name.trim().isNotEmpty ?? false)
        ? (authUser!.name.toLowerCase().contains('enterprises') ||
                  authUser.name.toLowerCase().contains('solutions')
              ? authUser.name
              : '${authUser.name} Enterprises & Solutions')
        : 'Rahul Enterprises & Solutions';
    const businessAddress =
        'Suite 402, Trade Tower, MG Road, Bengaluru, Karnataka 560001';
    final businessEmail = (authUser?.email.trim().isNotEmpty ?? false)
        ? authUser!.email
        : 'rahul@invoxa.app';
    const businessPhone = '+919876543210';

    try {
      final String? result;
      if (downloadDirectly) {
        result = await InvoicePdfService.downloadOrSharePdf(
          invoice: _currentInvoice,
          businessName: businessName,
          businessAddress: businessAddress,
          businessEmail: businessEmail,
          businessPhone: businessPhone,
        );
      } else {
        result = await InvoicePdfService.printPdf(
          invoice: _currentInvoice,
          businessName: businessName,
          businessAddress: businessAddress,
          businessEmail: businessEmail,
          businessPhone: businessPhone,
        );
      }

      if (mounted &&
          result != null &&
          result.isNotEmpty &&
          result != 'Printed') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF064E3B),
            content: Text(
              'PDF successfully saved: $result',
              style: const TextStyle(color: Color(0xFFA7F3D0)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _danger,
            content: Text('Failed to generate PDF: $e'),
          ),
        );
      }
    }
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share ${_currentInvoice.invoiceNumber}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: _textMuted),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _emeraldLightBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: _emeraldPrimary,
                    ),
                  ),
                  title: const Text(
                    'Download PDF Invoice',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Save ${_currentInvoice.invoiceNumber}.pdf to device',
                    style: const TextStyle(color: _textMuted, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _handlePrintOrDownloadPdf(downloadDirectly: true);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.copy_rounded, color: _textDark),
                  ),
                  title: const Text(
                    'Copy Invoice Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Copy invoice text details to clipboard',
                    style: TextStyle(color: _textMuted, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice details copied to clipboard!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrintDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Export ${_currentInvoice.invoiceNumber}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: _textMuted),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _emeraldLightBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: _emeraldPrimary,
                    ),
                  ),
                  title: const Text(
                    'Download PDF File',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Directly download ${_currentInvoice.invoiceNumber}.pdf',
                    style: const TextStyle(color: _textMuted, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _handlePrintOrDownloadPdf(downloadDirectly: true);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.print_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  title: const Text(
                    'Print / PDF Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Open print dialog and preview',
                    style: TextStyle(color: _textMuted, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _handlePrintOrDownloadPdf(downloadDirectly: false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().user;
    final balanceDue = _currentInvoice.balanceDue;
    final effectiveStatus = _currentInvoice.effectiveStatus;
    final effectivePayments = _currentInvoice.effectivePayments;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    // Business details from Image 1 / user account
    final businessName = (authUser?.name.trim().isNotEmpty ?? false)
        ? (authUser!.name.toLowerCase().contains('enterprises') ||
                  authUser.name.toLowerCase().contains('solutions')
              ? authUser.name
              : '${authUser.name} Enterprises & Solutions')
        : 'Rahul Enterprises & Solutions';
    final businessAddress =
        'Suite 402, Trade Tower, MG Road, Bengaluru, Karnataka 560001';
    final businessEmail = (authUser?.email.trim().isNotEmpty ?? false)
        ? authUser!.email
        : 'rahul@invoxa.app';
    const businessPhone = '+919876543210';

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top App Navigation Bar matching image 1
                    _buildTopHeaderBar(),

                    const SizedBox(height: 16),

                    // Top Banner Card (Pending balance / settled status)
                    _buildPendingBalanceBanner(balanceDue),

                    const SizedBox(height: 16),

                    // The White Invoice Paper Document Card
                    _buildInvoiceDocumentCard(
                      businessName: businessName,
                      businessAddress: businessAddress,
                      businessEmail: businessEmail,
                      businessPhone: businessPhone,
                      effectiveStatus: effectiveStatus,
                      balanceDue: balanceDue,
                      effectivePayments: effectivePayments,
                      isDesktop: isDesktop,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _borderSubtle, width: 1.0)),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildBottomNavigationBar(context),
            ),
          ),
        ),
      ),
    );
  }

  /// Top Bar with Back Button on Left and Action Buttons on Right
  Widget _buildTopHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pill Back button
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderSubtle),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_back_rounded, size: 16, color: _textDark),
                SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Icons on Right
        Row(
          children: [
            _buildCircularIconButton(
              icon: Icons.share_outlined,
              tooltip: 'Share Invoice',
              onTap: _showShareDialog,
            ),
            const SizedBox(width: 8),
            _buildCircularIconButton(
              icon: Icons.print_outlined,
              tooltip: 'Print / Export PDF',
              onTap: _showPrintDialog,
            ),
            const SizedBox(width: 8),
            _buildCircularIconButton(
              icon: Icons.delete_outline_rounded,
              tooltip: 'Delete Invoice',
              iconColor: _danger,
              bgColor: _dangerBg,
              borderColor: _dangerBorder,
              onTap: _confirmDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor ?? Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor ?? _borderSubtle),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: iconColor ?? _textMuted),
        ),
      ),
    );
  }

  /// Emerald green banner card on top
  Widget _buildPendingBalanceBanner(double balanceDue) {
    final isSettled = balanceDue <= 0.001;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isSettled ? const Color(0xFF047857) : _emeraldPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1800875A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Label & Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSettled ? 'BALANCE STATUS' : 'PENDING BALANCE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSettled ? 'PAID IN FULL' : _formatCurrency(balanceDue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Right: Button
          if (!isSettled)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _emeraldPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _showRecordPaymentDialog,
              icon: const Icon(
                Icons.credit_card_outlined,
                size: 18,
                color: _emeraldPrimary,
              ),
              label: const Text(
                'Record Payment',
                style: TextStyle(
                  color: _emeraldPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Settled',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// White Sheet Invoice Card matching Image 1
  Widget _buildInvoiceDocumentCard({
    required String businessName,
    required String businessAddress,
    required String businessEmail,
    required String businessPhone,
    required InvoiceStatus effectiveStatus,
    required double balanceDue,
    required List<InvoicePaymentModel> effectivePayments,
    required bool isDesktop,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 28 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header: Company Info on Left, Tax Invoice & Status on Right
          _buildCompanyAndInvoiceHeader(
            businessName: businessName,
            businessAddress: businessAddress,
            businessEmail: businessEmail,
            businessPhone: businessPhone,
            effectiveStatus: effectiveStatus,
          ),

          const SizedBox(height: 28),

          // 2. Billed To & Dates Row
          _buildBilledToAndDates(),

          const SizedBox(height: 24),

          // 3. Line Items Table
          _buildItemsTable(),

          const SizedBox(height: 18),

          // 4. Calculations Summary (Subtotal, Total, Paid, Balance)
          _buildSummaryBreakdown(),

          const SizedBox(height: 22),

          // 5. Notes & Payment Instructions
          _buildNotesSection(),

          const SizedBox(height: 20),
          const Divider(color: _borderSubtle, height: 1),
          const SizedBox(height: 20),

          // 6. Payment History Section
          _buildPaymentHistorySection(effectivePayments, balanceDue),
        ],
      ),
    );
  }

  /// Header row containing Company logo/details and Tax Invoice / Number / Badge
  Widget _buildCompanyAndInvoiceHeader({
    required String businessName,
    required String businessAddress,
    required String businessEmail,
    required String businessPhone,
    required InvoiceStatus effectiveStatus,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Emerald square icon + Business info
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _emeraldPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessAddress,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$businessEmail • $businessPhone',
                      style: const TextStyle(color: _textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right: TAX INVOICE, INV-0011, Status badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'TAX INVOICE',
              style: TextStyle(
                color: _textSubtle,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _currentInvoice.invoiceNumber,
              style: const TextStyle(
                color: _textDark,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            _buildStatusBadge(effectiveStatus),
          ],
        ),
      ],
    );
  }

  /// Status badge matching Image 1
  Widget _buildStatusBadge(InvoiceStatus status) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        bg = _emeraldLightBg;
        border = _emeraldBorder;
        text = _emeraldText;
        icon = Icons.check_circle_outline_rounded;
        label = 'PAID';
        break;
      case InvoiceStatus.partiallyPaid:
        bg = _amberBg;
        border = _amberBorder;
        text = _amberText;
        icon = Icons.access_time_rounded;
        label = 'PARTIALLY PAID';
        break;
      case InvoiceStatus.overdue:
        bg = _dangerBg;
        border = _dangerBorder;
        text = _danger;
        icon = Icons.error_outline_rounded;
        label = 'OVERDUE';
        break;
      case InvoiceStatus.pending:
        bg = _amberBg;
        border = _amberBorder;
        text = _amberText;
        icon = Icons.access_time_rounded;
        label = 'PENDING';
        break;
      case InvoiceStatus.draft:
      case InvoiceStatus.cancelled:
        bg = const Color(0xFFF1F5F9);
        border = _borderSubtle;
        text = _textMuted;
        icon = Icons.info_outline_rounded;
        label = status.displayName.toUpperCase();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Billed To details on Left, Dates on Right
  Widget _buildBilledToAndDates() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Billed To Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BILLED TO',
                style: TextStyle(
                  color: _textSubtle,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _currentInvoice.customerName.isNotEmpty
                    ? _currentInvoice.customerName
                    : 'Customer',
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentInvoice.customerPhone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _currentInvoice.customerPhone,
                  style: const TextStyle(color: _textMuted, fontSize: 13),
                ),
              ],
              if (_currentInvoice.customerEmail.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _currentInvoice.customerEmail,
                  style: const TextStyle(color: _textMuted, fontSize: 13),
                ),
              ],
              if (_currentInvoice.customerAddress.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _currentInvoice.customerAddress,
                  style: const TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Dates Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'INVOICE DATE',
              style: TextStyle(
                color: _textSubtle,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateIso(_currentInvoice.issueDate),
              style: const TextStyle(
                color: _textDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'DUE DATE',
              style: TextStyle(
                color: _textSubtle,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateIso(_currentInvoice.dueDate),
              style: TextStyle(
                color: _currentInvoice.isOverdue ? _danger : _textDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Line Items Table inside a rounded container
  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderSubtle),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 5,
                  child: Text(
                    'ITEM & DESCRIPTION',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'PRICE × QTY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'SUBTOTAL',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: _borderSubtle, height: 1),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentInvoice.items.length,
            separatorBuilder: (_, _) =>
                const Divider(color: Color(0xFFF1F5F9), height: 1),
            itemBuilder: (context, index) {
              final item = _currentInvoice.items[index];
              final qtyFormatted = item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toString();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Item Name
                    Expanded(
                      flex: 5,
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Price x Qty
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${_formatCurrency(item.unitPrice)} × $qtyFormatted',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _textSlate, fontSize: 12),
                      ),
                    ),

                    // Subtotal
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatCurrency(item.totalPrice),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Calculation Breakdown Summary on Right
  Widget _buildSummaryBreakdown() {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          children: [
            _buildSummaryRow(
              'Subtotal',
              _formatCurrency(_currentInvoice.subtotal),
              color: _textMuted,
            ),
            if (_currentInvoice.taxRate > 0) ...[
              const SizedBox(height: 6),
              _buildSummaryRow(
                'Tax (${_currentInvoice.taxRate}%)',
                '+ ${_formatCurrency(_currentInvoice.taxAmount)}',
                color: _textMuted,
              ),
            ],
            if (_currentInvoice.discountAmount > 0) ...[
              const SizedBox(height: 6),
              _buildSummaryRow(
                'Discount',
                '- ${_formatCurrency(_currentInvoice.discountAmount)}',
                color: _danger,
              ),
            ],
            const SizedBox(height: 8),
            const Divider(color: _borderSubtle, height: 1),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Total Amount',
              _formatCurrency(_currentInvoice.totalAmount),
              isBold: true,
              color: _textDark,
              fontSize: 15,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Paid Amount',
              _formatCurrency(_currentInvoice.paidAmount),
              color: _emeraldText,
              isBold: true,
              fontSize: 13,
            ),
            const SizedBox(height: 8),
            _buildDottedDivider(),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Remaining Balance',
              _formatCurrency(_currentInvoice.balanceDue),
              color: _amberText,
              isBold: true,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? _textDark : _textMuted,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? (isBold ? _textDark : _textSlate),
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Custom dotted line matching Image 1
  Widget _buildDottedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
              ),
            );
          }),
        );
      },
    );
  }

  /// Notes & Payment Instructions Section
  Widget _buildNotesSection() {
    final notesText = _currentInvoice.notes.trim().isNotEmpty
        ? _currentInvoice.notes.trim()
        : 'Initial deposit paid on dispatch. Balance due within 15 days.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes & Payment Instructions:',
          style: TextStyle(
            color: _textDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          notesText,
          style: const TextStyle(color: _textMuted, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  /// Payment History List Section matching Image 1
  Widget _buildPaymentHistorySection(
    List<InvoicePaymentModel> payments,
    double balanceDue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header with + Record Payment
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PAYMENT HISTORY (${payments.length})',
              style: const TextStyle(
                color: _textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            if (balanceDue > 0.001)
              InkWell(
                onTap: _showRecordPaymentDialog,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.credit_card_outlined,
                        size: 15,
                        color: _emeraldPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+ Record Payment',
                        style: TextStyle(
                          color: _emeraldPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Payments list
        if (payments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderSubtle),
            ),
            child: const Center(
              child: Text(
                'No payments recorded yet. Click "+ Record Payment" to log payment.',
                style: TextStyle(color: _textMuted, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _emeraldLightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _emeraldBorder),
                ),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.access_time_rounded,
                          color: _emeraldText,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Method & Note
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${payment.paymentMethod} • ${_formatDateIso(payment.date)}',
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (payment.notes.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              payment.notes,
                              style: const TextStyle(
                                color: _textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Amount
                    Text(
                      '+${_formatCurrency(payment.amount)}',
                      style: const TextStyle(
                        color: _emeraldText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  /// Bottom Navigation Bar matching Image 1
  Widget _buildBottomNavigationBar(BuildContext context) {
    final customerCount = context.watch<CustomerProvider>().totalCustomerCount;
    final productCount = context.watch<ProductProvider>().products.length;
    final invoiceCount = context.watch<InvoiceProvider>().totalInvoicesCount;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 0: Home
            _buildBottomNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Home',
              isSelected: false,
              onTap: () {
                Navigator.popUntil(context, (r) => r.isFirst);
              },
            ),

            // 1: Invoices (Active)
            _buildBottomNavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Invoices',
              isSelected: true,
              badgeCount: invoiceCount > 0 ? invoiceCount : null,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // 2: Center Floating Action (+)
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateInvoiceScreen(),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: _emeraldPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3300875A),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),

            // 3: Customers
            _buildBottomNavItem(
              icon: Icons.people_outline_rounded,
              label: 'Customers',
              isSelected: false,
              badgeCount: customerCount > 0 ? customerCount : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomersScreen()),
                );
              },
            ),

            // 4: Items / Products
            _buildBottomNavItem(
              icon: Icons.inventory_2_outlined,
              label: 'Items',
              isSelected: false,
              badgeCount: productCount > 0 ? productCount : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    final activeColor = _emeraldPrimary;
    const inactiveColor = _textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 22,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _textSlate,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
