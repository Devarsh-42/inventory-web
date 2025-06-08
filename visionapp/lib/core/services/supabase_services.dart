import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  // Supabase configuration
  static const String supabaseUrl = 'https://fnpphxriqanxvwfxzdmv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucHBoeHJpcWFueHZ3Znh6ZG12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyODIwNTYsImV4cCI6MjA2MTg1ODA1Nn0.Gg5jJKeVJaKmCWl_4BtrpFqFa6oB9CUwlIwSMZkjzn4';

  // Private constructor
  SupabaseService._() {
    _client = Supabase.instance.client;
  }

  // Singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  // Get Supabase client
  SupabaseClient get client => _client;

  // Initialize Supabase with session persistence
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 2,
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get auth state changes stream
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // You can add any additional cleanup here
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      if (currentUser != null) {
        final userData = await _client
            .from('users')
            .select('role')
            .eq('id', currentUser!.id)
            .single();
        return userData['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Add these methods to the SupabaseService class

  Future<void> markCompletion(String productionCompletionId) async {
    try {
      await client.rpc('create_dispatch_entry', params: {
        'completion_id': productionCompletionId
      });
    } catch (e) {
      throw Exception('Failed to mark completion: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDispatchItems(String dispatchId) async {
    try {
      final response = await client
          .from('dispatch_items')
          .select()
          .eq('dispatch_id', dispatchId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch dispatch items: $e');
    }
  }

  Future<void> shipDispatch(String dispatchId) async {
    try {
      await client.rpc('ship_dispatch', params: {
        'dispatch_id': dispatchId
      });
    } catch (e) {
      throw Exception('Failed to ship dispatch: $e');
    }
  }
}