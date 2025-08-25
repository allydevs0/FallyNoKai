import 'package:flutter/material.dart';
import 'package:anime/models/anime_model.dart';
import 'package:anime/screens/anime_detail_screen.dart';
import 'package:anime/widgets/anime_card.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final List<Anime> animeList;

  const CategoryScreen({Key? key, required this.title, required this.animeList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return AnimeCard(
            anime: anime,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AnimeDetailScreen(anime: anime)),
              );
            },
          );
        },
      ),
    );
  }
}
