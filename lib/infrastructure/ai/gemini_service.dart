import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:restro_hub/features/ai/data/gemini_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_service.g.dart';

@riverpod
class GeminiService extends _$GeminiService {
  final List<String> _prioritizedModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  late final Dio _dio;
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  FutureOr<void> build() {
    _dio = Dio();
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

  Future<GeminiModelList> listModels() async {
    final apiKey = dotenv.maybeGet('GEMINI_API_KEY');
    final response = await _dio.get<Map<String, dynamic>>(
      _baseUrl,
      queryParameters: {'key': apiKey},
    );
    return GeminiModelList.fromJson(response.data!);
  }
}
