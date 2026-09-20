$env:SUPABASE_URL = "https://ckbilyyvfocrkeylepkt.supabase.co"
$env:SUPABASE_PUBLISHABLE_KEY = "sb_publishable__PMMJXsYcoCYcEM7BYu3zA_gcG3Zubq"

flutter run -d chrome `
  --dart-define=SUPABASE_URL="$env:SUPABASE_URL" `
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$env:SUPABASE_PUBLISHABLE_KEY"