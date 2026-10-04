import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _itemType = 'Physical Good';
  String _unitType = 'piece';

  final List<String> _itemTypes = ['Physical Good', 'Hourly Service'];

  final List<String> _unitTypes = [
    'piece',
    'hour',
    'kg',
    'litre',
    'meter',
    'day',
    'month',
    'service',
  ];

  // Warm Cream Elegance Palette
  static const Color _bg = AppColors.bg;
  static const Color _cardBg = AppColors.cardBg;
  static const Color _cardBorder = AppColors.cardBorder;
  static const Color _primaryAccent = AppColors.primary;
  static const Color _inputFill = AppColors.inputFill;
  static const Color _inputBorder = AppColors.inputBorder;
  static const Color _textDark = AppColors.textDark;
  static const Color _textMuted = AppColors.textMuted;
  static const Color _textSubtle = AppColors.textSubtle;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final productProvider = context.read<ProductProvider>();

    final userId = authProvider.firebaseUser?.uid ?? authProvider.user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          message: 'You must be logged in to add a product.',
          isError: true,
        ),
      );
      return;
    }

    final price =
        double.tryParse(_priceController.text.trim().replaceAll(',', '')) ??
        0.0;

    final product = ProductModel(
      id: '',
      userId: userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      unitPrice: price,
      itemType: _itemType,
      unitType: _unitType,
      createdAt: DateTime.now(),
    );

    final success = await productProvider.addProduct(product);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(message: 'Product added successfully.', isError: false),
      );

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          message: productProvider.errorMessage ?? 'Failed to add product.',
          isError: true,
        ),
      );
    }
  }

  SnackBar _buildSnackBar({required String message, required bool isError}) {
    return SnackBar(
      backgroundColor: isError ? AppColors.dangerBg : AppColors.successBg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isError ? AppColors.dangerBorder : AppColors.successBorder,
        ),
      ),
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isError ? AppColors.danger : AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? AppColors.danger : AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: _inputFill,
      hintText: hintText,
      hintStyle: const TextStyle(color: _textSubtle, fontSize: 13),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: _primaryAccent,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      prefixIcon: Icon(prefixIcon, color: _primaryAccent, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _textDark,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBranding(),
                  const SizedBox(height: 24),
                  _buildCard(context, isLoading),
                  const SizedBox(height: 20),
                  _buildFooterBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBranding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primaryAccent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33113946),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: AppColors.cream,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'INVOXA',
              style: TextStyle(
                color: _textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'PRODUCT CATALOG',
              style: TextStyle(
                color: AppColors.camelDark,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12113946),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 16,
                          color: _primaryAccent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Back to Dashboard',
                          style: TextStyle(
                            color: _primaryAccent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sandLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.sandDark,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'New Product',
                    style: TextStyle(
                      color: _primaryAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
                children: [
                  TextSpan(
                    text: 'Add Product.\n',
                    style: TextStyle(color: _textDark),
                  ),
                  TextSpan(
                    text: 'To Your Catalog.',
                    style: TextStyle(color: _primaryAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add a physical product or hourly service to your business portfolio.',
              style: TextStyle(color: _textMuted, fontSize: 13),
            ),

            const SizedBox(height: 20),

            // In-Card Error Display from ProductProvider
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.errorMessage == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.dangerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.danger,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          productProvider.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Product Name Field
            _buildFieldLabel('Product / Service Name *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: _textDark, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'e.g. Website Design or Modern Desk Lamp',
                prefixIcon: Icons.drive_file_rename_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a product or service name.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description Field
            _buildFieldLabel('Description (Optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              textInputAction: TextInputAction.next,
              maxLines: 3,
              style: const TextStyle(color: _textDark, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'Brief description of the product or service...',
                prefixIcon: Icons.notes_rounded,
              ),
            ),

            const SizedBox(height: 16),

            // Unit Price Field
            _buildFieldLabel('Unit Price (₹) *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: _textDark, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'e.g. 1500.00',
                prefixIcon: Icons.currency_rupee_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a unit price.';
                }

                final sanitized = value.trim().replaceAll(',', '');
                final price = double.tryParse(sanitized);

                if (price == null) {
                  return 'Please enter a valid price.';
                }

                if (price < 0) {
                  return 'Price cannot be negative.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // Item Type Dropdown
            _buildFieldLabel('Item Type *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _itemType,
              dropdownColor: _cardBg,
              style: const TextStyle(color: _textDark, fontSize: 14),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _primaryAccent,
              ),
              decoration: _buildInputDecoration(
                hintText: 'Select item type',
                prefixIcon: Icons.category_outlined,
              ),
              items: _itemTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: const TextStyle(color: _textDark),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _itemType = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 16),

            // Unit of Measure Dropdown
            _buildFieldLabel('Unit of Measure *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _unitType,
              dropdownColor: _cardBg,
              style: const TextStyle(color: _textDark, fontSize: 14),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _primaryAccent,
              ),
              decoration: _buildInputDecoration(
                hintText: 'Select unit of measure',
                prefixIcon: Icons.straighten_rounded,
              ),
              items: _unitTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: const TextStyle(color: _textDark),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _unitType = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 26),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryAccent,
                  foregroundColor: AppColors.cream,
                  disabledBackgroundColor: const Color(0x80113946),
                  elevation: 3,
                  shadowColor: const Color(0x33113946),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.cream,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: AppColors.cream,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Save Product',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cream,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBadge() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 14, color: AppColors.camelDark),
        SizedBox(width: 6),
        Text(
          'Tenant Scoped • Cloud Firestore Protected',
          style: TextStyle(
            color: _textSubtle,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
