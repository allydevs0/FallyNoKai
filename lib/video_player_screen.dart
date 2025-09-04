import 'package:flutter/cupertino.dart';
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
  bool _isSeeked = false;

  @override
  void initState() {
    super.initState();
    _historyService = Provider.of<HistoryService>(context, listen: false);
    _currentIndex = widget.episodes.indexWhere((e) => e.url == widget.episode.url);
    _currentVideo = widget.videos.first;

    _player = Player();
    _videoController = mkv.VideoController(_player);
    _player.open(Media(_currentVideo.url!));

    _player.stream.duration.listen((duration) {
      if (duration > Duration.zero && !_isSeeked) {
        _loadAndSeekHistory();
        _isSeeked = true;
      }
    });

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
      _player.open(Media(video.url!));
      _isSeeked = false;
    });
  }

  void _goToEpisode(int index) {
    if (index < 0 || index >= widget.episodes.length) return;

    final nextEpisode = widget.episodes[index];
    final nextVideo = widget.videos.first;

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
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

    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black87,
        middle: Text(widget.episode.title, style: const TextStyle(color: Colors.white)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.videos.length > 1)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => CupertinoActionSheet(
                      actions: widget.videos.map((video) {
                        return CupertinoActionSheetAction(
                          child: Text(video.quality!),
                          onPressed: () {
                            _changeVideo(video);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                      cancelButton: CupertinoActionSheetAction(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.settings),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: hasPrevious ? () => _goToEpisode(_currentIndex - 1) : null,
              child: const Icon(CupertinoIcons.backward_end_fill),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: hasNext ? () => _goToEpisode(_currentIndex + 1) : null,
              child: const Icon(CupertinoIcons.forward_end_fill),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: mkv.Video(controller: _videoController),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(widget.anime.title ?? 'Untitled',
                    style: const TextStyle(color: Colors.white, fontSize: 20), softWrap: true, maxLines: 2),
                Text(widget.episode.title,
                    style: const TextStyle(color: Colors.white70), softWrap: true, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
