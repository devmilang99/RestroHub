import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_service.g.dart';

class SupabaseService {
  static Future<void> initialize() async {
    final url = dotenv.maybeGet('SUPABASE_URL');
    final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

    if (url == null ||
        anonKey == null ||
        url.contains('your-project-id') ||
        anonKey == 'your-anon-key') {
      debugPrint(
        'WARNING: Supabase configuration is missing or using placeholders in .env file. '
        'Please provide valid SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
      return;
    }

    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
    );
  }
}

@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
