import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/core/providers/favourites_provider.dart';

class ShowFavourites extends ConsumerStatefulWidget {
  const ShowFavourites({super.key});

  @override
  ConsumerState<ShowFavourites> createState() => _ShowFavouritesState();
}

class _ShowFavouritesState extends ConsumerState<ShowFavourites> {
  @override
  Widget build(BuildContext context) {
    final favourites = ref.read(favouritesProvider.notifier);
    final mainList = favourites.listFromFavourites();
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: ListView.builder(
        itemCount: mainList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(mainList[index].name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref
                    .read(favouritesProvider.notifier)
                    .removeFromFavourites(mainList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
