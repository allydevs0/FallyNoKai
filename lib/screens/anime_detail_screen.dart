import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_model.dart';
import '../models/episode_model.dart';
import '../services/anime_scraper.dart';
import 'package:anime/video_player_screen.dart';
import '../services/source_selection_service.dart';
import '../services/favorite_service.dart';
import 'package:provider/provider.dart';

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
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(_isFavorite ? 'Added to favorites!' : 'Removed from favorites!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => VideoPlayerScreen(
              anime: widget.anime,
              episode: episode,
              videos: videos,
              episodes: _episodes,
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
        middle: Text(widget.anime.title ?? 'Untitled'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _toggleFavorite,
          child: Icon(
            _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: _isFavorite ? CupertinoColors.systemRed : CupertinoColors.white,
          ),
        ),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      CupertinoButton(
                        child: const Text('Retry'),
                        onPressed: _fetchEpisodes,
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (widget.anime.bannerImageUrl != null)
                            CachedNetworkImage(
                              imageUrl: widget.anime.bannerImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Text(
                              widget.anime.title ?? 'Untitled',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.anime.description ?? 'No description available.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    CupertinoListSection(
                      header: const Text('Episodes'),
                      children: _episodes.map(
                        (episode) => CupertinoListTile(
                          title: Text(episode.title),
                          subtitle: Text('Episode ${episode.episodeNumber.toStringAsFixed(0)}'),
                          trailing: const Icon(CupertinoIcons.play_arrow),
                          onTap: () => _playEpisode(episode),
                        ),
                      ).toList(),
                    ),
                  ],
                ),
    );
  }
}
