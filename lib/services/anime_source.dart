
import 'package:anime/models/anime_model.dart';
import 'package:anime/models/episode_model.dart';
import 'package:anime/models/video_model.dart';

abstract class AnimeSource {
  String get name;
  String get baseUrl;
  bool get supportsLatest;

  Future<List<Anime>> fetchPopularAnime(int page);
  Future<List<Anime>> fetchLatestUpdates(int page);
  Future<List<Anime>> searchAnime(int page, String query, List<dynamic> filters); // filters will be dynamic for now
  Future<Anime> fetchAnimeDetails(String url);
  Future<List<Episode>> fetchEpisodeList(String url);
  Future<List<Video>> fetchVideoList(String url);
}
