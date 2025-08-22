import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_model.dart';
import '../models/episode_model.dart';
import '../services/anime_scraper.dart';
import 'package:anime/services/source_selection_service.dart';
import 'package:anime/video_player_screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final Anime anime;

  const AnimeDetailScreen({Key? key, required this.anime}) : super(key: key);

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  List<Episode> _episodes = [];
  bool _isLoading = true;
  String? _errorMessage;
  late Anime _displayAnime; // Added to hold the anime object for display

  @override
  void initState() {
    super.initState();
    _displayAnime = widget.anime; // Initialize with the passed anime
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final sourceService = SourceSelectionService();
      final selectedSource = await sourceService.getSelectedSource();

      // Search for the anime by title using the selected source
      final searchResults = await selectedSource.searchAnime(1, widget.anime.title, []); // Assuming page 1 and no filters

      Anime? matchedAnime;
      for (var result in searchResults) {
        if (result.title.toLowerCase() == widget.anime.title.toLowerCase()) {
          matchedAnime = result;
          break;
        }
      }

      if (matchedAnime != null) {
        // Update _displayAnime with scraper's banner if available
        if (matchedAnime.bannerImageUrl != null && matchedAnime.bannerImageUrl!.isNotEmpty) {
          _displayAnime = _displayAnime.copyWith(bannerImageUrl: matchedAnime.bannerImageUrl);
        } else if (matchedAnime.thumbnailUrl != null && matchedAnime.thumbnailUrl!.isNotEmpty && _displayAnime.thumbnailUrl == null) {
          // Fallback to scraper's thumbnail if no banner and current thumbnail is null
          _displayAnime = _displayAnime.copyWith(thumbnailUrl: matchedAnime.thumbnailUrl);
        }

        // Use the URL from the matched anime to call fetchEpisodeList
        final episodes = await selectedSource.fetchEpisodeList(matchedAnime.url);
        setState(() {
          _episodes = episodes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No exact match found for "${widget.anime.title}".';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load episodes: $e';
        _isLoading = false;
      });
    }
  }

  void _playEpisode(Episode episode) async {
    try {
      final scraper = AnimeScraper();
      final videos = await scraper.fetchVideoList(episode.url);

      if (videos.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              episode: episode,
              videos: videos,
              episodes: _episodes,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No videos found for this episode.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing episode: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayAnime.title), // Use _displayAnime
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: _fetchEpisodes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // <-- corrigido aqui
                    children: [
                      if (_displayAnime.thumbnailUrl != null || _displayAnime.bannerImageUrl != null)
                        Hero(
                          tag: 'anime-thumbnail-${_displayAnime.url}',
                          child: CachedNetworkImage(
                            imageUrl: _displayAnime.bannerImageUrl ?? _displayAnime.thumbnailUrl!,
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                            placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayAnime.title, // Use _displayAnime
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _displayAnime.description ?? 'No description available.',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Episodes:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _episodes.length,
                              itemBuilder: (context, index) {
                                final episode = _episodes[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text(episode.title),
                                    subtitle: Text(
                                        'Episode ${episode.episodeNumber.toStringAsFixed(0)}'),
                                    onTap: () => _playEpisode(episode),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
