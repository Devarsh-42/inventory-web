// lib/viewmodels/client_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/client.dart';
import '../repositories/client_repository.dart';

class ClientViewModel extends ChangeNotifier {
  final ClientRepository _repository;
 
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  ClientViewModel(this._repository);

  // Getters
  List<Client> get clients => List.unmodifiable(_clients);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all clients
  Future<void> loadClients() async {
    _setLoading(true);
    _clearError();
    try {
      _clients = await _repository.getAllClients(); // Fixed: removed asterisks
      notifyListeners();
    } catch (e) {
      _setError('Failed to load clients: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add new client
  Future<void> addClient(Client client) async {
    _setLoading(true);
    _clearError();
    try {
      final newClient = await _repository.createClient(client);
      _clients.add(newClient);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add client: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing client
  Future<void> updateClient(Client client) async {
    _setLoading(true);
    _clearError();
    try {
      final updatedClient = await _repository.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update client: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete client
  Future<void> deleteClient(String clientId) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deleteClient(clientId);
      _clients.removeWhere((c) => c.id == clientId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete client: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get client by ID
  Client? getClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search clients
  List<Client> searchClients(String query) {
    if (query.isEmpty) return _clients;
   
    return _clients.where((client) {
      final normalizedQuery = query.toLowerCase();
      final normalizedName = client.name.toLowerCase();
      final normalizedPhone = client.phone?.toLowerCase() ?? '';
      
      return normalizedName.contains(normalizedQuery) ||
             normalizedPhone.contains(normalizedQuery);
    }).toList();
  }

  // Get client suggestions for autocomplete
  List<Client> getClientSuggestions(String query) {
    if (query.isEmpty) return [];
    
    return _clients.where((client) =>
      client.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Ensure clients are loaded
  Future<void> ensureClientsLoaded() async {
    if (_clients.isEmpty) {
      await loadClients();
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}