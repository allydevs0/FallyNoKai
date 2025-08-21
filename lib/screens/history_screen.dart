import 'package:flutter/material.dart';
import 'package:anime/main.dart';
import 'package:anime/models/anime_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // TODO: Implement clear history functionality in HistoryService
              print('Clear history tapped');
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Anime>>(
        valueListenable: historyService.history,
        builder: (context, history, child) {
          if (history.isEmpty) {
            return const Center(
              child: Text('Nenhum item no histórico ainda.'),
            );
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final anime = history[index];
              return ListTile(
                leading: anime.thumbnailUrl != null && anime.thumbnailUrl!.isNotEmpty
                    ? Image.network(anime.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(anime.title),
                subtitle: Text(anime.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')),
                onTap: () {
                  // TODO: Navigate to anime details or episode list
                  print('Tapped on history: ${anime.title}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
