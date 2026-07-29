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
        ],
      ),
    ];

    _systemInstruction = Content.system(
      '''
Role: Restro Hub AI Assistant.
Goal: Help users find restaurants and food with brief, premium advice.

Available Menu Summary:
- Italian: Spaghetti Carbonara (Rs. 450), Margherita Pizza (Rs. 550), Lasagna Bolognese.
- Indian: Chicken Tikka Masala (Rs. 450), Butter Chicken (Rs. 400), Paneer Butter Masala.
- Chinese: Kung Pao Chicken (Rs. 550), Peking Duck, Mapo Tofu.
- Mexican: Beef Tacos (Rs. 550), Enchiladas Verdes, Guacamole.
- Japanese: Ramen Tonkotsu (Rs. 950), California Roll.
- Thai: Tom Yum Goong (Rs. 550), Pad Thai.
- USA: Classic Burger (Rs. 300), BBQ Ribs.

Available Restaurants:
- RoadSide Cafe (Lakeside): Italian, Budget-friendly.
- Airakan Restro: Asian Fusion, Premium.
- Tasty Heaven: Classic comfort food.

Rules:
- Be concise (max 2 sentences).
- If asked for recommendations, suggest something from the list above.
- Tone: Professional, helpful, food-expert.
''',
    );
  }

  Future<GenerateContentResponse> routeSearch(
    String query, {
    List<Content> history = const [],
  }) async {
    final contents = [...history, Content.text(query)];

    return ref
        .read(geminiServiceProvider.notifier)
        .generateContent(
          contents: contents,
          tools: _tools,
          systemInstruction: _systemInstruction,
        );
  }
}
