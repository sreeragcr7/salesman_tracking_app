import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/app/app.dart';
import 'package:salesman_tracking_app/config/supabase_config.dart';
import 'package:salesman_tracking_app/init_dependencies.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase configuration is missing. '
      'Run the app with SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY using --dart-define.',
    );
  }

  await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.publishableKey);

  await initDependencies();

  runApp(const App());
}
