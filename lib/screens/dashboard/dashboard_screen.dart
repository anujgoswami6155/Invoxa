import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../customers/customers_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color _bgDark = Color(0xFF060D0A);
  static const Color _cardBg = Color(0xFF0B1612);
  static const Color _cardBorder = Color(0xFF14291F);
  static const Color _primaryAccentLight = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final displayName =
        user?.name.isNotEmpty == true ? user!.name : 'there';

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.35),
                  radius: 1.0,
                  colors: const [
                    Color(0x3800D07E),
                    Color(0x2805291C),
                    _bgDark,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(
                        context,
                        displayName,
                      ),

                      const SizedBox(height: 36),

                      _buildWelcomeSection(displayName),

                      const SizedBox(height: 28),

                      _buildSectionTitle(),

                      const SizedBox(height: 14),

                      _buildModuleGrid(context),

                      const SizedBox(height: 28),

                      _buildQuickInfo(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String displayName,
  ) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0E2419),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF18422E),
            ),
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
              'Invoice Management',
              style: TextStyle(
                color: Color(0xFF6B8277),
                fontSize: 10.5,
              ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _cardBorder,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 17,
                ),
                SizedBox(width: 7),
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

  Widget _buildWelcomeSection(String displayName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DASHBOARD',
            style: TextStyle(
              color: _primaryAccentLight,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            'Welcome back, $displayName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Manage your customers, invoices and business '
            'information from one place.',
            style: TextStyle(
              color: Color(0xFF84968D),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Text(
      'Quick Access',
      style: TextStyle(
        color: Color(0xFFD1FAE5),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;

        final cards = [
          _ModuleCardData(
            title: 'Customers',
            description:
                'Manage your customer records and contact details.',
            icon: Icons.people_outline_rounded,
            enabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomersScreen(),
                ),
              );
            },
          ),
          _ModuleCardData(
            title: 'Invoices',
            description:
                'Create and manage invoices for your customers.',
            icon: Icons.receipt_long_outlined,
            enabled: false,
          ),
          _ModuleCardData(
            title: 'Reports',
            description:
                'View useful insights about your business.',
            icon: Icons.bar_chart_rounded,
            enabled: false,
          ),
          _ModuleCardData(
            title: 'Profile',
            description:
                'Manage your account and business information.',
            icon: Icons.person_outline_rounded,
            enabled: false,
          ),
        ];

        if (isWide) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              return _buildModuleCard(cards[index]);
            },
          );
        }

        return Column(
          children: cards
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildModuleCard(card),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildModuleCard(_ModuleCardData data) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: data.enabled ? data.onTap : null,
      child: Opacity(
        opacity: data.enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: data.enabled
                  ? const Color(0xFF18422E)
                  : _cardBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2419),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  data.icon,
                  color: _primaryAccentLight,
                  size: 23,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (!data.enabled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF17211D),
                              borderRadius:
                                  BorderRadius.circular(7),
                            ),
                            child: const Text(
                              'SOON',
                              style: TextStyle(
                                color: Color(0xFF6F8178),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      data.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF74877D),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              if (data.enabled)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF4F7663),
                  size: 15,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF08120E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF10251B),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF4F7663),
            size: 17,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'More Invoxa features will be available here as '
              'they are added.',
              style: TextStyle(
                color: Color(0xFF687B72),
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCardData {
  final String title;
  final String description;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _ModuleCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.enabled,
    this.onTap,
  });
}