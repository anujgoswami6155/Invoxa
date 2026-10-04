import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../theme/app_theme.dart';
import 'create_invoice_screen.dart';
import 'invoice_details_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // Warm Cream Elegance Palette
  static const Color _bg = AppColors.bg;
  static const Color _cardBg = AppColors.cardBg;
  static const Color _cardBorder = AppColors.cardBorder;
  static const Color _primaryAccent = AppColors.primary;
  static const Color _textDark = AppColors.textDark;
  static const Color _textMuted = AppColors.textMuted;
  static const Color _textSubtle = AppColors.textSubtle;
  static const Color _danger = AppColors.danger;
  static const Color _warning = AppColors.warning;
  static const Color _info = AppColors.info;

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
        return AppColors.success;
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
        return AppColors.successBg;
      case InvoiceStatus.partiallyPaid:
        return AppColors.infoBg;
      case InvoiceStatus.overdue:
        return AppColors.dangerBg;
      case InvoiceStatus.pending:
        return AppColors.warningBg;
      case InvoiceStatus.draft:
      case InvoiceStatus.cancelled:
        return AppColors.sandLight;
    }
  }

  Color _statusBorderColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.successBorder;
      case InvoiceStatus.partiallyPaid:
        return AppColors.infoBorder;
      case InvoiceStatus.overdue:
        return AppColors.dangerBorder;
      case InvoiceStatus.pending:
        return AppColors.warningBorder;
      case InvoiceStatus.draft:
        return _cardBorder;
      case InvoiceStatus.cancelled:
        return AppColors.dangerBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final invoices = provider.invoices;

        return Scaffold(
          backgroundColor: _bg,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 1),
            child: Container(
              decoration: const BoxDecoration(
                color: _cardBg,
                border: Border(bottom: BorderSide(color: _cardBorder, width: 1)),
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: _textDark),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Invoices',
                            style: TextStyle(
                              color: _textDark,
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
                              color: AppColors.sandLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.sandDark),
                            ),
                            child: Text(
                              '${provider.totalInvoicesCount}',
                              style: const TextStyle(
                                color: _primaryAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: _primaryAccent),
                            tooltip: 'Refresh',
                            onPressed: _loadInvoices,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            color: _primaryAccent,
            backgroundColor: _cardBg,
            onRefresh: _loadInvoices,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
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
                              accentColor: AppColors.success,
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
                              accentColor: _primaryAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 2. Search Field
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: _textDark, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search by invoice # or customer...',
                          hintStyle: const TextStyle(
                            color: _textSubtle,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _primaryAccent,
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
                                  color: AppColors.sandLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  color: _primaryAccent,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No invoices found',
                                style: TextStyle(
                                  color: _textDark,
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
                                  foregroundColor: AppColors.cream,
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
                                            color: _textDark,
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
                                                color: _textDark,
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
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: _primaryAccent,
            foregroundColor: AppColors.cream,
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
            color: isSelected ? AppColors.cream : _textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
