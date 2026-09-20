class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');

  static const String anonKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static void validate() {
    if (url.isEmpty) {
      throw StateError('SUPABASE_URL is not configured.');
    }

    if (anonKey.isEmpty) {
      throw StateError('SUPABASE_PUBLISHABLE_KEY is not configured.');
    }
  }
}
