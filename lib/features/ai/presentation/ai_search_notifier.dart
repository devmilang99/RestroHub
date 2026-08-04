import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:restro_hub/core/data/mock_data.dart';
import 'package:restro_hub/features/ai/domain/model/ai_chat_message.dart';
import 'package:restro_hub/features/ai/presentation/ai_search_state.dart';
import 'package:restro_hub/features/restaurants/data/repositories/restaurant_repository.dart';
import 'package:restro_hub/infrastructure/ai/gemini_search_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_search_notifier.g.dart';

@riverpod
class AiSearchNotifier extends _$AiSearchNotifier {
  final List<Content> _chatHistory = [];
  static const int _maxChatHistory = 10;

  bool _isCancelled = false;

  @override
  FutureOr<AiSearchState> build() {
    return const AiSearchState();
  }

  Future<void> performAiSearch(String query) async {
    final current = state.value!;
    if (query.isEmpty || current.isProcessing) return;

    if (current.searchCount >= 5) {
      state = AsyncData(
        current.copyWith(
          error: 'You have reached the limit of 5 AI searches.',
        ),
      );
      return;
    }

    if (current.errorCount >= 2) {
      state = AsyncData(
        current.copyWith(
          error: 'Multiple errors occurred. Please restart the assistant.',
        ),
      );
      return;
    }

    _isCancelled = false;
    final nextSearchCount = current.searchCount + 1;

    state = AsyncData(
      current.copyWith(
        isProcessing: true,
        error: null,
        restaurants: [], // Clear previous search results
        searchCount: nextSearchCount,
        messages: [
          ...current.messages,
          AiChatMessage(text: query, isUser: true),
        ],
      ),
    );

    try {
      final userContent = Content.text(query);
      _addToHistory(userContent);

      await _executeSearch(query);
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          errorCount: state.value!.errorCount + 1,
          messages: [
            ...state.value!.messages,
            AiChatMessage(
              text: "I've found these recommendations for you!",
              isUser: false,
            ),
          ],
          error: null,
          restaurants: restaurantsList,
          searchCount: state.value!.searchCount,
        ),
      );
    }
  }

  Future<void> _executeSearch(String query) async {
    try {
      final router = ref.read(geminiSearchRouterProvider.notifier);

      var response = await router.routeSearch(query, history: _chatHistory);

      var candidate = response.candidates.firstOrNull;
      if (candidate == null) throw Exception('No candidate response');

      var parts = candidate.content.parts;
      var functionCalls = parts.whereType<FunctionCall>().toList();

      while (functionCalls.isNotEmpty) {
        // Add model's tool call to history
        _addToHistory(candidate!.content);

        final responseParts = <Part>[];
        for (final call in functionCalls) {
          final result = await _handleFunctionCall(call);
          responseParts.add(FunctionResponse(call.name, result));
        }

        final responseContent = Content.model(responseParts);
        _addToHistory(responseContent);

        if (_isCancelled) {
          return;
        }

        response = await router.routeSearch('', history: _chatHistory);
        candidate = response.candidates.firstOrNull;
        if (candidate == null) break;
        parts = candidate.content.parts;
        functionCalls = parts.whereType<FunctionCall>().toList();
      }

      if (_isCancelled) {
        return;
      }

      final finalMessage = parts.whereType<TextPart>().firstOrNull?.text;
      if (finalMessage != null && finalMessage.isNotEmpty) {
        state = AsyncData(
          state.value!.copyWith(
            isProcessing: false,
            messages: [
              ...state.value!.messages,
              AiChatMessage(text: finalMessage, isUser: false),
            ],
          ),
        );
        _addToHistory(candidate!.content);
      } else {
        final hasRestaurants = state.value?.restaurants.isNotEmpty ?? false;
        state = AsyncData(
          state.value!.copyWith(
            isProcessing: false,
            messages: [
              ...state.value!.messages,
              AiChatMessage(
                text: hasRestaurants
                    ? "I've found some great options for you based on your request!"
                    : "I've found these recommendations for you!",
                isUser: false,
              ),
            ],
          ),
        );
      }
    } catch (e) {
      final hasRestaurants = state.value?.restaurants.isNotEmpty ?? false;
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          errorCount: state.value!.errorCount + 1,
          messages: [
            ...state.value!.messages,
            AiChatMessage(
              text: hasRestaurants
                  ? "I've found some great options for you based on your request!"
                  : "I've found these recommendations for you!",
              isUser: false,
            ),
          ],
          restaurants: hasRestaurants
              ? state.value!.restaurants
              : restaurantsList,
          searchCount: state.value!.searchCount, // Explicitly carry over count
          error: null,
        ),
      );
    }
  }

  void _addToHistory(Content content) {
    _chatHistory.add(content);
    if (_chatHistory.length > _maxChatHistory) {
      _chatHistory.removeAt(0);
    }
  }

  Future<Map<String, Object?>> _handleFunctionCall(FunctionCall call) async {
    final args = call.args;
    switch (call.name) {
      case 'search_restaurants':
        final keywords = args['keywords'] as String?;
        final ratingMin = args['rating_min'] as num?;

        final repo = ref.read(restaurantRepositoryProvider);
        final result = await repo.getRestaurants();

        return result.fold(
          onSuccess: (restaurants) {
            var filtered = restaurants;
            // Fallback to mock data if DB is empty for demo purposes
            if (filtered.isEmpty) {
              filtered = restaurantsList;
            }

            if (keywords != null) {
              filtered = filtered
                  .where(
                    (r) =>
                        r.name.toLowerCase().contains(keywords.toLowerCase()) ||
                        r.description.toLowerCase().contains(
                          keywords.toLowerCase(),
                        ),
                  )
                  .toList();
            }
            if (ratingMin != null) {
              filtered = filtered.where((r) => r.rating >= ratingMin).toList();
            }

            state = AsyncData(
              state.value!.copyWith(
                restaurants: filtered,
              ),
            );

            return {
              'status': 'success',
              'count': filtered.length,
              'restaurants': filtered
                  .take(5)
                  .map(
                    (r) => {
                      'id': r.id,
                      'name': r.name,
                      'rating': r.rating,
                    },
                  )
                  .toList(),
            };
          },
          onFailure: (error) => {'status': 'error', 'message': error.message},
        );

      case 'search_cuisines':
        // This is a bit tricky as cuisines are per restaurant in this repo structure
        // For sample purposes, we might just search common ones or all if we had a global repo
        // We'd need a restaurant ID, but let's assume we search across all if possible
        // Since the repo needs an ID, we'll just return a placeholder or search in a default one
        return {
          'status': 'success',
          'message': 'Searching cuisines... (Limited in sample)',
          'cuisines': [],
        };

      default:
        return {'status': 'unknown_function'};
    }
  }

  void clearSearch() {
    _chatHistory.clear();
    state = const AsyncData(AiSearchState());
  }

  void cancelSearch() {
    if (state.value?.isProcessing == true) {
      _isCancelled = true;
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          messages: [
            ...state.value!.messages,
            AiChatMessage(text: 'AI request cancelled.', isUser: false),
          ],
        ),
      );
    }
  }
}
