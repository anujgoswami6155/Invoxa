import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/invoice_item_model.dart';
import '../../models/invoice_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/product_provider.dart';
import '../customers/add_customer_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  // Emerald Dark Aesthetic Palette
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

  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDraft();
    });
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _taxRateController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initDraft() async {
    final authProvider = context.read<AuthProvider>();
    final invoiceProvider = context.read<InvoiceProvider>();
    final user = authProvider.firebaseUser;

    if (user != null) {
      context.read<CustomerProvider>().loadCustomers(user.uid);
      context.read<ProductProvider>().fetchProducts(userId: user.uid);
      await invoiceProvider.initDraft(user.uid);
      _invoiceNumberController.text = invoiceProvider.draftInvoiceNumber;
      _taxRateController.text = '0';
      _discountController.text = '0';
      _notesController.text = '';
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
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

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primaryAccent,
              onPrimary: Color(0xFF060D0A),
              surface: _cardBg,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: _cardBg),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  void _showCustomerPicker() {
    final customerProvider = context.read<CustomerProvider>();
    final authProvider = context.read<AuthProvider>();
    final customers = customerProvider.allCustomers;
    String filterQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = filterQuery.trim().isEmpty
                ? customers
                : customers.where((c) {
                    final q = filterQuery.trim().toLowerCase();
                    return c.name.toLowerCase().contains(q) ||
                        c.email.toLowerCase().contains(q) ||
                        c.phone.toLowerCase().contains(q);
                  }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E382B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Customer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(bottomContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddCustomerScreen(),
                            ),
                          ).then((_) {
                            final user = authProvider.firebaseUser;
                            if (user != null) {
                              customerProvider.loadCustomers(user.uid);
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: _primaryAccent,
                        ),
                        label: const Text(
                          'New',
                          style: TextStyle(
                            color: _primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search field
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search customer name or email...',
                      hintStyle: const TextStyle(
                        color: _textSubtle,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _textMuted,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: _inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _primaryAccent),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        filterQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_search_rounded,
                                  color: _textSubtle,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  customers.isEmpty
                                      ? 'No customers added yet'
                                      : 'No matching customers found',
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const Divider(color: _cardBorder, height: 1),
                            itemBuilder: (context, index) {
                              final customer = filtered[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF0E2419),
                                  foregroundColor: _primaryAccentLight,
                                  child: Text(
                                    customer.name.isNotEmpty
                                        ? customer.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  customer.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  customer.email.isNotEmpty
                                      ? customer.email
                                      : customer.phone,
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: _textSubtle,
                                ),
                                onTap: () {
                                  context
                                      .read<InvoiceProvider>()
                                      .setDraftCustomer(customer);
                                  Navigator.pop(bottomContext);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddItemModal() {
    final productProvider = context.read<ProductProvider>();
    final products = productProvider.products;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DefaultTabController(
          length: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E382B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Add Line Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  indicatorColor: _primaryAccent,
                  labelColor: _primaryAccent,
                  unselectedLabelColor: _textMuted,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'From Catalog'),
                    Tab(text: 'Custom Item'),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Pick from Catalog
                      products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    color: _textSubtle,
                                    size: 44,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'No products in catalog',
                                    style: TextStyle(color: _textMuted),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Use Custom Item tab to add directly',
                                    style: TextStyle(
                                      color: _textSubtle,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: products.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(color: _cardBorder, height: 1),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ListTile(
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '₹ ${product.unitPrice.toStringAsFixed(2)} / ${product.unitType}',
                                    style: const TextStyle(
                                      color: _textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.add_circle_outline,
                                    color: _primaryAccent,
                                  ),
                                  onTap: () {
                                    _promptQuantityForCatalogProduct(
                                      product,
                                      sheetContext,
                                    );
                                  },
                                );
                              },
                            ),

                      // Tab 2: Custom Item Form
                      _CustomItemForm(
                        onSubmit: (item) {
                          context.read<InvoiceProvider>().addDraftItem(item);
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _promptQuantityForCatalogProduct(
    ProductModel product,
    BuildContext parentSheetContext,
  ) {
    double quantity = 1.0;
    double unitPrice = product.unitPrice;
    final qtyController = TextEditingController(text: '1');
    final rateController = TextEditingController(
      text: product.unitPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: _cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _cardBorder),
              ),
              title: Text(
                'Add ${product.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Quantity (${product.unitType})',
                            labelStyle: const TextStyle(color: _textMuted),
                            filled: true,
                            fillColor: _inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _inputBorder),
                            ),
                          ),
                          onChanged: (val) {
                            quantity = double.tryParse(val) ?? 1.0;
                            setDlgState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: rateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Unit Price (₹)',
                            labelStyle: const TextStyle(color: _textMuted),
                            filled: true,
                            fillColor: _inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _inputBorder),
                            ),
                          ),
                          onChanged: (val) {
                            unitPrice =
                                double.tryParse(val) ?? product.unitPrice;
                            setDlgState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E2419),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF18422E)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(color: _textMuted, fontSize: 14),
                        ),
                        Text(
                          '₹ ${(quantity * unitPrice).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: _primaryAccentLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: _textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    foregroundColor: const Color(0xFF060D0A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final item = InvoiceItemModel.create(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      productId: product.id,
                      productName: product.name,
                      quantity: quantity <= 0 ? 1.0 : quantity,
                      unitPrice: unitPrice < 0 ? 0.0 : unitPrice,
                      unitType: product.unitType,
                    );
                    context.read<InvoiceProvider>().addDraftItem(item);
                    Navigator.pop(dlgContext);
                    Navigator.pop(parentSheetContext);
                  },
                  child: const Text(
                    'Add to Invoice',
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

  Future<void> _submitInvoice({required InvoiceStatus status}) async {
    final invoiceProvider = context.read<InvoiceProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.firebaseUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create invoices.')),
      );
      return;
    }

    if (invoiceProvider.draftCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer.')),
      );
      return;
    }

    if (invoiceProvider.draftItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item.')),
      );
      return;
    }

    // Update custom invoice number & notes
    invoiceProvider.setDraftInvoiceNumber(_invoiceNumberController.text.trim());
    invoiceProvider.setDraftNotes(_notesController.text.trim());

    final savedInvoice = await invoiceProvider.createInvoiceFromDraft(
      userId: user.uid,
      status: status,
    );

    if (savedInvoice != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0E2419),
          content: Text(
            'Invoice ${savedInvoice.invoiceNumber} created successfully!',
            style: const TextStyle(color: Color(0xFFA7F3D0)),
          ),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2D141E),
          content: Text(
            invoiceProvider.errorMessage ?? 'Failed to create invoice.',
            style: const TextStyle(color: Color(0xFFFECDD3)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: _bgDark,
        body: Center(child: CircularProgressIndicator(color: _primaryAccent)),
      );
    }

    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _bgDark,
          appBar: AppBar(
            backgroundColor: _cardBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'New Invoice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final user = context.read<AuthProvider>().firebaseUser;
                  if (user != null) {
                    provider.initDraft(user.uid);
                  }
                },
                child: const Text('Reset', style: TextStyle(color: _textMuted)),
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
                // 1. Invoice Number & Dates Section
                _buildCardWrapper(
                  title: 'Invoice Details',
                  icon: Icons.tag_rounded,
                  child: Column(
                    children: [
                      TextField(
                        controller: _invoiceNumberController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        decoration: _inputDecoration(
                          label: 'Invoice Number',
                          prefixIcon: Icons.receipt_long_rounded,
                        ),
                        onChanged: (val) => provider.setDraftInvoiceNumber(val),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(
                                context: context,
                                initialDate: provider.draftIssueDate,
                                onPicked: (d) => provider.setDraftIssueDate(d),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _inputFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _inputBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Issue Date',
                                      style: TextStyle(
                                        color: _textSubtle,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(provider.draftIssueDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(
                                context: context,
                                initialDate: provider.draftDueDate,
                                onPicked: (d) => provider.setDraftDueDate(d),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _inputFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _inputBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Due Date',
                                      style: TextStyle(
                                        color: _textSubtle,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(provider.draftDueDate),
                                      style: const TextStyle(
                                        color: _primaryAccentLight,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Customer Section
                _buildCardWrapper(
                  title: 'Bill To Customer',
                  icon: Icons.person_outline_rounded,
                  trailing: provider.draftCustomer != null
                      ? TextButton(
                          onPressed: _showCustomerPicker,
                          child: const Text(
                            'Change',
                            style: TextStyle(color: _primaryAccent),
                          ),
                        )
                      : null,
                  child: provider.draftCustomer == null
                      ? OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: Color(0xFF1B4332),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showCustomerPicker,
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Select Customer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E2419),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF18422E)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF143827),
                                foregroundColor: _primaryAccentLight,
                                child: Text(
                                  provider.draftCustomer!.name.isNotEmpty
                                      ? provider.draftCustomer!.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.draftCustomer!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (provider
                                        .draftCustomer!
                                        .email
                                        .isNotEmpty)
                                      Text(
                                        provider.draftCustomer!.email,
                                        style: const TextStyle(
                                          color: _textMuted,
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (provider
                                        .draftCustomer!
                                        .phone
                                        .isNotEmpty)
                                      Text(
                                        provider.draftCustomer!.phone,
                                        style: const TextStyle(
                                          color: _textSubtle,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: _textSubtle,
                                  size: 18,
                                ),
                                onPressed: () => provider.clearDraftCustomer(),
                              ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 18),

                // 3. Line Items Section
                _buildCardWrapper(
                  title: 'Line Items',
                  icon: Icons.format_list_bulleted_rounded,
                  trailing: TextButton.icon(
                    onPressed: _showAddItemModal,
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: _primaryAccent,
                    ),
                    label: const Text(
                      'Add Item',
                      style: TextStyle(
                        color: _primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  child: provider.draftItems.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.playlist_add_rounded,
                                color: _textSubtle,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No items added yet',
                                style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _showAddItemModal,
                                child: const Text(
                                  'Add Line Item',
                                  style: TextStyle(color: _primaryAccent),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.draftItems.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = provider.draftItems[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _inputFill,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _inputBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
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
                                      color: _primaryAccentLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: _danger,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        provider.removeDraftItem(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 18),

                // 4. Financial Calculations & Summary Card
                _buildCardWrapper(
                  title: 'Billing & Calculations',
                  icon: Icons.calculate_outlined,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _taxRateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                label: 'Tax Rate (%)',
                                prefixIcon: Icons.percent_rounded,
                              ),
                              onChanged: (val) {
                                final rate = double.tryParse(val) ?? 0.0;
                                provider.setDraftTaxRate(rate);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _discountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                label: 'Discount (₹)',
                                prefixIcon: Icons.discount_outlined,
                              ),
                              onChanged: (val) {
                                final disc = double.tryParse(val) ?? 0.0;
                                provider.setDraftDiscountAmount(disc);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: _cardBorder, height: 1),
                      const SizedBox(height: 14),

                      // Subtotal
                      _buildSummaryRow(
                        'Subtotal',
                        '₹ ${provider.draftSubtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),

                      // Tax
                      if (provider.draftTaxRate > 0) ...[
                        _buildSummaryRow(
                          'Tax (${provider.draftTaxRate}%)',
                          '+ ₹ ${provider.draftTaxAmount.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Discount
                      if (provider.draftDiscountAmount > 0) ...[
                        _buildSummaryRow(
                          'Discount',
                          '- ₹ ${provider.draftDiscountAmount.toStringAsFixed(2)}',
                          valueColor: _danger,
                        ),
                        const SizedBox(height: 8),
                      ],

                      const SizedBox(height: 8),

                      // Grand Total highlighted
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E2419),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF18422E),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹ ${provider.draftTotalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: _primaryAccentLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 5. Notes & Terms
                _buildCardWrapper(
                  title: 'Notes & Payment Terms',
                  icon: Icons.notes_rounded,
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDecoration(
                      label: 'Payment terms or client notes (optional)',
                      prefixIcon: Icons.edit_note_rounded,
                    ),
                    onChanged: (val) => provider.setDraftNotes(val),
                  ),
                ),

                const SizedBox(height: 28),

                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textMuted,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: _cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: provider.isLoading
                            ? null
                            : () => _submitInvoice(status: InvoiceStatus.draft),
                        child: const Text(
                          'Save as Draft',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryAccent,
                          foregroundColor: const Color(0xFF060D0A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0x6600D07E),
                        ),
                        onPressed: provider.isLoading
                            ? null
                            : () =>
                                  _submitInvoice(status: InvoiceStatus.pending),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF060D0A),
                                ),
                              )
                            : const Text(
                                'Issue Invoice',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryAccentLight, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textSubtle, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: _textMuted, size: 18),
      filled: true,
      fillColor: _inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryAccent),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CustomItemForm extends StatefulWidget {
  final Function(InvoiceItemModel) onSubmit;

  const _CustomItemForm({required this.onSubmit});

  @override
  State<_CustomItemForm> createState() => _CustomItemFormState();
}

class _CustomItemFormState extends State<_CustomItemForm> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String _unitType = 'unit';

  static const Color _inputFill = Color(0xFF07120D);
  static const Color _inputBorder = Color(0xFF152A1F);
  static const Color _primaryAccent = Color(0xFF00D07E);
  static const Color _textMuted = Color(0xFF98ACA2);

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Item Name or Description *',
              labelStyle: const TextStyle(color: _textMuted),
              filled: true,
              fillColor: _inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _inputBorder),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Quantity *',
                    labelStyle: const TextStyle(color: _textMuted),
                    filled: true,
                    fillColor: _inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _inputBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Unit Price (₹) *',
                    labelStyle: const TextStyle(color: _textMuted),
                    filled: true,
                    fillColor: _inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _inputBorder),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _unitType,
            dropdownColor: const Color(0xFF0B1612),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Unit of Measure',
              labelStyle: const TextStyle(color: _textMuted),
              filled: true,
              fillColor: _inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _inputBorder),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'unit', child: Text('unit')),
              DropdownMenuItem(value: 'item', child: Text('item')),
              DropdownMenuItem(value: 'hr', child: Text('hr (hours)')),
              DropdownMenuItem(value: 'day', child: Text('day')),
              DropdownMenuItem(value: 'service', child: Text('service')),
              DropdownMenuItem(value: 'kg', child: Text('kg')),
              DropdownMenuItem(value: 'box', child: Text('box')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _unitType = val);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryAccent,
              foregroundColor: const Color(0xFF060D0A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final name = _nameController.text.trim();
              final qty = double.tryParse(_qtyController.text) ?? 1.0;
              final price = double.tryParse(_priceController.text) ?? 0.0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an item name.')),
                );
                return;
              }

              final item = InvoiceItemModel.create(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                productId: '',
                productName: name,
                quantity: qty <= 0 ? 1.0 : qty,
                unitPrice: price < 0 ? 0.0 : price,
                unitType: _unitType,
              );

              widget.onSubmit(item);
            },
            child: const Text(
              'Add Item to Invoice',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
