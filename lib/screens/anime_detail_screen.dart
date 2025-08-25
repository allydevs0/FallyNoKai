import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_model.dart';
import '../models/episode_model.dart';
import '../services/anime_scraper.dart';
import 'package:anime/video_player_screen.dart';
import '../services/source_selection_service.dart';
import '../services/favorite_service.dart';
import 'package:provider/provider.dart';

/// Widget de exibição de erros com retry e botão de voltar
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool showBackButton;

  const ErrorDisplay({
    Key? key,
    required this.message,
    required this.onRetry,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
          if (showBackButton) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tela de detalhes do anime
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

  final SourceSelectionService _sourceSelectionService = SourceSelectionService();
  late FavoriteService _favoriteService;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Obtem o FavoriteService do Provider
    _favoriteService = Provider.of<FavoriteService>(context, listen: false);
    _checkFavoriteStatus();
    _fetchEpisodes();
  }

  void _checkFavoriteStatus() {
    setState(() {
      _isFavorite = _favoriteService.isFavorite(widget.anime);
    });
  }

  void _toggleFavorite() async {
    await _favoriteService.toggleFavorite(widget.anime);
    _checkFavoriteStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites!' : 'Removed from favorites!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _fetchEpisodes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final selectedSource = await _sourceSelectionService.getSelectedSource();
      List<Anime> searchResults = await selectedSource.searchAnime(1, widget.anime.title!, []); // Added !

      Anime? foundAnime;
      if (searchResults.isNotEmpty) {
        foundAnime = searchResults.firstWhere(
          (a) => (a.title?.toLowerCase() ?? '') == (widget.anime.title?.toLowerCase() ?? ''), // Added null checks
          orElse: () => searchResults.first,
        );
      }

      if (foundAnime != null) {
        final episodes = await selectedSource.fetchEpisodeList(foundAnime.url!); // Added !
        setState(() {
          _episodes = episodes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No anime found from selected source for "${widget.anime.title}"';
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
      final selectedSource = await _sourceSelectionService.getSelectedSource();
      final videos = await selectedSource.fetchVideoList(episode.url);

      if (videos.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              anime: widget.anime,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _fetchEpisodes,
                  showBackButton: true,
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250,
                      pinned: true,
                      backgroundColor: Colors.black,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(widget.anime.title ?? 'Untitled', softWrap: true, maxLines: 2), // Added null check
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (widget.anime.thumbnailUrl != null)
                              CachedNetworkImage(
                                imageUrl: widget.anime.thumbnailUrl!, // Still asserting non-null
                                fit: BoxFit.cover,
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.redAccent : Colors.white,
                            size: 28,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.anime.description ?? 'No description available.',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final episode = _episodes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  episode.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Episode ${episode.episodeNumber.toStringAsFixed(0)}'),
                                trailing: const Icon(Icons.play_arrow),
                                onTap: () => _playEpisode(episode),
                              ),
                            ),
                          );
                        },
                        childCount: _episodes.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
    );
  }
}