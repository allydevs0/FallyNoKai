import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/anime_model.dart';
// Import Video model
import '../services/anime_scraper.dart'; // Import AnimeScraper
import '../main.dart' as main_app; // Import main_app for global services

class EpisodeScreen extends StatefulWidget {
  final Anime anime;

  const EpisodeScreen({Key? key, required this.anime}) : super(key: key);

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedVideoIndex = 0;

  List<Map<String, String>> _scrapedEpisodes = []; // To store fetched episodes
  final AnimeScraper _animeScraper = AnimeScraper(); // Local instance for this screen

  @override
  void initState() {
    super.initState();
    _fetchEpisodesAndInitializePlayer(); // Fetch episodes when screen initializes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Explicitly depend on common InheritedWidgets to ensure they are available during dispose
    MediaQuery.of(context);
    Theme.of(context);
  }

  Future<void> _fetchEpisodesAndInitializePlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final episodes = await _animeScraper.fetchEpisodeList(widget.anime.url);
      if (!mounted) return;
      setState(() {
        _scrapedEpisodes = episodes
            .map((e) => {'title': e.title, 'url': e.url})
            .toList();
        _isLoading = false;
      });
      // Optionally, auto-play the first episode if available
      if (_scrapedEpisodes.isNotEmpty) {
        _initializeVideoPlayer(_scrapedEpisodes[0]['url']!, _scrapedEpisodes[0]['title'] ?? 'Episódio 1');
      } else {
        setState(() {
          _errorMessage = 'Nenhum episódio encontrado para este anime.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar episódios: $e';
        _isLoading = false;
      });
      main_app.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Erro ao carregar episódios: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl, String episodeTitle) async {
    print("🎬 EpisodeScreen: _initializeVideoPlayer called for URL: $videoUrl, Title: $episodeTitle"); // Added log
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Dispose previous controllers
      await _chewieController?.dispose();
      await _videoPlayerController?.dispose();

      // Fetch video links for the selected episode URL
      final videos = await _animeScraper.fetchVideoList(videoUrl);
      print("🎬 EpisodeScreen: Fetched ${videos.length} video links."); // Added log

      if (videos.isEmpty) {
        throw Exception('Nenhum link de vídeo encontrado para este episódio');
      }

      // Selecionar o melhor vídeo (720p primeiro, depois 360p)
      _selectedVideoIndex = 0;
      for (int i = 0; i < videos.length; i++) {
        if (videos[i].quality.contains('720p')) {
          _selectedVideoIndex = i;
          break;
        }
      }

      final selectedVideo = videos[_selectedVideoIndex];
      print("🎬 EpisodeScreen: Initializing player with video: ${selectedVideo.quality} - ${selectedVideo.url}"); // Added log

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(selectedVideo.url!),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
        httpHeaders: selectedVideo.headers ?? {},
      );

      await _videoPlayerController!.initialize();
      print("🎬 EpisodeScreen: VideoPlayerController initialized. isInitialized: ${_videoPlayerController!.value.isInitialized}, hasError: ${_videoPlayerController!.value.hasError}, errorDescription: ${_videoPlayerController!.value.errorDescription}"); // Added log

      // Check if widget is still mounted after async operations
      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, size: 100, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Carregando vídeo...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          if (!mounted) return const SizedBox.shrink();
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 100, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro ao carregar vídeo',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      print("🎬 EpisodeScreen: Player loading complete."); // Added log

    } catch (e) {
      print("💥 EpisodeScreen: Error initializing player: $e"); // Modified log
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      main_app.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Erro ao carregar vídeo: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anime.title ?? ''),
      ),
      body: Column(
        children: [
          // Video Player Section
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Carregando vídeo...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 100, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao carregar vídeo',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _fetchEpisodesAndInitializePlayer(), // Retry fetching episodes
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          else if (!_isInitialized || _chewieController == null)
            const Expanded(
              child: Center(
                child: Text(
                  'Player não inicializado',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            Expanded(
              child: Chewie(controller: _chewieController!),
            ),

          // Episode List Section
          Expanded(
            child: ListView.builder(
              itemCount: _scrapedEpisodes.length,
              itemBuilder: (context, index) {
                final episode = _scrapedEpisodes[index];
                return ListTile(
                  title: Text(episode['title'] ?? 'Episódio sem título'),
                  subtitle: Text(episode['url'] ?? 'URL não disponível'),
                  onTap: () {
                    // Play the selected episode
                    _initializeVideoPlayer(episode['url']!, episode['title'] ?? 'Episódio ${index + 1}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}