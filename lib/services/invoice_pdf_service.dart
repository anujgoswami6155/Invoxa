import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice_model.dart';
import 'pdf_downloader/pdf_downloader.dart';

class InvoicePdfService {
  static String _formatNumber(double amount) {
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
      return formattedInt;
    } else {
      final decimals = (amount.abs() % 1).toStringAsFixed(2).substring(2);
      return '$formattedInt.$decimals';
    }
  }

  static String _formatCurrency(double amount) {
    return 'Rs. ${_formatNumber(amount)}';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Generates the PDF document matching Image 1
  static Future<Uint8List> generateInvoicePdf({
    required InvoiceModel invoice,
    required String businessName,
    required String businessAddress,
    required String businessEmail,
    required String businessPhone,
  }) async {
    final doc = pw.Document();

    pw.Font? regularFont;
    pw.Font? boldFont;

    try {
      regularFont = await PdfGoogleFonts.robotoRegular();
      boldFont = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      regularFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    final emeraldColor = PdfColor.fromHex('00875A');
    final darkColor = PdfColor.fromHex('0F172A');
    final slateColor = PdfColor.fromHex('334155');
    final mutedColor = PdfColor.fromHex('64748B');
    final subtleColor = PdfColor.fromHex('94A3B8');
    final borderLight = PdfColor.fromHex('E2E8F0');
    final amberColor = PdfColor.fromHex('D97706');
    final lightGreenBg = PdfColor.fromHex('F0FDF4');
    final greenBorder = PdfColor.fromHex('BBF7D0');
    final greenText = PdfColor.fromHex('059669');

    final status = invoice.effectiveStatus;
    final payments = invoice.effectivePayments;

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          return [
            // 1. Header (Company Info on Left, Tax Invoice on Right)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Company Details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 32,
                            height: 32,
                            decoration: pw.BoxDecoration(
                              color: emeraldColor,
                              borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(6),
                              ),
                            ),
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              'I',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Text(
                              businessName,
                              style: pw.TextStyle(
                                color: darkColor,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        businessAddress,
                        style: pw.TextStyle(color: mutedColor, fontSize: 10),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '$businessEmail • $businessPhone',
                        style: pw.TextStyle(color: mutedColor, fontSize: 10),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 20),

                // Invoice Number & Status
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'TAX INVOICE',
                      style: pw.TextStyle(
                        color: subtleColor,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      invoice.invoiceNumber,
                      style: pw.TextStyle(
                        color: darkColor,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: pw.BoxDecoration(
                        color: status == InvoiceStatus.paid
                            ? lightGreenBg
                            : PdfColor.fromHex('FFFBEB'),
                        border: pw.Border.all(
                          color: status == InvoiceStatus.paid
                              ? greenBorder
                              : PdfColor.fromHex('FDE68A'),
                        ),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(12),
                        ),
                      ),
                      child: pw.Text(
                        status.displayName.toUpperCase(),
                        style: pw.TextStyle(
                          color: status == InvoiceStatus.paid
                              ? greenText
                              : amberColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 24),
            pw.Divider(color: borderLight, thickness: 1),
            pw.SizedBox(height: 16),

            // 2. Billed To & Dates
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILLED TO',
                        style: pw.TextStyle(
                          color: subtleColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.customerName,
                        style: pw.TextStyle(
                          color: darkColor,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (invoice.customerPhone.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          invoice.customerPhone,
                          style: pw.TextStyle(color: mutedColor, fontSize: 10),
                        ),
                      ],
                      if (invoice.customerEmail.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          invoice.customerEmail,
                          style: pw.TextStyle(color: mutedColor, fontSize: 10),
                        ),
                      ],
                      if (invoice.customerAddress.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          invoice.customerAddress,
                          style: pw.TextStyle(color: mutedColor, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'INVOICE DATE',
                      style: pw.TextStyle(
                        color: subtleColor,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      _formatDate(invoice.issueDate),
                      style: pw.TextStyle(
                        color: darkColor,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'DUE DATE',
                      style: pw.TextStyle(
                        color: subtleColor,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      _formatDate(invoice.dueDate),
                      style: pw.TextStyle(
                        color: invoice.isOverdue
                            ? PdfColor.fromHex('E11D48')
                            : darkColor,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // 3. Line Items Table
            pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: borderLight, width: 0.5),
                bottom: pw.BorderSide(color: borderLight, width: 1),
                top: pw.BorderSide(color: borderLight, width: 1),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(5),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(3),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('F8FAFC'),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: pw.Text(
                        'ITEM & DESCRIPTION',
                        style: pw.TextStyle(
                          color: mutedColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: pw.Text(
                        'PRICE x QTY',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: mutedColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: pw.Text(
                        'SUBTOTAL',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          color: mutedColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                // Item rows
                ...invoice.items.map((item) {
                  final qtyFormatted = item.quantity % 1 == 0
                      ? item.quantity.toInt().toString()
                      : item.quantity.toString();

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        child: pw.Text(
                          item.productName,
                          style: pw.TextStyle(
                            color: darkColor,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        child: pw.Text(
                          '${_formatCurrency(item.unitPrice)} x $qtyFormatted',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(color: slateColor, fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        child: pw.Text(
                          _formatCurrency(item.totalPrice),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            color: darkColor,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 16),

            // 4. Calculations Summary
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 220,
                child: pw.Column(
                  children: [
                    _buildSummaryRow('Subtotal', _formatCurrency(invoice.subtotal), mutedColor),
                    if (invoice.taxRate > 0) ...[
                      pw.SizedBox(height: 4),
                      _buildSummaryRow(
                        'Tax (${invoice.taxRate}%)',
                        '+ ${_formatCurrency(invoice.taxAmount)}',
                        mutedColor,
                      ),
                    ],
                    if (invoice.discountAmount > 0) ...[
                      pw.SizedBox(height: 4),
                      _buildSummaryRow(
                        'Discount',
                        '- ${_formatCurrency(invoice.discountAmount)}',
                        PdfColor.fromHex('E11D48'),
                      ),
                    ],
                    pw.SizedBox(height: 6),
                    pw.Divider(color: borderLight, thickness: 1),
                    pw.SizedBox(height: 6),
                    _buildSummaryRow(
                      'Total Amount',
                      _formatCurrency(invoice.totalAmount),
                      darkColor,
                      isBold: true,
                      fontSize: 11,
                    ),
                    pw.SizedBox(height: 4),
                    _buildSummaryRow(
                      'Paid Amount',
                      _formatCurrency(invoice.paidAmount),
                      greenText,
                      isBold: true,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Divider(color: borderLight, thickness: 1),
                    pw.SizedBox(height: 6),
                    _buildSummaryRow(
                      'Remaining Balance',
                      _formatCurrency(invoice.balanceDue),
                      amberColor,
                      isBold: true,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // 5. Notes & Instructions
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Notes & Payment Instructions:',
                  style: pw.TextStyle(
                    color: darkColor,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  invoice.notes.trim().isNotEmpty
                      ? invoice.notes.trim()
                      : 'Initial deposit paid on dispatch. Balance due within 15 days.',
                  style: pw.TextStyle(color: mutedColor, fontSize: 9),
                ),
              ],
            ),

            // 6. Payment History if present
            if (payments.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Divider(color: borderLight, thickness: 1),
              pw.SizedBox(height: 10),
              pw.Text(
                'PAYMENT HISTORY (${payments.length})',
                style: pw.TextStyle(
                  color: mutedColor,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 8),
              ...payments.map((p) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: lightGreenBg,
                    border: pw.Border.all(color: greenBorder),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${p.paymentMethod} • ${_formatDate(p.date)}',
                            style: pw.TextStyle(
                              color: darkColor,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (p.notes.isNotEmpty)
                            pw.Text(
                              p.notes,
                              style: pw.TextStyle(color: mutedColor, fontSize: 8),
                            ),
                        ],
                      ),
                      pw.Text(
                        '+ ${_formatCurrency(p.amount)}',
                        style: pw.TextStyle(
                          color: greenText,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ];
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value,
    PdfColor color, {
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: isBold ? PdfColor.fromHex('0F172A') : PdfColor.fromHex('64748B'),
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Downloads or opens the PDF file.
  /// Uses direct native file write / browser blob first so it works even if
  /// native plugin bindings are not recompiled yet.
  static Future<String?> downloadOrSharePdf({
    required InvoiceModel invoice,
    required String businessName,
    required String businessAddress,
    required String businessEmail,
    required String businessPhone,
  }) async {
    final pdfBytes = await generateInvoicePdf(
      invoice: invoice,
      businessName: businessName,
      businessAddress: businessAddress,
      businessEmail: businessEmail,
      businessPhone: businessPhone,
    );

    // 1. Try direct native file saver / browser download first (zero plugin dependency!)
    final directResult = await saveAndLaunchPdf(
      pdfBytes,
      '${invoice.invoiceNumber}.pdf',
    );
    if (directResult != null) {
      return directResult;
    }

    // 2. Fallback to printing package
    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${invoice.invoiceNumber}.pdf',
      );
      return 'Downloaded';
    } catch (_) {
      return null;
    }
  }

  /// Opens the print / PDF preview dialog.
  /// If printing plugin is not linked, falls back to direct download & open.
  static Future<String?> printPdf({
    required InvoiceModel invoice,
    required String businessName,
    required String businessAddress,
    required String businessEmail,
    required String businessPhone,
  }) async {
    try {
      await Printing.layoutPdf(
        name: invoice.invoiceNumber,
        onLayout: (PdfPageFormat format) async {
          return generateInvoicePdf(
            invoice: invoice,
            businessName: businessName,
            businessAddress: businessAddress,
            businessEmail: businessEmail,
            businessPhone: businessPhone,
          );
        },
      );
      return 'Printed';
    } catch (_) {
      // MissingPluginException fallback: Save and launch default viewer
      return await downloadOrSharePdf(
        invoice: invoice,
        businessName: businessName,
        businessAddress: businessAddress,
        businessEmail: businessEmail,
        businessPhone: businessPhone,
      );
    }
  }
}
