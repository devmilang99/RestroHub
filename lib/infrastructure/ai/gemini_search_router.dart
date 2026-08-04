import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:restro_hub/infrastructure/ai/gemini_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_search_router.g.dart';

@riverpod
class GeminiSearchRouter extends _$GeminiSearchRouter {
  final _searchRestaurantsTool = FunctionDeclaration(
    'search_restaurants',
    'Search Restro Hub for restaurants. Use when user wants to find places to eat.',
    Schema.object(
      properties: {
        'keywords': Schema.string(
          description: 'Restaurant name or type (e.g. Italian).',
        ),
        'location': Schema.string(description: 'Location or area.'),
        'rating_min': Schema.number(description: 'Minimum rating (0-5).'),
      },
    ),
  );

  final _searchCuisinesTool = FunctionDeclaration(
    'search_cuisines',
    'Search for specific food items or cuisines across restaurants.',
    Schema.object(
      properties: {
        'keywords': Schema.string(description: 'Food item name (e.g. Pizza).'),
        'category': Schema.string(
          description: 'Cuisine category (e.g. Indian, Chinese, Continental).',
        ),
        'price_max': Schema.number(description: 'Maximum price.'),
      },
    ),
  );

  final _getRestaurantDetailsTool = FunctionDeclaration(
    'get_restaurant_details',
    'Get detailed information for a specific restaurant.',
    Schema.object(
      properties: {
        'restaurant_id': Schema.string(description: 'Unique restaurant ID.'),
      },
      requiredProperties: ['restaurant_id'],
    ),
  );

  final _applyCouponTool = FunctionDeclaration(
    'apply_coupon',
    'Check or apply restaurant discount coupons.',
    Schema.object(
      properties: {
        'coupon_code': Schema.string(description: 'Coupon code.'),
        'restaurant_id': Schema.string(
          description: 'Restaurant ID (optional).',
        ),
      },
      requiredProperties: ['coupon_code'],
    ),
  );

  late final List<Tool> _tools;
  late final Content _systemInstruction;

  @override
  FutureOr<void> build() {
    _tools = [
      Tool(
        functionDeclarations: [
          _searchRestaurantsTool,
          _searchCuisinesTool,
          _getRestaurantDetailsTool,
          _applyCouponTool,
        ],
      ),
    ];

    _systemInstruction = Content.system(
      '''
Role: Restro Hub AI Assistant.
Goal: Help users find restaurants and food with brief, premium advice.

Rules:
- Use 'search_restaurants' for any exploration, category mentions, or "Best/Top" queries.
- Use 'apply_coupon' for discount or offer related queries.
- Call tools before claiming no results.
- Post-tool: Give a concise natural language response (max 2 sentences).
- Do NOT list prices in text (already in UI cards).
- Tone: Professional, Brief & Helpful.
''',
    );
  }

  Future<GenerateContentResponse> routeSearch(
    String query, {
    List<Content> history = const [],
  }) async {
    final contents = [...history, Content.text(query)];
    return routeSearchWithContent(contents);
  }

  Future<GenerateContentResponse> routeSearchWithContent(
    List<Content> contents,
  ) async {
    return ref
        .read(geminiServiceProvider.notifier)
        .generateContent(
          contents: contents,
          tools: _tools,
          systemInstruction: _systemInstruction,
        );
  }

  Future<dynamic> listAvailableModels() =>
      ref.read(geminiServiceProvider.notifier).listModels();
}
