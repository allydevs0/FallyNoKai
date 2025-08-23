import 'package:flutter/material.dart';
import '../models/episode_model.dart';

class HistoryScreen extends StatefulWidget {
  final List<Episode> historyEpisodes;

  const HistoryScreen({Key? key, required this.historyEpisodes}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final episodes = widget.historyEpisodes;

    if (episodes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: const Center(
          child: Text('No history available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          final episode = episodes[index]; // garante que não é null
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(episode.title ?? 'Untitled Episode'),
              subtitle: Text('Episode ${episode.episodeNumber.toStringAsFixed(0)}'),
              trailing: const Icon(Icons.play_arrow),
              onTap: () {
                // Aqui você pode chamar a função para abrir o episódio no player
                print('Playing episode: ${episode.title}');
              },
            ),
          );
        },
      ),
    );
  }
}
