import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/providers/cart_provider.dart';

class ProcessCheckOut extends ConsumerWidget {
  const ProcessCheckOut({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            title: Center(
              child: Text('CheckOut', style: TextStyle(color: Colors.white)),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
            backgroundColor: Colors.transparent, // Make the app bar transparent
            elevation: 0.0, // Remove shadow
            flexibleSpace: Image.asset(
              "assets/food4.webp",
              fit: BoxFit.cover, // Cover the entire app bar area
            ),
          ),

          SliverList.builder(
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final item = cart[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text("Rs. ${item.price.toStringAsFixed(0)}"),
                trailing: Text(item.quantity.toString()),
              );
            },
          ),
        ],
      ),
    );
  }
}
