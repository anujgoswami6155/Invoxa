import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../auth/login_screen.dart';
import '../customers/add_customer_screen.dart';
import '../customers/customers_screen.dart';
import '../products/add_product_screen.dart';
import '../products/products_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Emerald Dark Aesthetic Color Palette (exact theme)
  static const Color _bgDark = Color(0xFF060D0A);
  static const Color _cardBg = Color(0xFF0B1612);
  static const Color _cardBorder = Color(0xFF14291F);
  static const Color _primaryAccent = Color(0xFF00D07E);
  static const Color _primaryAccentLight = Color(0xFF34D399);
  static const Color _inputFill = Color(0xFF07120D);
  static const Color _textMuted = Color(0xFF98ACA2);
  static const Color _textSubtle = Color(0xFF5A7568);

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
    }
  }

  void _showPendingInvoicesNotice() {
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
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E382B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2419),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF18422E)),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: _primaryAccentLight,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Invoices Module In Development',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The invoice generator and billing engine will be enabled in the upcoming update. You can manage your Customers and Product Catalog right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryAccent,
                  foregroundColor: const Color(0xFF042717),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  color: const Color(0xFF1E382B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Quick Create',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCreateActionTile(
              icon: Icons.person_add_outlined,
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
            const SizedBox(height: 10),
            _buildCreateActionTile(
              icon: Icons.receipt_long_outlined,
              title: 'New Invoice',
              subtitle: 'Create and issue a customer invoice',
              isPending: true,
              onTap: () {
                Navigator.pop(ctx);
                _showPendingInvoicesNotice();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPending = false,
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
                color: const Color(0xFF0E2419),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryAccentLight, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2822),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SOON',
                            style: TextStyle(
                              color: Color(0xFF84968D),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
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
              color: Color(0xFF345244),
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

    final user = authProvider.user;
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'there';

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.35),
                  radius: 1.0,
                  colors: [Color(0x3800D07E), Color(0x2805291C), _bgDark],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildWelcomeRow(displayName),
                      const SizedBox(height: 22),

                      // Stat Cards Row (Invoices, Customers, Products)
                      _buildStatsRow(customerProvider, productProvider),

                      const SizedBox(height: 26),

                      // Quick Actions Section (New Invoice, Add Customer, Add Product)
                      _buildQuickActionsSection(),

                      const SizedBox(height: 26),

                      // Management Modules Section (Customers & Products Directory)
                      _buildManagementCards(customerProvider, productProvider),

                      const SizedBox(height: 26),

                      // Recent Invoices Section
                      _buildRecentInvoicesSection(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        customerProvider.totalCustomerCount,
        productProvider.products.length,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0E2419),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF18422E)),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: _primaryAccentLight,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INVOXA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Business Suite',
              style: TextStyle(color: Color(0xFF6B8277), fontSize: 10.5),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFFB7185), size: 16),
                SizedBox(width: 6),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFB6C2BC),
                    fontSize: 12,
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

  Widget _buildWelcomeRow(String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $displayName 👋',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage your customers and product catalog from one place.',
          style: TextStyle(color: _textMuted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    CustomerProvider customerProvider,
    ProductProvider productProvider,
  ) {
    return Row(
      children: [
        // Invoices Stat (Pending)
        Expanded(
          child: _buildStatCard(
            label: 'INVOICES',
            icon: Icons.description_outlined,
            value: '0',
            subtitle: 'Pending billing',
            valueColor: _primaryAccentLight,
            isPending: true,
            onTap: _showPendingInvoicesNotice,
          ),
        ),
        const SizedBox(width: 10),
        // Customers Stat
        Expanded(
          child: _buildStatCard(
            label: 'CUSTOMERS',
            icon: Icons.people_outline_rounded,
            value: '${customerProvider.totalCustomerCount}',
            subtitle: 'Active clients',
            valueColor: const Color(0xFF38BDF8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              ).then((_) => _loadData());
            },
          ),
        ),
        const SizedBox(width: 10),
        // Products Stat
        Expanded(
          child: _buildStatCard(
            label: 'PRODUCTS',
            icon: Icons.inventory_2_outlined,
            value: '${productProvider.products.length}',
            subtitle: 'Catalog items',
            valueColor: const Color(0xFFA78BFA),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsScreen()),
              ).then((_) => _loadData());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required IconData icon,
    required String value,
    required String subtitle,
    required Color valueColor,
    bool isPending = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                  label,
                  style: const TextStyle(
                    color: _textSubtle,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                Icon(icon, color: _textSubtle, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isPending ? const Color(0xFFFBBF24) : _textSubtle,
                      fontSize: 10.5,
                      fontWeight: isPending
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            color: Color(0xFFD1FAE5),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Action 1: New Invoice (Featured Primary)
            Expanded(
              child: _buildFeaturedActionCard(
                icon: Icons.add_rounded,
                title: 'New Invoice',
                subtitle: 'Start billing',
                isPending: true,
                onTap: _showPendingInvoicesNotice,
              ),
            ),
            const SizedBox(width: 10),
            // Action 2: Add Customer
            Expanded(
              child: _buildStandardActionCard(
                icon: Icons.person_add_alt_1_outlined,
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
                icon: Icons.add_box_outlined,
                title: 'Add Product',
                subtitle: 'Catalog',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  ).then((_) => _loadData());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPending = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF00D07E),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4400D07E),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF042717),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primaryAccent, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF042717),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              isPending ? 'Soon' : subtitle,
              style: const TextStyle(
                color: Color(0xFF0A442A),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2419),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF18422E)),
              ),
              child: Icon(icon, color: _primaryAccentLight, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
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
            color: Color(0xFFD1FAE5),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Customers Directory Card
            Expanded(
              child: _buildManagementTile(
                title: 'Customers',
                subtitle: '${customerProvider.totalCustomerCount} Active',
                icon: Icons.people_outline_rounded,
                badgeText: 'VIEW ALL',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()),
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 12),
            // Products Catalog Card
            Expanded(
              child: _buildManagementTile(
                title: 'Products',
                subtitle: '${productProvider.products.length} Items',
                icon: Icons.inventory_2_outlined,
                badgeText: 'CATALOG',
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
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2419),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF18422E)),
              ),
              child: Icon(icon, color: _primaryAccentLight, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
              color: Color(0xFF4F7663),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT INVOICES',
              style: TextStyle(
                color: Color(0xFFD1FAE5),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            TextButton(
              onPressed: _showPendingInvoicesNotice,
              style: TextButton.styleFrom(
                foregroundColor: _primaryAccentLight,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                children: [
                  Text(
                    'View All (0)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Invoices Pending Placeholder Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cardBorder),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2419),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF18422E)),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: _primaryAccentLight,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No Invoices Generated Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Invoices will appear here once generated. Customer records and products are ready for billing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textSubtle, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(int customerCount, int productCount) {
    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: _cardBorder, width: 1.2)),
      ),
      child: SafeArea(
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
                badgeText: 'Soon',
                onTap: _showPendingInvoicesNotice,
              ),

              // 2: Center Floating Action (+)
              InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: _showCreateActionSheet,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _primaryAccent,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x6600D07E),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF042717),
                    size: 28,
                  ),
                ),
              ),

              // 3: Customers
              _buildBottomNavItem(
                icon: Icons.people_outline_rounded,
                label: 'Customers',
                isSelected: _currentNavIndex == 3,
                badgeCount: customerCount,
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
                badgeCount: productCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()),
                  ).then((_) => _loadData());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? badgeText,
    int? badgeCount,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? _primaryAccent : const Color(0xFF7A8D84),
                  size: 22,
                ),
                if (badgeText != null)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2822),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Color(0xFFA7F3D0),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E2419),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF18422E),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Color(0xFFA7F3D0),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _primaryAccent : const Color(0xFF7A8D84),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
