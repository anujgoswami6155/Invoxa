import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/customer_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  // Emerald Dark Aesthetic Color Palette (consistent with Auth & Dashboard)
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

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final authProvider = context.read<AuthProvider>();
    final customerProvider = context.read<CustomerProvider>();

    final user = authProvider.firebaseUser;

    if (user == null) {
      return;
    }

    await customerProvider.loadCustomers(user.uid);
  }

  void _navigateToAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    ).then((_) {
      // Reload or refresh query if needed
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.firebaseUser;
        if (user != null) {
          context.read<CustomerProvider>().loadCustomers(user.uid);
        }
      }
    });
  }

  void _showCustomerDetails(CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: _cardBorder, width: 1.5),
              left: BorderSide(color: _cardBorder, width: 1.5),
              right: BorderSide(color: _cardBorder, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 40,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E382B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Customer Header Row
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E2419),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF18422E),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: _primaryAccentLight,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E2419),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF18422E),
                                ),
                              ),
                              child: const Text(
                                'ACTIVE CLIENT',
                                style: TextStyle(
                                  color: Color(0xFFA7F3D0),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            if (customer.createdAt != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Added ${_formatDate(customer.createdAt!)}',
                                style: const TextStyle(
                                  color: _textSubtle,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: _cardBorder, height: 1),
              const SizedBox(height: 20),

              // Detail List Items
              _buildDetailTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email Address',
                value: customer.email.isNotEmpty
                    ? customer.email
                    : 'Not provided',
                copyable: customer.email.isNotEmpty,
              ),

              const SizedBox(height: 12),

              _buildDetailTile(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                value: customer.phone.isNotEmpty
                    ? customer.phone
                    : 'Not provided',
                copyable: customer.phone.isNotEmpty,
              ),

              const SizedBox(height: 12),

              _buildDetailTile(
                icon: Icons.location_on_outlined,
                label: 'Billing Address',
                value: customer.address.isNotEmpty
                    ? customer.address
                    : 'Not provided',
                copyable: customer.address.isNotEmpty,
              ),

              const SizedBox(height: 28),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _confirmDeleteCustomer(customer);
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: _danger,
                      ),
                      label: const Text(
                        'Delete Customer',
                        style: TextStyle(
                          color: _danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _dangerBg,
                        side: const BorderSide(color: _dangerBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF102018),
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF193828),
                          width: 1.1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07120D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _primaryAccentLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: _textMuted),
              tooltip: 'Copy to clipboard',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF0E2419),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFF18422E)),
                    ),
                    content: Text(
                      'Copied $label to clipboard',
                      style: const TextStyle(color: Color(0xFFA7F3D0)),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _confirmDeleteCustomer(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _cardBorder),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: _danger, size: 22),
              SizedBox(width: 10),
              Text(
                'Delete Customer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
            style: const TextStyle(
              color: _textMuted,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final authProvider = context.read<AuthProvider>();
                final customerProvider = context.read<CustomerProvider>();
                final user = authProvider.firebaseUser;

                if (user != null) {
                  final success = await customerProvider.deleteCustomer(
                    user.uid,
                    customer.id,
                  );

                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF0E2419),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF18422E)),
                          ),
                          content: const Text(
                            'Customer deleted successfully',
                            style: TextStyle(color: Color(0xFFA7F3D0)),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _dangerBg,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: _dangerBorder),
                          ),
                          content: Text(
                            customerProvider.errorMessage ??
                                'Could not delete customer',
                            style: const TextStyle(color: Color(0xFFFECDD3)),
                          ),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: const Color(0xFF450A0A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Ambient Radial Background Glow (Emerald aura)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.35),
                  radius: 1.0,
                  colors: const [Color(0x3800D07E), Color(0x2805291C), _bgDark],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Navigation Row
                          _buildTopNav(context),

                          const SizedBox(height: 20),

                          // Header Title & Action
                          _buildHeaderTitle(customerProvider),

                          const SizedBox(height: 18),

                          // Search & Filter Bar
                          _buildSearchBar(customerProvider),

                          const SizedBox(height: 16),

                          // Main Content (List / Loading / Error / Empty)
                          Expanded(child: _buildContent(customerProvider)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddCustomer,
        backgroundColor: _primaryAccent,
        foregroundColor: const Color(0xFF042717),
        elevation: 6,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
        label: const Text(
          'Add Customer',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: _primaryAccentLight,
                ),
                SizedBox(width: 8),
                Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    color: _primaryAccentLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0E2419),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF18422E), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 13,
                color: _primaryAccentLight,
              ),
              SizedBox(width: 6),
              Text(
                'DIRECTORY',
                style: TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTitle(CustomerProvider customerProvider) {
    final count = customerProvider.totalCustomerCount;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Customers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E2419),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF18422E)),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: _primaryAccentLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage customer profiles, billing addresses, and contact info',
                style: TextStyle(color: _textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _loadCustomers,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: _primaryAccentLight,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(CustomerProvider customerProvider) {
    return Container(
      decoration: BoxDecoration(
        color: _inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _inputBorder),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 13.5),
        onChanged: (value) {
          customerProvider.setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search customers by name, email, phone, or address...',
          hintStyle: const TextStyle(color: Color(0xFF43584E), fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primaryAccentLight,
            size: 20,
          ),
          suffixIcon: customerProvider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _textMuted,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    customerProvider.clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(CustomerProvider customerProvider) {
    if (customerProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryAccent,
          strokeWidth: 2.5,
        ),
      );
    }

    if (customerProvider.errorMessage != null) {
      return _buildErrorState(customerProvider);
    }

    final customers = customerProvider.customers;

    if (customers.isEmpty) {
      if (customerProvider.searchQuery.isNotEmpty) {
        return _buildNoSearchResults(customerProvider);
      }
      return _buildEmptyState();
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: customers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showCustomerDetails(customer),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 1.1),
        ),
        child: Row(
          children: [
            // Avatar Circle
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2419),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF18422E), width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: _primaryAccentLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (customer.email.isNotEmpty) ...[
                        const Icon(
                          Icons.mail_outline_rounded,
                          size: 13,
                          color: _primaryAccentLight,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            customer.email,
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (customer.email.isNotEmpty &&
                          customer.phone.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '•',
                            style: TextStyle(color: _textSubtle, fontSize: 12),
                          ),
                        ),
                      if (customer.phone.isNotEmpty) ...[
                        const Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: _primaryAccentLight,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            customer.phone,
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (customer.address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: _textSubtle,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            customer.address,
                            style: const TextStyle(
                              color: _textSubtle,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF4F7663),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2419),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF18422E)),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 34,
                color: _primaryAccentLight,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Customers Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first customer to generate invoices and build ledgers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _navigateToAddCustomer,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text(
                'Add Customer',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryAccent,
                foregroundColor: const Color(0xFF042717),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(CustomerProvider customerProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 44, color: _textSubtle),
            const SizedBox(height: 14),
            Text(
              'No matches for "${customerProvider.searchQuery}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching with a different name, email, or phone number.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                customerProvider.clearSearch();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryAccentLight,
                side: const BorderSide(color: Color(0xFF18422E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(CustomerProvider customerProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _dangerBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _dangerBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44, color: _danger),
            const SizedBox(height: 14),
            const Text(
              'Could not load customers',
              style: TextStyle(
                color: Color(0xFFFECDD3),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              customerProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFDA4AF), fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loadCustomers,
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: const Color(0xFF450A0A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
