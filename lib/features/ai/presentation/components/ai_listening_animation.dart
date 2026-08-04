import 'package:flutter/material.dart';

class AiListeningAnimation extends StatefulWidget {
  const AiListeningAnimation({super.key});

  @override
  State<AiListeningAnimation> createState() => _AiListeningAnimationState();
}

class _AiListeningAnimationState extends State<AiListeningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.3 * _controller.value),
                  blurRadius: 10 * _controller.value,
                  spreadRadius: 5 * _controller.value,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          );
        },
      ),
    );
  }
}
