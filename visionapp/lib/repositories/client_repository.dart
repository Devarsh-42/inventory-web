import '../core/services/supabase_services.dart';
import '../models/client.dart';

class ClientRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'clients';

  ClientRepository() : _supabaseService = SupabaseService.instance;

  Future<List<Client>> getAllClients() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .order('name'); // Order by name for better usability

      return (response as List)
          .map((json) => Client.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch clients: $e');
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .insert({
            'name': client.name,
            'phone': client.phone,
            'is_active': client.is_active,
          })
          .select()
          .single();

      return Client.fromJson(response);
    } catch (e) {
      if (e.toString().contains('clients_name_key')) {
        throw Exception('A client with this name already exists');
      }
      throw Exception('Failed to create client: $e');
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .update({
            'name': client.name,
            'phone': client.phone,
            'is_active': client.is_active,
          })
          .eq('id', client.id)
          .select()
          .single();

      return Client.fromJson(response);
    } catch (e) {
      if (e.toString().contains('clients_name_key')) {
        throw Exception('A client with this name already exists');
      }
      throw Exception('Failed to update client: $e');
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  Future<Client?> getClientById(String id) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Client.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch client: $e');
    }
  }

  Future<List<Client>> searchClientsByName(String query) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .ilike('name', '%$query%')
          .order('name')
          .limit(10);

      return (response as List)
          .map((json) => Client.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search clients: $e');
    }
  }
}
