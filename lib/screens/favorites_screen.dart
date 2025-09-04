import 'package:anime/screens/anime_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:anime/main.dart';
import 'package:anime/models/anime_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Meus Favoritos'),
      ),
      child: ValueListenableBuilder<List<Anime>>(
        valueListenable: favoriteService.favorites,
        builder: (context, favorites, child) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text('Nenhum anime favoritado ainda.'),
            );
          }
          return ListView.separated(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final anime = favorites[index];
              return CupertinoListTile(
                leading: anime.thumbnailUrl != null && anime.thumbnailUrl!.isNotEmpty
                    ? Image.network(anime.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(anime.title ?? 'Untitled'),
                subtitle: Text(
                  anime.description?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') ?? '',
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    favoriteService.toggleFavorite(anime);
                  },
                  child: const Icon(CupertinoIcons.heart_fill, color: CupertinoColors.systemRed),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => AnimeDetailScreen(anime: anime),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }
}