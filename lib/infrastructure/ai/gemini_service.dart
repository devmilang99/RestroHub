import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:restro_hub/features/ai/data/gemini_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_service.g.dart';

@Riverpod(keepAlive: true)
class GeminiService extends _$GeminiService {
  final List<String> _prioritizedModels = [
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  bool _isBackupNext = false;

  late final Dio _dio;
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  FutureOr<void> build() {
    _dio = Dio();
  }

  String _getApiKey({bool forcePrimary = false, bool forceBackup = false}) {
    final primaryKey = dotenv.maybeGet('GEMINI_API_KEY');
    final backupKey = dotenv.maybeGet('GEMINI_API_KEY_BACKUP');

    if (forcePrimary) return primaryKey ?? backupKey ?? '';
    if (forceBackup) return backupKey ?? primaryKey ?? '';

    // Standard rotation
    final useBackup = _isBackupNext;
    _isBackupNext = !_isBackupNext; // Toggle for next query

    final selectedKey = useBackup ? backupKey : primaryKey;
    final keyName = useBackup ? 'BACKUP_KEY' : 'PRIMARY_KEY';
    debugPrint(
      'GeminiService: Using $keyName for current request. Next request will use ${!useBackup ? 'BACKUP_KEY' : 'PRIMARY_KEY'}.',
    );

    // Fallback if the selected key is missing
    return selectedKey ?? (useBackup ? primaryKey : backupKey) ?? '';
  }

  GenerativeModel _createModel(
    String modelName,
    String apiKey, {
    List<Tool>? tools,
    Content? systemInstruction,
  }) {
    if (apiKey.isEmpty || apiKey == 'your-gemini-api-key') {
      throw Exception('Gemini API Key is missing or invalid');
    }

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      tools: tools,
      systemInstruction: systemInstruction,
    );
  }

  /// Generic method to generate content with tools, following the Kotlin pattern
  Future<GenerateContentResponse> generateContent({
    required List<Content> contents,
    List<Tool>? tools,
    Content? systemInstruction,
  }) async {
    final primaryKey = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    final backupKey = dotenv.maybeGet('GEMINI_API_KEY_BACKUP') ?? '';

    // Decide which key to try first based on rotation state
    final useBackupFirst = _isBackupNext;
    final firstKey = useBackupFirst ? backupKey : primaryKey;
    final secondKey = useBackupFirst ? primaryKey : backupKey;

    final firstKeyName = useBackupFirst ? 'BACKUP_KEY' : 'PRIMARY_KEY';
    final secondKeyName = useBackupFirst ? 'PRIMARY_KEY' : 'BACKUP_KEY';

    debugPrint(
      'GeminiService: Starting query with $firstKeyName. Next query will start with $secondKeyName.',
    );

    // Toggle for the next query
    _isBackupNext = !_isBackupNext;

    try {
      return await _tryGenerateWithKey(
        firstKey,
        contents: contents,
        tools: tools,
        systemInstruction: systemInstruction,
      );
    } catch (e) {
      debugPrint(
        'GeminiService: ERROR with $firstKeyName: $e. FALLING BACK to $secondKeyName...',
      );
      try {
        return await _tryGenerateWithKey(
          secondKey,
          contents: contents,
          tools: tools,
          systemInstruction: systemInstruction,
        );
      } catch (e2) {
        debugPrint('GeminiService: CRITICAL - Both API keys failed.');
        throw Exception('All Gemini API keys failed. Last error: $e2');
      }
    }
  }

  Future<GenerateContentResponse> _tryGenerateWithKey(
    String apiKey, {
    required List<Content> contents,
    List<Tool>? tools,
    Content? systemInstruction,
  }) async {
    Exception? lastException;

    for (final modelName in _prioritizedModels) {
      try {
        final model = _createModel(
          modelName,
          apiKey,
          tools: tools,
          systemInstruction: systemInstruction,
        );
        return await model.generateContent(contents);
      } on Exception catch (e) {
        lastException = e;
        debugPrint('Model $modelName failed: $e');
      }
    }
    throw lastException ?? Exception('All Gemini models failed with this key');
  }

  Future<GeminiModelList> listModels() async {
    final apiKey = _getApiKey();
    final response = await _dio.get<Map<String, dynamic>>(
      _baseUrl,
      queryParameters: {'key': apiKey},
    );
    return GeminiModelList.fromJson(response.data!);
  }
}
