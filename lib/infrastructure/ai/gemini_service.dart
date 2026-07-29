import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_service.g.dart';

@riverpod
class GeminiService extends _$GeminiService {
  final List<String> _prioritizedModels = [
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  @override
  FutureOr<void> build() async {
    // Initialization is now handled lazily or via sendMessage to support retries
  }

  GenerativeModel _createModel(
    String modelName, {
    List<Tool>? tools,
    Content? systemInstruction,
  }) {
    final apiKey = dotenv.maybeGet('GEMINI_API_KEY');
    if (apiKey == null || apiKey == 'your-gemini-api-key') {
      throw Exception('GEMINI_API_KEY is missing');
    }

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      tools: tools,
      systemInstruction: systemInstruction,
    );
  }

  Future<String> sendMessage(String message) async {
    for (final modelName in _prioritizedModels) {
      try {
        final model = _createModel(modelName);
        // Start a fresh chat for now or manage session
        final response = await model.startChat().sendMessage(
          Content.text(message),
        );
        return response.text ?? "I'm sorry, I couldn't process that.";
      } on Exception catch (_) {
        continue;
      }
    }
    return 'All Gemini models failed to generate content or API key is missing.';
  }

  /// Generic method to generate content with tools, following the Kotlin pattern
  Future<GenerateContentResponse> generateContent({
    required List<Content> contents,
    List<Tool>? tools,
    Content? systemInstruction,
  }) async {
    Exception? lastException;

    for (final modelName in _prioritizedModels) {
      try {
        final model = _createModel(
          modelName,
          tools: tools,
          systemInstruction: systemInstruction,
        );
        return await model.generateContent(contents);
      } on Exception catch (e) {
        lastException = e;
      }
    }
    throw lastException ?? Exception('All Gemini models failed');
  }
}
