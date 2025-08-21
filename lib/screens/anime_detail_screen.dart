import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_model.dart';
import '../models/episode_model.dart';
import '../services/anime_scraper.dart'; // Assuming this is the service to fetch episodes
import 'package:anime/video_player_screen.dart'; // Import the video player screen


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

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Assuming AnimeScraper has a method to get episodes for an anime
      // You might need to adjust this based on the actual AnimeScraper implementation
      final scraper = AnimeScraper(); // Use the wrapper class
      final episodes = await scraper.fetchEpisodeList(widget.anime.url);

      setState(() {
        _episodes = episodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load episodes: $e';
        _isLoading = false;
      });
    }
  }

  void _playEpisode(Episode episode) async {
    try {
      // Fetch videos for the selected episode
      final scraper = AnimeScraper(); // Use the wrapper class
      final videos = await scraper.fetchVideoList(episode.url);

      if (videos.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              episode: episode,
              videos: videos,
              episodes: _episodes, // Pass the list of episodes
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
        title: Text(widget.anime.title),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.anime.thumbnailUrl != null)
                        Hero(
                          tag: 'anime-thumbnail-${widget.anime.url}', // Same tag as in AnimeCard
                          child: CachedNetworkImage(
                            imageUrl: widget.anime.thumbnailUrl!,
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
                              widget.anime.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.anime.description ?? 'No description available.',
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
                                    subtitle: Text('Episode ${episode.episodeNumber.toStringAsFixed(0)}'),
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
