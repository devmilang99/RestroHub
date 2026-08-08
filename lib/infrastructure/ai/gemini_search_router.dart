import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:restro_hub/infrastructure/ai/gemini_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_search_router.g.dart';

@riverpod
class GeminiSearchRouter extends _$GeminiSearchRouter {
  final _searchRestaurantsTool = FunctionDeclaration(
    'search_restaurants',
    'Find restaurants.',
    Schema.object(
      properties: {
        'keywords': Schema.string(description: 'Name/type (e.g. Italian).'),
        'location': Schema.string(description: 'Area.'),
        'rating_min': Schema.number(description: 'Min rating (0-5).'),
      },
    ),
  );

  final _searchCuisinesTool = FunctionDeclaration(
    'search_cuisines',
    'Find food/cuisines.',
    Schema.object(
      properties: {
        'keywords': Schema.string(description: 'Item (e.g. Pizza).'),
        'category': Schema.string(description: 'Cuisine (e.g. Indian).'),
        'price_max': Schema.number(description: 'Max price.'),
      },
    ),
  );

  final _searchMenuItemsTool = FunctionDeclaration(
    'search_menu_items',
    'Find specific dishes or food items.',
    Schema.object(
      properties: {
        'keywords': Schema.string(
          description: 'Food name or type (e.g. Burger, Ribs).',
        ),
        'price_max': Schema.number(description: 'Max price.'),
        'rating_min': Schema.number(description: 'Min rating (0-5).'),
      },
    ),
  );

  final _getRestaurantDetailsTool = FunctionDeclaration(
    'get_restaurant_details',
    'Get details.',
    Schema.object(
      properties: {
        'restaurant_id': Schema.string(description: 'ID.'),
      },
      requiredProperties: ['restaurant_id'],
    ),
  );

  final _applyCouponTool = FunctionDeclaration(
    'apply_coupon',
    'Apply coupons.',
    Schema.object(
      properties: {
        'coupon_code': Schema.string(description: 'Code.'),
        'restaurant_id': Schema.string(description: 'ID.'),
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
          _searchMenuItemsTool,
          _getRestaurantDetailsTool,
          _applyCouponTool,
        ],
      ),
    ];

    _systemInstruction = Content.system(
      '''You are Restro Hub AI. Brief & Professional.
- Use 'search_restaurants' for exploration or "Top/Best" queries.
- Use 'apply_coupon' for discounts.
- Call tools before saying no results.
- Post-tool: 1-2 sentences only.
- NO prices in text (shown in cards).''',
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
