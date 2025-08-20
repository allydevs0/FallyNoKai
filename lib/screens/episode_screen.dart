import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../video_player_screen.dart';

class EpisodeScreen extends StatelessWidget {
  final Anime anime;

  const EpisodeScreen({Key? key, required this.anime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime.title),
      ),
      body: ListView.builder(
        itemCount: anime.episodes ?? 0,
        itemBuilder: (context, index) {
          final episodeNumber = index + 1;
          return ListTile(
            title: Text('Episode $episodeNumber'),
            onTap: () {
              // ATENÇÃO: Use uma URL de vídeo real e legal aqui.
              // Esta é uma URL de exemplo para teste.
              const sampleVideoUrl =
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoUrl: sampleVideoUrl,
                    title: '${anime.title} - Episode $episodeNumber',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
