import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_hub/features/ai/presentation/ai_search_notifier.dart';
import 'package:restro_hub/features/ai/presentation/ai_search_state.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:restro_hub/features/chat/presentation/widgets/ai_assistant_widgets.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_menu_screen.dart';

class AiSearchScreen extends ConsumerStatefulWidget {
  const AiSearchScreen({super.key});

  @override
  ConsumerState<AiSearchScreen> createState() => _AiSearchScreenState();
}

class _AiSearchScreenState extends ConsumerState<AiSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? manualText]) {
    final text = manualText ?? _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(aiSearchProvider.notifier).performAiSearch(text);
      if (manualText == null) _controller.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiSearchProvider);
    final isInitial = aiState.value?.messages.isEmpty ?? true;

    final user = ref.watch(authRepositoryProvider).currentUser;
    final userName = user?.fullName?.split(' ').first ?? 'there';

    // Auto scroll to bottom when messages change
    ref.listen<AsyncValue<AiSearchState>>(aiSearchProvider, (
      previous,
      next,
    ) {
      final nextValue = next.value;
      final prevValue = previous?.value;
      if (nextValue == null) return;

      if (nextValue.error != null && nextValue.error != prevValue?.error) {
        // Only show snackbar for limit-related or non-chat errors
        if (nextValue.error!.contains('limit') ||
            nextValue.error!.contains('restart') ||
            nextValue.messages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(nextValue.error!)),
          );
        }
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1A12),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, colorScheme, isInitial),
              Expanded(
                child: isInitial
                    ? _buildInitialView(colorScheme, userName)
                    : _buildChatView(aiState),
              ),
              // status is shown inside the input bar to avoid extra layout height
              // Respect keyboard insets so the input bar isn't covered or causes overflow
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SafeArea(
                  top: false,
                  child: AiInputBar(
                    controller: _controller,
                    onSend: _sendMessage,
                    onStop: () =>
                        ref.read(aiSearchProvider.notifier).cancelSearch(),
                    isProcessing: aiState.value?.isProcessing ?? false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isInitial,
  ) {
    final aiState = ref.watch(aiSearchProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              isInitial ? Icons.arrow_back : Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              if (isInitial) {
                Navigator.pop(context);
              } else {
                ref.read(aiSearchProvider.notifier).clearSearch();
              }
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF322416),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: GoogleFonts.poppins(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.history_toggle_off,
              color: Colors.white70,
            ),
            onPressed: () => ref.read(aiSearchProvider.notifier).clearSearch(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView(ColorScheme colorScheme, String userName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hi, $userName!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'What can I help you find today?',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Quick Explore',
              style: GoogleFonts.poppins(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              QuickActionCard(
                icon: Icons.star,
                title: 'Top Rated',
                subtitle: 'Find top-rated restaurants',
                onTap: () => _sendMessage('Find top-rated restaurants near me'),
              ),
              QuickActionCard(
                icon: Icons.restaurant,
                title: 'Italian Bistro',
                subtitle: 'Authentic Italian flavors',
                onTap: () =>
                    _sendMessage('Show me authentic Italian restaurants'),
              ),
              QuickActionCard(
                icon: Icons.coffee,
                title: 'Coffee & Snacks',
                subtitle: 'Great coffee and snacks',
                onTap: () =>
                    _sendMessage('Where can I get good coffee and snacks?'),
              ),
              QuickActionCard(
                icon: Icons.location_on,
                title: 'Near Kathmandu',
                subtitle: 'Restaurants in Kathmandu',
                onTap: () =>
                    _sendMessage('What are the best restaurants in Kathmandu?'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const PoweredByGeminiLabel(),
        ],
      ),
    );
  }

  Widget _buildChatView(AsyncValue<AiSearchState> aiState) {
    return aiState.when(
      data: (state) => ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        itemCount: state.messages.length + (state.isProcessing ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.messages.length) {
            final msg = state.messages[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChatBubble(
                  text: msg.text ?? '',
                  isUser: msg.isUser,
                ),
                if (!msg.isUser && msg.restaurants.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Top recommendations',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...msg.restaurants.map(
                    (r) => RecommendationCard(
                      title: r.name,
                      description: r.description,
                      price: 'Rs. ${(r.rating * 10).toInt()}', // Sample price
                      category: 'Restaurant',
                      imageUrl: r.bannerUrl ?? '',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantMenuScreen(restaurant: r),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          }

          return const AiThinkingBubble();
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFB700),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.orange : const Color(0xFF1E262C),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: isUser ? Colors.black87 : Colors.white,
                  fontSize: 14,
                  fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
