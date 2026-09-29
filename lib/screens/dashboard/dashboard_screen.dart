import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../customers/add_customer_screen.dart';
import '../customers/customers_screen.dart';
import '../invoices/create_invoice_screen.dart';
import '../invoices/invoice_details_screen.dart';
import '../invoices/invoices_screen.dart';
import '../products/add_product_screen.dart';
import '../products/products_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Warm Cream Elegance Palette
  static const Color _bg = AppColors.bg;
  static const Color _cardBg = AppColors.cardBg;
  static const Color _cardBorder = AppColors.cardBorder;
  static const Color _primaryAccent = AppColors.primary;
  static const Color _inputFill = AppColors.inputFill;
  static const Color _textDark = AppColors.textDark;
  static const Color _textMuted = AppColors.textMuted;
  static const Color _textSubtle = AppColors.textSubtle;
  static const Color _danger = AppColors.danger;

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.firebaseUser;
    if (user != null) {
      context.read<CustomerProvider>().loadCustomers(user.uid);
      context.read<ProductProvider>().fetchProducts(userId: user.uid);
      context.read<InvoiceProvider>().loadInvoices(user.uid);
    }
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Color _statusTextColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.partiallyPaid:
        return AppColors.info;
      case InvoiceStatus.overdue:
        return AppColors.danger;
      case InvoiceStatus.pending:
        return AppColors.warning;
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
      case InvoiceStatus.cancelled:
        return _cardBorder;
    }
  }

  void _showCreateActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: _cardBorder, width: 1.5),
            left: BorderSide(color: _cardBorder, width: 1.5),
            right: BorderSide(color: _cardBorder, width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.camel,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Quick Create',
              style: TextStyle(
                color: _textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCreateActionTile(
              icon: Icons.receipt_long_outlined,
              iconColor: _primaryAccent,
              iconBgColor: AppColors.sandLight,
              title: 'New Invoice',
              subtitle: 'Create and issue a customer invoice',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateInvoiceScreen(),
                  ),
                ).then((_) => _loadData());
              },
            ),
            const SizedBox(height: 10),
            _buildCreateActionTile(
              icon: Icons.person_add_outlined,
              iconColor: _primaryAccent,
              iconBgColor: AppColors.sand,
              title: 'Add New Customer',
              subtitle: 'Add a new client to your directory',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
                ).then((_) => _loadData());
              },
            ),
            const SizedBox(height: 10),
            _buildCreateActionTile(
              icon: Icons.add_box_outlined,
              iconColor: AppColors.camelDark,
              iconBgColor: AppColors.sandLight,
              title: 'Add New Product / Service',
              subtitle: 'Add items or hourly services to your catalog',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                ).then((_) => _loadData());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _textSubtle, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.camelDark,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final productProvider = context.watch<ProductProvider>();
    final invoiceProvider = context.watch<InvoiceProvider>();

    final user = authProvider.user;
    final userName = user?.name.trim();
    final firstName = (userName != null && userName.isNotEmpty)
        ? userName.split(' ').first
        : 'Business';

    final businessName = (userName != null && userName.isNotEmpty)
        ? userName.toUpperCase()
        : 'MY WORKSPACE';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Header with Logout
                  _buildHeader(context),
                  const SizedBox(height: 16),

                  // Hero Overview Card (Revenue & Outstanding)
                  _buildHeroOverviewCard(
                    businessName: businessName,
                    firstName: firstName,
                    invoiceProvider: invoiceProvider,
                  ),

                  const SizedBox(height: 18),

                  // 3 Metric Cards: INVOICES, PAID, PENDING
                  _buildThreeStatCards(invoiceProvider),

                  const SizedBox(height: 22),

                  // Quick Actions Row
                  _buildQuickActionsSection(),

                  const SizedBox(height: 22),

                  // Recent Invoices Section
                  _buildRecentInvoicesSection(invoiceProvider),

                  const SizedBox(height: 22),

                  // Directory Modules (Customers & Products)
                  _buildManagementCards(customerProvider, productProvider),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _cardBg,
          border: Border(top: BorderSide(color: _cardBorder, width: 1.2)),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildBottomNavigationBar(
                customerProvider.totalCustomerCount,
                productProvider.products.length,
                invoiceProvider.totalInvoicesCount,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// App Header with logo and Logout button
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: _primaryAccent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F4C75),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INVOXA',
              style: TextStyle(
                color: _textDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Business Suite',
              style: TextStyle(color: AppColors.iceBlue, fontSize: 10),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cardBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded, color: _danger, size: 14),
                SizedBox(width: 4),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Premium Hero Overview Card in Deep Oceanic Blue with Ice Blue accents
  Widget _buildHeroOverviewCard({
    required String businessName,
    required String firstName,
    required InvoiceProvider invoiceProvider,
  }) {
    final greeting = '${_getGreeting()}, $firstName 👋';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.oceanBlue,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.azureBlue.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330F4C75),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Business Name + Live Business Overview Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.iceBlue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x28BBE1FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.azureBlue,
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'Live Business Overview',
                  style: TextStyle(
                    color: AppColors.iceBlue,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Greeting
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          const Text(
            'Here is your financial and billing health at a glance.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),

          // Thin Divider
          Container(height: 1, color: const Color(0x33BBE1FA)),
          const SizedBox(height: 16),

          // Revenue & Outstanding row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Total Revenue Collected
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Revenue Collected',
                      style: TextStyle(
                        color: AppColors.iceBlue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatCurrency(invoiceProvider.totalRevenue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Outstanding Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFFFBBF24),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Outstanding',
                        style: TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatCurrency(invoiceProvider.totalOutstanding),
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3 Stat Cards in a row: INVOICES, PAID, PENDING
  Widget _buildThreeStatCards(InvoiceProvider invoiceProvider) {
    return Row(
      children: [
        // 1: INVOICES
        Expanded(
          child: _buildMetricCard(
            title: 'INVOICES',
            value: '${invoiceProvider.totalInvoicesCount}',
            subtitle: 'Generated total',
            titleColor: _textDark,
            subtitleColor: _textSubtle,
            icon: Icons.description_outlined,
            iconColor: _primaryAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoicesScreen()),
              ).then((_) => _loadData());
            },
          ),
        ),
        const SizedBox(width: 10),

        // 2: PAID
        Expanded(
          child: _buildMetricCard(
            title: 'PAID',
            value: '${invoiceProvider.paidInvoicesCount}',
            subtitle: 'Cleared in full',
            titleColor: AppColors.success,
            subtitleColor: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.success,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoicesScreen()),
              ).then((_) => _loadData());
            },
          ),
        ),
        const SizedBox(width: 10),

        // 3: PENDING
        Expanded(
          child: _buildMetricCard(
            title: 'PENDING',
            value: '${invoiceProvider.pendingInvoicesCount}',
            subtitle: 'Unpaid / Partial',
            titleColor: AppColors.warning,
            subtitleColor: AppColors.warning,
            icon: Icons.access_time_rounded,
            iconColor: AppColors.warning,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoicesScreen()),
              ).then((_) => _loadData());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color titleColor,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, color: iconColor, size: 14),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            color: _textDark,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Action 1: New Invoice
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateInvoiceScreen(),
                    ),
                  ).then((_) => _loadData());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryAccent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330F4C75),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: _primaryAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'New Invoice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Start billing',
                        style: TextStyle(
                          color: AppColors.iceBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Action 2: Add Customer
            Expanded(
              child: _buildStandardActionCard(
                icon: Icons.person_add_alt_1_rounded,
                iconColor: AppColors.iceBlue,
                iconBgColor: AppColors.oceanBlue,
                title: 'Add Customer',
                subtitle: 'Directory',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddCustomerScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 10),

            // Action 3: Add Product
            Expanded(
              child: _buildStandardActionCard(
                icon: Icons.inventory_2_rounded,
                iconColor: AppColors.azureBlue,
                iconBgColor: AppColors.sandLight,
                title: 'Add Product',
                subtitle: 'Catalog',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddProductScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: _textSubtle,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Invoices Section
  Widget _buildRecentInvoicesSection(InvoiceProvider invoiceProvider) {
    final recentInvoices = invoiceProvider.recentInvoices(5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT INVOICES',
              style: TextStyle(
                color: _textDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                ).then((_) => _loadData());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All (${invoiceProvider.totalInvoicesCount})',
                    style: const TextStyle(
                      color: _primaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _primaryAccent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (invoiceProvider.isLoading && invoiceProvider.allInvoices.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: _primaryAccent),
            ),
          )
        else if (recentInvoices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.sandLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: _primaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No Invoices Generated Yet',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create your first invoice to start billing customers and tracking payments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textSubtle, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    foregroundColor: AppColors.cream,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateInvoiceScreen(),
                      ),
                    ).then((_) => _loadData());
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    'Create Invoice',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < recentInvoices.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildRecentInvoiceCard(recentInvoices[i]),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildRecentInvoiceCard(InvoiceModel invoice) {
    final status = invoice.effectiveStatus;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceDetailsScreen(invoice: invoice),
          ),
        ).then((_) => _loadData());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            // Document Icon Box
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.sandLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cardBorder),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: _primaryAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Invoice # + date, Customer Name, items count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${invoice.invoiceNumber}  •  ${_formatDateIso(invoice.dueDate)}',
                    style: const TextStyle(
                      color: _textSubtle,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoice.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${invoice.items.length} ${invoice.items.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      color: _textSubtle,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right: Amount and Status Pill
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(invoice.totalAmount),
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusPill(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Status badge matching warm palette
  Widget _buildStatusPill(InvoiceStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusBgColor(status),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _statusBorderColor(status), width: 0.8),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          color: _statusTextColor(status),
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  /// Directory Modules for Customers & Products
  Widget _buildManagementCards(
    CustomerProvider customerProvider,
    ProductProvider productProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MANAGE DIRECTORIES',
          style: TextStyle(
            color: _textDark,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Customers Directory
            Expanded(
              child: _buildManagementTile(
                title: 'Customers',
                subtitle: '${customerProvider.totalCustomerCount} Active',
                icon: Icons.people_outline_rounded,
                iconColor: _primaryAccent,
                iconBgColor: AppColors.sand,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()),
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 10),

            // Products Catalog
            Expanded(
              child: _buildManagementTile(
                title: 'Products',
                subtitle: '${productProvider.products.length} Items',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.camelDark,
                iconBgColor: AppColors.sandLight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()),
                  ).then((_) => _loadData());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _textSubtle, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.camelDark,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Navigation Bar matching Warm Cream Elegance theme
  Widget _buildBottomNavigationBar(
    int customerCount,
    int productCount,
    int invoiceCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 0: Home
          _buildBottomNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Home',
            isSelected: _currentNavIndex == 0,
            onTap: () {
              setState(() {
                _currentNavIndex = 0;
              });
            },
          ),

          // 1: Invoices
          _buildBottomNavItem(
            icon: Icons.receipt_long_outlined,
            label: 'Invoices',
            isSelected: _currentNavIndex == 1,
            badgeCount: invoiceCount > 0 ? invoiceCount : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoicesScreen()),
              ).then((_) => _loadData());
            },
          ),

          // 2: Center Floating Action (+)
          InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: _showCreateActionSheet,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: _primaryAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33113946),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.cream,
                size: 26,
              ),
            ),
          ),

          // 3: Customers
          _buildBottomNavItem(
            icon: Icons.people_outline_rounded,
            label: 'Customers',
            isSelected: _currentNavIndex == 3,
            badgeCount: customerCount > 0 ? customerCount : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              ).then((_) => _loadData());
            },
          ),

          // 4: Items / Products
          _buildBottomNavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Items',
            isSelected: _currentNavIndex == 4,
            badgeCount: productCount > 0 ? productCount : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsScreen()),
              ).then((_) => _loadData());
            },
          ),
        ],
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
    final activeColor = _primaryAccent;
    const inactiveColor = _textSubtle;

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
                        color: _primaryAccent,
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
                          color: AppColors.cream,
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
