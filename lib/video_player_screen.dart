import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../models/episode_model.dart';
import '../models/video_model.dart';
import '../models/history_entry_model.dart';
import '../services/history_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Anime anime;
  final Episode episode;
  final List<Video> videos;
  final List<Episode> episodes;

  const VideoPlayerScreen({
    super.key,
    required this.anime,
    required this.episode,
    required this.videos,
    required this.episodes,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late Player _player;
  late mkv.VideoController _videoController;
  late Video _currentVideo;
  late int _currentIndex;
  late HistoryService _historyService;

  @override
  void initState() {
    super.initState();
    _historyService = Provider.of<HistoryService>(context, listen: false);
    _currentIndex = widget.episodes.indexWhere((e) => e.url == widget.episode.url);
    _currentVideo = widget.videos.first;

    _player = Player();
    _videoController = mkv.VideoController(_player);
    _player.open(Media(_currentVideo.url!)); // Added !

    _loadAndSeekHistory();

    // Listen to player position changes to continuously update history
    _player.stream.position.listen((position) {
      _saveHistory(); // Save frequently
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAndSeekHistory() async {
    print("Loading history for ${widget.anime.title} - ${widget.episode.title}");
    final historyEntry = _historyService.history.value.firstWhere(
      (entry) => entry.anime.url == widget.anime.url && entry.episode?.url == widget.episode.url,
      orElse: () => HistoryEntry(anime: widget.anime, episode: widget.episode),
    );

    print("Last position: ${historyEntry.lastPosition}");
    if (historyEntry.lastPosition.inSeconds > 0) {
      _player.seek(historyEntry.lastPosition);
      print("Seeking to ${historyEntry.lastPosition}");
    }
  }

  Future<void> _saveHistory() async {
    final currentPosition = _player.state.position;
    print("Saving history for ${widget.anime.title} - ${widget.episode.title} at ${currentPosition}");
    final newEntry = HistoryEntry(
      anime: widget.anime,
      episode: widget.episode,
      lastPosition: currentPosition,
      lastWatched: DateTime.now(),
    );
    await _historyService.addOrUpdateHistoryEntry(newEntry);
  }

  void _changeVideo(Video video) {
    setState(() {
      _currentVideo = video;
      _player.open(Media(video.url!)); // Added !
    });
  }

  void _goToEpisode(int index) {
    if (index < 0 || index >= widget.episodes.length) return;

    final nextEpisode = widget.episodes[index];
    final nextVideo = widget.videos.first;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          anime: widget.anime,
          episode: nextEpisode,
          videos: [nextVideo],
          episodes: widget.episodes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNext = _currentIndex < widget.episodes.length - 1;
    final hasPrevious = _currentIndex > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(widget.episode.title, softWrap: true, maxLines: 2), // No change, assuming it's String
        actions: [
          if (widget.videos.length > 1)
            PopupMenuButton<int>(
              icon: const Icon(Icons.settings),
              onSelected: (index) => _changeVideo(widget.videos[index]),
              itemBuilder: (context) => widget.videos.asMap().entries.map((entry) {
                final index = entry.key;
                final video = entry.value;
                return PopupMenuItem<int>(
                  value: index,
                  child: Row(
                    children: [
                      if (video == _currentVideo)
                        const Icon(Icons.check, color: Colors.green)
                      else
                        const SizedBox(width: 24),
                      Text(video.quality!), // Added !
                    ],
                  ),
                );
              }).toList(),
            ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: hasPrevious ? () => _goToEpisode(_currentIndex - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: hasNext ? () => _goToEpisode(_currentIndex + 1) : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: mkv.Video(controller: _videoController),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(widget.anime.title ?? 'Untitled', // Added null check
                    style: const TextStyle(color: Colors.white, fontSize: 20), softWrap: true, maxLines: 2),
                Text(widget.episode.title, // No change, assuming it's String
                    style: const TextStyle(color: Colors.white70), softWrap: true, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}