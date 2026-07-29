import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase Connectivity Sanity Check', () {
    setUpAll(() async {
      // Load .env file for testing
      await dotenv.load();
      SharedPreferences.setMockInitialValues({});
    });

    test('Environment variables are loaded correctly', () {
      final url = dotenv.maybeGet('SUPABASE_URL');
      final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

      expect(url, isNotNull, reason: 'SUPABASE_URL should be defined in .env');
      expect(
        anonKey,
        isNotNull,
        reason: 'SUPABASE_ANON_KEY should be defined in .env',
      );
      expect(
        url,
        isNot(contains('your-project-id')),
        reason: 'SUPABASE_URL should not be a placeholder',
      );
      expect(
        anonKey,
        isNot(equals('your-anon-key')),
        reason: 'SUPABASE_ANON_KEY should not be a placeholder',
      );
    });

    test('Supabase Client can be initialized', () async {
      final url = dotenv.get('SUPABASE_URL');
      final anonKey = dotenv.get('SUPABASE_ANON_KEY');

      try {
        await Supabase.initialize(
          url: url,
          publishableKey: anonKey,
        );

        final client = Supabase.instance.client;
        expect(client, isNotNull);
      } catch (e) {
        fail('Supabase initialization failed: $e');
      }
    });
  });
}
