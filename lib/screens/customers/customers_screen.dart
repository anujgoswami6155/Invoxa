import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/customer_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D0A),
      body: SafeArea(
        child: Consumer<CustomerProvider>(
          builder: (context, customerProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildContent(customerProvider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add customer screen will be connected next.
        },
        backgroundColor: const Color(0xFF00D07E),
        foregroundColor: const Color(0xFF060D0A),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your customers',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1612),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF14291F),
            ),
          ),
          child: IconButton(
            onPressed: _loadCustomers,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF34D399),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(CustomerProvider customerProvider) {
    if (customerProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00D07E),
        ),
      );
    }

    if (customerProvider.errorMessage != null) {
      return _buildErrorState(customerProvider);
    }

    if (customerProvider.customers.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCustomerList(customerProvider.customers);
  }

  Widget _buildErrorState(CustomerProvider customerProvider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          const Text(
            'Could not load customers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            customerProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _loadCustomers,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF34D399),
              side: const BorderSide(
                color: Color(0xFF00D07E),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1612),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF14291F),
              ),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 36,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No customers yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first customer to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(List<CustomerModel> customers) {
    return ListView.separated(
      itemCount: customers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final customer = customers[index];

        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1612),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF14291F),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00D07E).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  customer.email.isEmpty
                      ? customer.phone
                      : customer.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF5A7568),
          ),
        ],
      ),
    );
  }
}