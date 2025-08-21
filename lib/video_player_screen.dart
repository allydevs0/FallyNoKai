import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:anime/models/video_model.dart';
import 'package:anime/models/episode_model.dart';
import 'package:provider/provider.dart';
import 'package:anime/services/player_selection_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:anime/services/anime_scraper.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Episode episode;
  final List<Video> videos;
  final List<Episode> episodes;

  const VideoPlayerScreen({
    super.key,
    required this.episode,
    required this.videos,
    required this.episodes,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // For media_kit
  late final Player player;
  late final media_kit_video.VideoController controller;

  // For video_player
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  bool _isLoading = true;
  String? _errorMessage;
  int _selectedVideoIndex = 0;

  late final PlayerSelectionService _playerService;

  @override
  void initState() {
    super.initState();
    _playerService = Provider.of<PlayerSelectionService>(context, listen: false);
    if (_playerService.selectedPlayer == 'native') {
      _initializeVideoPlayer();
    } else {
      player = Player();
      controller = media_kit_video.VideoController(player);
      _initializeMediaKitPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (widget.videos.isEmpty) {
        throw Exception('Nenhum vídeo disponível para este episódio');
      }

      _selectedVideoIndex = 0;
      for (int i = 0; i < widget.videos.length; i++) {
        if (widget.videos[i].quality.contains('720p')) {
          _selectedVideoIndex = i;
          break;
        }
      }

      final selectedVideo = widget.videos[_selectedVideoIndex];
      print("🎬 Inicializando player com vídeo: ${selectedVideo.quality} - ${selectedVideo.url}");

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(selectedVideo.url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
        httpHeaders: selectedVideo.headers ?? {},
      );

      await _videoPlayerController.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
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
      );

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      print("💥 Erro no player nativo: $e");
      _switchToMpvPlayer();
    } catch (e) {
      print("💥 Erro ao inicializar player: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _switchToMpvPlayer() async {
    await _playerService.setPlayer('mpv');
    player = Player();
    controller = media_kit_video.VideoController(player);
    await _initializeMediaKitPlayer();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro no player nativo. Trocando para o player MPV.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _initializeMediaKitPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (widget.videos.isEmpty) {
        throw Exception('Nenhum vídeo disponível para este episódio');
      }

      _selectedVideoIndex = 0;
      for (int i = 0; i < widget.videos.length; i++) {
        if (widget.videos[i].quality.contains('720p')) {
          _selectedVideoIndex = i;
          break;
        }
      }

      final selectedVideo = widget.videos[_selectedVideoIndex];
      print("🎬 Inicializando player com vídeo: ${selectedVideo.quality} - ${selectedVideo.url}");

      await player.open(Media(selectedVideo.url, httpHeaders: selectedVideo.headers));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("💥 Erro ao inicializar player: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeVideo(int index) async {
    if (index == _selectedVideoIndex) return;

    if (_playerService.selectedPlayer == 'native') {
      await _changeVideoPlayer(index);
    } else {
      await _changeMediaKitPlayer(index);
    }
  }

  Future<void> _changeVideoPlayer(int index) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _chewieController?.dispose();
      await _videoPlayerController.dispose();

      _selectedVideoIndex = index;
      final selectedVideo = widget.videos[_selectedVideoIndex];
      print("🎬 Mudando para vídeo: ${selectedVideo.quality} - ${selectedVideo.url}");

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(selectedVideo.url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
        httpHeaders: selectedVideo.headers ?? {},
      );

      await _videoPlayerController.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
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
      );

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      print("💥 Erro ao mudar vídeo: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeMediaKitPlayer(int index) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _selectedVideoIndex = index;
      final selectedVideo = widget.videos[_selectedVideoIndex];
      print("🎬 Mudando para vídeo: ${selectedVideo.quality} - ${selectedVideo.url}");

      await player.open(Media(selectedVideo.url, httpHeaders: selectedVideo.headers));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("💥 Erro ao mudar vídeo: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (_playerService.selectedPlayer == 'native') {
      _videoPlayerController.pause();
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    } else {
      player.pause();
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.episodes.indexWhere((e) => e.url == widget.episode.url);
    final hasNextEpisode = currentIndex < widget.episodes.length - 1;
    final hasPreviousEpisode = currentIndex > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(
          widget.episode.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: hasPreviousEpisode ? _playPreviousEpisode : null,
          ),
          if (widget.videos.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              onSelected: (value) {
                final index = int.tryParse(value);
                if (index != null) {
                  _changeVideo(index);
                }
              },
              itemBuilder: (context) => widget.videos.asMap().entries.map((entry) {
                final index = entry.key;
                final video = entry.value;
                return PopupMenuItem<String>(
                  value: index.toString(),
                  child: Row(
                    children: [
                      if (index == _selectedVideoIndex)
                        const Icon(Icons.check, color: Colors.green)
                      else
                        const SizedBox(width: 24),
                      Text(video.quality),
                    ],
                  ),
                );
              }).toList(),
            ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: hasNextEpisode ? _playNextEpisode : null,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  void _playPreviousEpisode() async {
    final currentIndex = widget.episodes.indexWhere((e) => e.url == widget.episode.url);
    if (currentIndex > 0) {
      final previousEpisode = widget.episodes[currentIndex - 1];
      try {
        final scraper = AnimeScraper();
        final videos = await scraper.fetchVideoList(previousEpisode.url);
        if (videos.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                episode: previousEpisode,
                videos: videos,
                episodes: widget.episodes,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No videos found for the previous episode.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing previous episode: $e')),
        );
      }
    }
  }

  void _playNextEpisode() async {
    final currentIndex = widget.episodes.indexWhere((e) => e.url == widget.episode.url);
    if (currentIndex < widget.episodes.length - 1) {
      final nextEpisode = widget.episodes[currentIndex + 1];
      try {
        final scraper = AnimeScraper();
        final videos = await scraper.fetchVideoList(nextEpisode.url);
        if (videos.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                episode: nextEpisode,
                videos: videos,
                episodes: widget.episodes,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No videos found for the next episode.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing next episode: $e')),
        );
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
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
      );
    }

    if (_errorMessage != null) {
      return Center(
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
              onPressed: () {
                if (_playerService.selectedPlayer == 'native') {
                  _initializeVideoPlayer();
                } else {
                  _initializeMediaKitPlayer();
                }
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_playerService.selectedPlayer == 'native') {
      if (!_isInitialized || _chewieController == null) {
        return const Center(
          child: Text(
            'Player não inicializado',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
      return Chewie(controller: _chewieController!);
    } else {
      return media_kit_video.Video(controller: controller);
    }
  }
}
