import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';
import 'create_invoice_screen.dart';
import 'invoice_details_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // Emerald Dark Theme Tokens
  static const Color _bgDark = Color(0xFF060D0A);
  static const Color _cardBg = Color(0xFF0B1612);
  static const Color _cardBorder = Color(0xFF14291F);
  static const Color _primaryAccent = Color(0xFF00D07E);
  static const Color _primaryAccentLight = Color(0xFF34D399);
  static const Color _textMuted = Color(0xFF98ACA2);
  static const Color _textSubtle = Color(0xFF5A7568);
  static const Color _danger = Color(0xFFFB7185);
  static const Color _warning = Color(0xFFFBBF24);
  static const Color _info = Color(0xFF38BDF8);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    final user = context.read<AuthProvider>().firebaseUser;
    if (user != null) {
      await context.read<InvoiceProvider>().loadInvoices(user.uid);
    }
  }

  void _navigateToCreateInvoice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
    ).then((_) {
      _loadInvoices();
    });
  }

  void _navigateToDetails(InvoiceModel invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoiceDetailsScreen(invoice: invoice)),
    ).then((_) {
      _loadInvoices();
    });
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
        return const Color(0xFF0B2538);
      case InvoiceStatus.overdue:
        return const Color(0xFF2D141E);
      case InvoiceStatus.pending:
        return const Color(0xFF2D2310);
      case InvoiceStatus.draft:
        return const Color(0xFF14241D);
      case InvoiceStatus.cancelled:
        return const Color(0xFF2D141E);
    }
  }

  Color _statusBorderColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFF18422E);
      case InvoiceStatus.partiallyPaid:
        return const Color(0xFF0C4A6E);
      case InvoiceStatus.overdue:
        return const Color(0xFF9F1239);
      case InvoiceStatus.pending:
        return const Color(0xFF573D0F);
      case InvoiceStatus.draft:
        return _cardBorder;
      case InvoiceStatus.cancelled:
        return const Color(0xFF9F1239);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final invoices = provider.invoices;

        return Scaffold(
          backgroundColor: _bgDark,
          appBar: AppBar(
            backgroundColor: _cardBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Text(
                  'Invoices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E2419),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF18422E)),
                  ),
                  child: Text(
                    '${provider.totalInvoicesCount}',
                    style: const TextStyle(
                      color: _primaryAccentLight,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: _textMuted),
                tooltip: 'Refresh',
                onPressed: _loadInvoices,
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(color: _cardBorder, height: 1),
            ),
          ),
          body: RefreshIndicator(
            color: _primaryAccent,
            backgroundColor: _cardBg,
            onRefresh: _loadInvoices,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. KPI Mini Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniKpi(
                          label: 'Revenue',
                          value:
                              '₹ ${provider.totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.payments_outlined,
                          accentColor: _primaryAccentLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniKpi(
                          label: 'Outstanding',
                          value:
                              '₹ ${provider.totalOutstanding.toStringAsFixed(0)}',
                          icon: Icons.hourglass_top_rounded,
                          accentColor: _warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniKpi(
                          label: 'Pending',
                          value: '${provider.pendingInvoicesCount}',
                          icon: Icons.receipt_long_rounded,
                          accentColor: _info,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2. Search Field
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by invoice # or customer...',
                      hintStyle: const TextStyle(
                        color: _textSubtle,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _textMuted,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: _textSubtle,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                provider.clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _primaryAccent),
                      ),
                    ),
                    onChanged: (val) => provider.setSearchQuery(val),
                  ),

                  const SizedBox(height: 12),

                  // 3. Horizontal Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          isSelected: provider.selectedStatusFilter == null,
                          onSelected: () => provider.setStatusFilter(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Pending',
                          isSelected:
                              provider.selectedStatusFilter ==
                              InvoiceStatus.pending,
                          onSelected: () =>
                              provider.setStatusFilter(InvoiceStatus.pending),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Paid',
                          isSelected:
                              provider.selectedStatusFilter ==
                              InvoiceStatus.paid,
                          onSelected: () =>
                              provider.setStatusFilter(InvoiceStatus.paid),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Partially Paid',
                          isSelected:
                              provider.selectedStatusFilter ==
                              InvoiceStatus.partiallyPaid,
                          onSelected: () => provider.setStatusFilter(
                            InvoiceStatus.partiallyPaid,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Overdue',
                          isSelected:
                              provider.selectedStatusFilter ==
                              InvoiceStatus.overdue,
                          onSelected: () =>
                              provider.setStatusFilter(InvoiceStatus.overdue),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Draft',
                          isSelected:
                              provider.selectedStatusFilter ==
                              InvoiceStatus.draft,
                          onSelected: () =>
                              provider.setStatusFilter(InvoiceStatus.draft),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Invoices List
                  if (provider.isLoading && invoices.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: _primaryAccent),
                      ),
                    )
                  else if (invoices.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 48,
                        horizontal: 20,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E2419),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF18422E),
                              ),
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              color: _primaryAccentLight,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No invoices found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.searchQuery.isNotEmpty ||
                                    provider.selectedStatusFilter != null
                                ? 'Try changing your search or filter query'
                                : 'Create your first invoice to start billing clients',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryAccent,
                              foregroundColor: const Color(0xFF060D0A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onPressed: _navigateToCreateInvoice,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text(
                              'Create Invoice',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final invoice = invoices[index];
                        final status = invoice.effectiveStatus;

                        return InkWell(
                          onTap: () => _navigateToDetails(invoice),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _cardBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      invoice.invoiceNumber,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusBgColor(status),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _statusBorderColor(status),
                                        ),
                                      ),
                                      child: Text(
                                        status.displayName,
                                        style: TextStyle(
                                          color: _statusTextColor(status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  invoice.customerName,
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: _cardBorder, height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Due ${_formatDate(invoice.dueDate)}',
                                          style: TextStyle(
                                            color: invoice.isOverdue
                                                ? _danger
                                                : _textSubtle,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '${invoice.items.length} ${invoice.items.length == 1 ? 'item' : 'items'}',
                                          style: const TextStyle(
                                            color: _textSubtle,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹ ${invoice.totalAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (invoice.balanceDue > 0 &&
                                            invoice.balanceDue <
                                                invoice.totalAmount)
                                          Text(
                                            'Bal: ₹ ${invoice.balanceDue.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: _warning,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: _primaryAccent,
            foregroundColor: const Color(0xFF060D0A),
            elevation: 4,
            onPressed: _navigateToCreateInvoice,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'New Invoice',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniKpi({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSubtle, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryAccent : _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primaryAccent : _cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF060D0A) : _textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
