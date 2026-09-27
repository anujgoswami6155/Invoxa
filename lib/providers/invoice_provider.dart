import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../services/invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();

  // Invoices list state
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  InvoiceStatus? _selectedStatusFilter; // null means 'All'
  String _searchQuery = '';

  // ---------------------------------------------------------------------------
  // Getters for Invoices List & Filtering
  // ---------------------------------------------------------------------------
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  InvoiceStatus? get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;
  List<InvoiceModel> get allInvoices => List.unmodifiable(_invoices);

  List<InvoiceModel> get invoices {
    var list = _invoices;

    if (_selectedStatusFilter != null) {
      list = list.where((inv) {
        return inv.effectiveStatus == _selectedStatusFilter ||
            inv.status == _selectedStatusFilter;
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((inv) {
        final matchesNumber = inv.invoiceNumber.toLowerCase().contains(query);
        final matchesCustomer = inv.customerName.toLowerCase().contains(query);
        final matchesEmail = inv.customerEmail.toLowerCase().contains(query);
        return matchesNumber || matchesCustomer || matchesEmail;
      }).toList();
    }

    return list;
  }

  // ---------------------------------------------------------------------------
  // Aggregated KPI Metrics (for Dashboard & Overview)
  // ---------------------------------------------------------------------------
  int get totalInvoicesCount => _invoices.length;

  double get totalRevenue => _invoices.fold(
        0.0,
        (sum, inv) => sum + inv.paidAmount,
      );

  double get totalOutstanding => _invoices.fold(
        0.0,
        (sum, inv) =>
            inv.status != InvoiceStatus.cancelled ? sum + inv.balanceDue : sum,
      );

  int get pendingInvoicesCount => _invoices
      .where(
        (inv) =>
            inv.effectiveStatus == InvoiceStatus.pending ||
            inv.effectiveStatus == InvoiceStatus.partiallyPaid ||
            inv.effectiveStatus == InvoiceStatus.overdue,
      )
      .length;

  int get paidInvoicesCount => _invoices
      .where((inv) => inv.effectiveStatus == InvoiceStatus.paid)
      .length;

  List<InvoiceModel> recentInvoices([int limit = 5]) {
    if (_invoices.isEmpty) return [];
    return _invoices.take(limit).toList();
  }

  // ---------------------------------------------------------------------------
  // Interactive Draft Builder State (for CreateInvoiceScreen)
  // ---------------------------------------------------------------------------
  String _draftInvoiceNumber = '';
  CustomerModel? _draftCustomer;
  DateTime _draftIssueDate = DateTime.now();
  DateTime _draftDueDate = DateTime.now().add(const Duration(days: 14));
  List<InvoiceItemModel> _draftItems = [];
  double _draftTaxRate = 0.0;
  double _draftDiscountAmount = 0.0;
  String _draftNotes = '';

  String get draftInvoiceNumber => _draftInvoiceNumber;
  CustomerModel? get draftCustomer => _draftCustomer;
  DateTime get draftIssueDate => _draftIssueDate;
  DateTime get draftDueDate => _draftDueDate;
  List<InvoiceItemModel> get draftItems => List.unmodifiable(_draftItems);
  double get draftTaxRate => _draftTaxRate;
  double get draftDiscountAmount => _draftDiscountAmount;
  String get draftNotes => _draftNotes;

  // Real-time calculation getters
  double get draftSubtotal => _draftItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

  double get draftTaxAmount => draftSubtotal * (_draftTaxRate / 100);

  double get draftTotalAmount =>
      (draftSubtotal + draftTaxAmount - _draftDiscountAmount)
          .clamp(0.0, double.infinity);

  bool get isDraftValid =>
      _draftCustomer != null &&
      _draftItems.isNotEmpty &&
      draftTotalAmount >= 0;

  // ---------------------------------------------------------------------------
  // Draft Builder Mutations
  // ---------------------------------------------------------------------------
  Future<void> initDraft(String userId) async {
    _draftCustomer = null;
    _draftIssueDate = DateTime.now();
    _draftDueDate = DateTime.now().add(const Duration(days: 14));
    _draftItems = [];
    _draftTaxRate = 0.0;
    _draftDiscountAmount = 0.0;
    _draftNotes = '';
    _draftInvoiceNumber = await _invoiceService.getNextInvoiceNumber(userId);
    notifyListeners();
  }

  void setDraftInvoiceNumber(String number) {
    _draftInvoiceNumber = number;
    notifyListeners();
  }

  void setDraftCustomer(CustomerModel customer) {
    _draftCustomer = customer;
    notifyListeners();
  }

  void clearDraftCustomer() {
    _draftCustomer = null;
    notifyListeners();
  }

  void setDraftIssueDate(DateTime date) {
    _draftIssueDate = date;
    if (_draftDueDate.isBefore(_draftIssueDate)) {
      _draftDueDate = _draftIssueDate.add(const Duration(days: 14));
    }
    notifyListeners();
  }

  void setDraftDueDate(DateTime date) {
    _draftDueDate = date;
    notifyListeners();
  }

  void setDraftTaxRate(double rate) {
    _draftTaxRate = rate < 0 ? 0.0 : rate;
    notifyListeners();
  }

  void setDraftDiscountAmount(double discount) {
    _draftDiscountAmount = discount < 0 ? 0.0 : discount;
    notifyListeners();
  }

  void setDraftNotes(String notes) {
    _draftNotes = notes;
    notifyListeners();
  }

  void addDraftItem(InvoiceItemModel item) {
    _draftItems.add(item);
    notifyListeners();
  }

  void updateDraftItem(int index, InvoiceItemModel item) {
    if (index >= 0 && index < _draftItems.length) {
      _draftItems[index] = item;
      notifyListeners();
    }
  }

  void removeDraftItem(int index) {
    if (index >= 0 && index < _draftItems.length) {
      _draftItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearDraft() {
    _draftCustomer = null;
    _draftInvoiceNumber = '';
    _draftIssueDate = DateTime.now();
    _draftDueDate = DateTime.now().add(const Duration(days: 14));
    _draftItems = [];
    _draftTaxRate = 0.0;
    _draftDiscountAmount = 0.0;
    _draftNotes = '';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Filters & Search
  // ---------------------------------------------------------------------------
  void setStatusFilter(InvoiceStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Cloud Operations
  // ---------------------------------------------------------------------------
  Future<bool> loadInvoices(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _invoices = await _invoiceService.getInvoices(userId);
      return true;
    } catch (e, stack) {
      debugPrint('[InvoiceProvider] Error loading invoices: $e\n$stack');
      _errorMessage = 'Could not load invoices. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<InvoiceModel?> createInvoiceFromDraft({
    required String userId,
    InvoiceStatus status = InvoiceStatus.pending,
  }) async {
    if (_draftCustomer == null) {
      _errorMessage = 'Please select a customer for this invoice.';
      notifyListeners();
      return null;
    }

    if (_draftItems.isEmpty) {
      _errorMessage = 'Please add at least one line item.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final invoice = InvoiceModel(
        id: '',
        userId: userId,
        invoiceNumber: _draftInvoiceNumber.trim(),
        customerId: _draftCustomer!.id,
        customerName: _draftCustomer!.name,
        customerEmail: _draftCustomer!.email,
        customerPhone: _draftCustomer!.phone,
        customerAddress: _draftCustomer!.address,
        issueDate: _draftIssueDate,
        dueDate: _draftDueDate,
        items: List.from(_draftItems),
        subtotal: draftSubtotal,
        taxRate: _draftTaxRate,
        taxAmount: draftTaxAmount,
        discountAmount: _draftDiscountAmount,
        totalAmount: draftTotalAmount,
        paidAmount: 0.0,
        status: status,
        notes: _draftNotes.trim(),
        createdAt: DateTime.now(),
      );

      final savedInvoice = await _invoiceService.createInvoice(invoice);
      _invoices.insert(0, savedInvoice);
      clearDraft();
      return savedInvoice;
    } catch (e, stack) {
      debugPrint('[InvoiceProvider] Error creating invoice: $e\n$stack');
      _errorMessage = 'Failed to create invoice: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateInvoice(InvoiceModel invoice) async {
    _setLoading(true);
    _clearError();

    try {
      await _invoiceService.updateInvoice(invoice);

      final index = _invoices.indexWhere((item) => item.id == invoice.id);
      if (index != -1) {
        _invoices[index] = invoice;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Could not update invoice. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateInvoiceStatus({
    required String invoiceId,
    required String userId,
    required InvoiceStatus status,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _invoiceService.updateInvoiceStatus(
        invoiceId: invoiceId,
        userId: userId,
        status: status,
      );

      final index = _invoices.indexWhere((item) => item.id == invoiceId);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }
      return true;
    } catch (e) {
      _errorMessage = 'Could not update invoice status.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> recordPayment({
    required String invoiceId,
    required String userId,
    required double paymentAmount,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updated = await _invoiceService.recordPayment(
        invoiceId: invoiceId,
        userId: userId,
        paymentAmount: paymentAmount,
      );

      final index = _invoices.indexWhere((item) => item.id == invoiceId);
      if (index != -1) {
        _invoices[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Could not record payment. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteInvoice({
    required String invoiceId,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _invoiceService.deleteInvoice(
        invoiceId: invoiceId,
        userId: userId,
      );

      _invoices.removeWhere((item) => item.id == invoiceId);
      return true;
    } catch (e) {
      _errorMessage = 'Could not delete invoice. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  InvoiceModel? getInvoiceById(String invoiceId) {
    for (final inv in _invoices) {
      if (inv.id == invoiceId) {
        return inv;
      }
    }
    return null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
