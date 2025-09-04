import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime/services/history_service.dart';
import 'package:anime/models/history_entry_model.dart';
import 'package:anime/screens/anime_detail_screen.dart';
import 'package:anime/video_player_screen.dart';
import 'package:anime/services/source_selection_service.dart';
import 'package:anime/services/anime_scraper.dart';
import 'package:anime/services/anime_source.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  Future<void> _playEpisode(BuildContext context, HistoryEntry entry) async {
    final sourceService = Provider.of<SourceSelectionService>(context, listen: false);
    final selectedSource = sourceService.selectedSource;

    try {
      // Explicitly assert non-nullability for url
      final videos = await selectedSource.fetchVideoList(entry.episode!.url as String); // Added as String
      final allEpisodes = await selectedSource.fetchEpisodeList(entry.anime.url as String); // Added as String

      if (videos.isNotEmpty) {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => VideoPlayerScreen(
              anime: entry.anime,
              episode: entry.episode!,
              videos: videos,
              episodes: allEpisodes,
            ),
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('No videos found'),
            content: const Text('No videos found for this episode.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Error playing episode: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('History'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Provider.of<HistoryService>(context, listen: false).clearHistory();
          },
          child: const Icon(CupertinoIcons.delete),
        ),
      ),
      child: Consumer<HistoryService>(
        builder: (context, historyService, child) {
          final history = historyService.history.value;
          if (history.isEmpty) {
            return const Center(
              child: Text('No history available.'),
            );
          }
          return ListView.separated(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return CupertinoListTile(
                leading: entry.anime.thumbnailUrl != null && entry.anime.thumbnailUrl!.isNotEmpty
                    ? Image.network(entry.anime.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(entry.anime.title!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.episode?.title ?? 'Untitled Episode'),
                    if (entry.lastPosition.inSeconds > 0)
                      Text('Resumir em: ${entry.lastPosition.toString().split('.').first}'),
                  ],
                ),
                trailing: const Icon(CupertinoIcons.play_arrow),
                onTap: () => _playEpisode(context, entry),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }
}
