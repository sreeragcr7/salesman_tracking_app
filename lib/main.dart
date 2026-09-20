import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
    url: 'https://ckbilyyvfocrkeylepkt.supabase.co',
    publishableKey: 'sb_publishable__PMMJXsYcoCYcEM7BYu3zA_gcG3Zubq',
  );

  runApp(const App());
}
