import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:restro_hub/features/chat/presentation/widgets/ai_assistant_widgets.dart';
import 'package:restro_hub/infrastructure/ai/gemini_search_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Content> _history = [];
  final List<Map<String, dynamic>> _displayMessages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  bool _isCancelled = false;
  int _errorCount = 0;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  Future<void> _sendMessage([String? manualText]) async {
    final text = manualText ?? _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    if (_errorCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Multiple errors occurred. Please restart the assistant.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _displayMessages.add({'role': 'user', 'text': text});
      if (manualText == null) _controller.clear();
      _isTyping = true;
      _isCancelled = false;
    });
    _scrollToBottom();

    try {
      final response = await ref
          .read(geminiSearchRouterProvider.notifier)
          .routeSearch(text, history: _history);

      if (_isCancelled) return;

      final assistantText =
          response.text ?? "I'm sorry, I couldn't process that.";

      setState(() {
        _displayMessages.add({'role': 'assistant', 'text': assistantText});

        _history
          ..add(Content.text(text))
          ..add(Content.model([TextPart(assistantText)]));
        _isTyping = false;
        _errorCount = 0; // Reset error count on success
      });
    } on Object catch (e) {
      if (_isCancelled) return;
      setState(() {
        _displayMessages.add({'role': 'assistant', 'text': 'Error: $e'});
        _isTyping = false;
        _errorCount++;
      });
    }
    _scrollToBottom();
  }

  void _cancelProcessing() {
    setState(() {
      _isCancelled = true;
      _isTyping = false;
      _displayMessages.add({
        'role': 'assistant',
        'text': 'Processing cancelled.',
      });
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isInitial = _displayMessages.isEmpty;

    final user = ref.watch(authRepositoryProvider).currentUser;
    final userName = user?.fullName?.split(' ').first ?? 'there';

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
              _buildAppBar(context, isInitial),
              Expanded(
                child: isInitial
                    ? _buildInitialView(userName)
                    : _buildChatView(),
              ),
              AiInputBar(
                controller: _controller,
                onSend: _sendMessage,
                onStop: _cancelProcessing,
                isProcessing: _isTyping,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isInitial) {
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
                setState(() {
                  _displayMessages.clear();
                  _history.clear();
                  _errorCount = 0;
                });
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
            icon: const Icon(Icons.history_toggle_off, color: Colors.white70),
            onPressed: () {
              setState(() {
                _displayMessages.clear();
                _history.clear();
                _errorCount = 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView(String userName) {
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
                subtitle: '"Find top-rated restaurants"',
                onTap: () => _sendMessage('Find top-rated restaurants near me'),
              ),
              QuickActionCard(
                icon: Icons.restaurant,
                title: 'Italian Bistro',
                subtitle: '"Authentic Italian flavors"',
                onTap: () =>
                    _sendMessage('Show me authentic Italian restaurants'),
              ),
              QuickActionCard(
                icon: Icons.coffee,
                title: 'Coffee & Snacks',
                subtitle: '"Great coffee and snacks"',
                onTap: () =>
                    _sendMessage('Where can I get good coffee and snacks?'),
              ),
              QuickActionCard(
                icon: Icons.location_on,
                title: 'Near Kathmandu',
                subtitle: '"Restaurants in Kathmandu"',
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

  Widget _buildChatView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _displayMessages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _displayMessages.length) {
          return const AiThinkingBubble();
        }
        final msg = _displayMessages[index];
        final role = msg['role'] as String;

        if (role == 'recommendation') {
          final data = msg['data'] as Map<String, dynamic>;
          final title = data['title'] as String;
          final description = data['description'] as String;
          final price = data['price'] as String;
          final category = data['category'] as String;
          final imageUrl = data['imageUrl'] as String;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              RecommendationCard(
                title: title,
                description: description,
                price: price,
                category: category,
                imageUrl: imageUrl,
              ),
            ],
          );
        }

        final isUser = role == 'user';
        return _ChatBubble(
          text: msg['text'] as String,
          isUser: isUser,
        );
      },
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
