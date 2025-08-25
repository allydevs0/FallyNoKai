import 'package:anime/screens/anime_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime/main.dart';
import 'package:anime/models/anime_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
      ),
      body: ValueListenableBuilder<List<Anime>>(
        valueListenable: favoriteService.favorites,
        builder: (context, favorites, child) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text('Nenhum anime favoritado ainda.'),
            );
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final anime = favorites[index];
              return ListTile(
                leading: anime.thumbnailUrl != null && anime.thumbnailUrl!.isNotEmpty
                    ? Image.network(anime.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(anime.title ?? 'Untitled', softWrap: true, maxLines: 2), // Null check for title
                subtitle: Text(
                  anime.description?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') ?? '', // Null check for description
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    favoriteService.toggleFavorite(anime);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailScreen(anime: anime),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}