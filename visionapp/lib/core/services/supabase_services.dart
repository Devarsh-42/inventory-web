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

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Set to false in production
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
    await _client.auth.signOut();
  }
}