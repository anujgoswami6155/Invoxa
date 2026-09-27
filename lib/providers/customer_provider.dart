import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CustomerModel> get customers {
    if (_searchQuery.trim().isEmpty) {
      return _customers;
    }
    final query = _searchQuery.trim().toLowerCase();
    return _customers.where((customer) {
      final nameMatches = customer.name.toLowerCase().contains(query);
      final emailMatches = customer.email.toLowerCase().contains(query);
      final phoneMatches = customer.phone.toLowerCase().contains(query);
      final addressMatches = customer.address.toLowerCase().contains(query);
      return nameMatches || emailMatches || phoneMatches || addressMatches;
    }).toList();
  }

  List<CustomerModel> get allCustomers => _customers;

  int get totalCustomerCount => _customers.length;

  String get searchQuery => _searchQuery;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<bool> loadCustomers(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _customers = await _customerService.getCustomers(userId);
      return true;
    } catch (e, stack) {
      debugPrint('[CustomerProvider] Error loading customers: $e\n$stack');
      _errorMessage = 'Could not load customers. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    _setLoading(true);
    _clearError();

    try {
      final savedCustomer = await _customerService.createCustomer(customer);
      _customers.insert(0, savedCustomer);
      return true;
    } catch (e, stack) {
      debugPrint('[CustomerProvider] Error adding customer: $e\n$stack');
      _errorMessage = 'Could not add customer. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    _setLoading(true);
    _clearError();

    try {
      await _customerService.updateCustomer(customer);

      final index = _customers.indexWhere((item) => item.id == customer.id);

      if (index != -1) {
        _customers[index] = customer;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Could not update customer. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCustomer(String userId, String customerId) async {
    _setLoading(true);
    _clearError();

    try {
      await _customerService.deleteCustomer(userId, customerId);

      _customers.removeWhere((customer) => customer.id == customerId);

      return true;
    } catch (e) {
      _errorMessage = 'Could not delete customer. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
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
