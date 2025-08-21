import 'package:anime/models/anime_model.dart';
import 'package:anime/models/episode_model.dart';
import 'package:anime/models/video_model.dart';
import 'package:anime/services/anime_source.dart';
import 'package:anime/services/default_anime_scraper.dart';

class AnimeScraper implements AnimeSource {
  // Default to DefaultAnimeScraper, but can be changed
  AnimeSource _currentSource = DefaultAnimeScraper();

  // Method to set the current active source
  void setSource(AnimeSource source) {
    _currentSource = source;
  }

  // Delegate methods to the current active source
  @override
  String get name => _currentSource.name;

  @override
  String get baseUrl => _currentSource.baseUrl;

  @override
  bool get supportsLatest => _currentSource.supportsLatest;

  @override
  Future<List<Anime>> fetchPopularAnime(int page) {
    return _currentSource.fetchPopularAnime(page);
  }

  @override
  Future<List<Anime>> fetchLatestUpdates(int page) {
    return _currentSource.fetchLatestUpdates(page);
  }

  @override
  Future<List<Anime>> searchAnime(int page, String query, List<dynamic> filters) {
    return _currentSource.searchAnime(page, query, filters);
  }

  @override
  Future<Anime> fetchAnimeDetails(String url) {
    return _currentSource.fetchAnimeDetails(url);
  }

  @override
  Future<List<Episode>> fetchEpisodeList(String url) {
    return _currentSource.fetchEpisodeList(url);
  }

  @override
  Future<List<Video>> fetchVideoList(String url) {
    return _currentSource.fetchVideoList(url);
  }
}