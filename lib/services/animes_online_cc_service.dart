import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'dart:convert'; // For JSON decoding
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import '../models/anime_model.dart'; // This now contains 'Anime'
import '../models/video_model.dart'; // This now contains 'Video'

class AnimesOnlineCCService {
  final String baseUrl = "https://animesonlinecc.to";
  late final SharedPreferences _prefs; // Declare SharedPreferences instance

  // Constructor
  AnimesOnlineCCService() {
    _initPreferences(); // Initialize preferences in the constructor
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Helper to get a string preference
  String _getPreference(String key, String defaultValue) {
    return _prefs.getString(key) ?? defaultValue;
  }

  // Helper to set a string preference
  Future<bool> _setPreference(String key, String value) async {
    return _prefs.setString(key, value);
  }

  // ============================== Popular ===============================
  Future<List<Anime>> fetchPopularAnime(int page) async { // Changed AnimeModel to Anime
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final animeElements = document.querySelectorAll("article.w_item_b > a");
      return animeElements.map((element) => _popularAnimeFromElement(element)).toList();
    } else {
      throw Exception('Failed to load popular anime');
    }
  }

  Anime _popularAnimeFromElement(Element element) { // Changed AnimeModel to Anime
    final titleElement = element.querySelector("div.data > h3");
    final thumbnailElement = element.querySelector("div.poster > img");

    return Anime( // Changed AnimeModel to Anime
      url: element.attributes['href'],
      title: titleElement?.text,
      thumbnailUrl: _getImageUrl(thumbnailElement),
    );
  }

  String? _getImageUrl(Element? element) {
    if (element == null) return null;
    return element.attributes['src'] ?? element.attributes['data-src'];
  }

  // =============================== Latest ===============================
  Future<List<Anime>> fetchLatestUpdates(int page) async { // Changed AnimeModel to Anime
    final latestUpdatesUrl = Uri.parse("$baseUrl/page/$page/");
    final response = await http.get(latestUpdatesUrl);

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final animeElements = document.querySelectorAll("article.w_item_b > a"); // Assuming same selector as popular
      return animeElements.map((element) => _popularAnimeFromElement(element)).toList();
    } else {
      throw Exception('Failed to load latest updates for page: $page');
    }
  }

  Future<bool> hasLatestUpdatesNextPage(int currentPage) async {
    final latestUpdatesUrl = Uri.parse("$baseUrl/page/$currentPage/");
    final response = await http.get(latestUpdatesUrl);

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final nextPageElement = document.querySelector("div.pagination > a.arrow_pag > i.icon-caret-right");
      return nextPageElement != null;
    } else {
      throw Exception('Failed to check for next page of latest updates');
    }
  }

  // =============================== Search ===============================
  Future<List<Anime>> searchAnime(String query) async { // Changed AnimeModel to Anime
    final searchUrl = Uri.parse("$baseUrl/search/$query");
    final response = await http.get(searchUrl);

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final searchResults = document.querySelectorAll("div#animation-2 > article > div.poster > a");
      return searchResults.map((element) => _popularAnimeFromElement(element)).toList();
    } else {
      throw Exception('Failed to search anime for query: $query');
    }
  }

  // =========================== Anime Details ============================
  Future<Anime> fetchAnimeDetails(String url) async { // Changed AnimeModel to Anime
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final sheader = document.querySelector("div.sheader");

      if (sheader == null) {
        throw Exception('Failed to find sheader in anime details');
      }

      final anime = Anime(); // Changed AnimeModel to Anime
      anime.url = url;

      final thumbnailElement = sheader.querySelector("div.poster > img");
      anime.thumbnailUrl = _getImageUrl(thumbnailElement);

      final titleAlt = thumbnailElement?.attributes['alt'];
      final titleH1 = sheader.querySelector("div.data > h1")?.text;
      anime.title = titleAlt?.isNotEmpty == true ? titleAlt : titleH1;

      anime.genres = sheader.querySelectorAll("div.data div.sgeneros > a")
          .map((e) => e.text)
          .toList();

      final descriptionElement = document.querySelector("div.wp-content");
      anime.description = descriptionElement?.text.trim();

      return anime;
    } else {
      throw Exception('Failed to load anime details');
    }
  }

  // ============================ Video Links =============================
  Future<List<Video>> fetchVideoLinks(String animeUrl) async { // Changed VideoModel to Video
    final response = await http.get(Uri.parse(animeUrl));
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final playerIframes = document.querySelectorAll("#playex iframe");

      final List<Future<List<Video>>> videoFutures = playerIframes.map((iframe) => _getPlayerVideos(iframe)).toList(); // Changed VideoModel to Video
      final List<List<Video>> allVideos = await Future.wait(videoFutures); // Changed VideoModel to Video

      return allVideos.expand((videos) => videos).toList(); // Flatten the list of lists
    } else {
      throw Exception('Failed to load video links');
    }
  }

  Future<List<Video>> _getPlayerVideos(Element playerIframe) async { // Changed VideoModel to Video
    final url = playerIframe.attributes['src'];
    if (url == null) return [];

    final id = playerIframe.parent?.attributes['id'];
    String language = "";
    if (id != null) {
      final languageElement = playerIframe.ownerDocument?.querySelector("a.options[href=\"#$id\"]");
      final langText = languageElement?.text?.trim();
      if (langText?.toLowerCase() == "legendado" || langText?.toLowerCase() == "dublado") {
        language = langText!;
      }
    }

    if (url.contains("blogger.com")) {
      return _extractVideosFromBlogger(url, language);
    } else {
      return [];
    }
  }

  Future<List<Video>> _extractVideosFromBlogger(String bloggerUrl, String language) async { // Changed VideoModel to Video
    final List<Video> videos = []; // Changed VideoModel to Video
    try {
      final response = await http.get(Uri.parse(bloggerUrl));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final scriptElements = document.querySelectorAll("script");

        for (final script in scriptElements) {
          final scriptContent = script.text;

          // Regex to find common video file extensions
          final videoRegex = RegExp(r"(https?:\/\/[^\s\'\\]+\.(mp4|m3u8|webm|flv|avi|mov|wmv|mkv))", caseSensitive: false);
          final matches = videoRegex.allMatches(scriptContent);

          for (final match in matches) {
            final videoUrl = match.group(1);
            if (videoUrl != null) {
              videos.add(Video(url: videoUrl, quality: "Blogger", language: language)); // Changed VideoModel to Video
            }
          }

          // Attempt to parse JSON within scripts
          try {
            final jsonRegex = RegExp(r"\{[\s\S]*\}"); // Simple regex for JSON objects
            final jsonMatches = jsonRegex.allMatches(scriptContent);
            for (final jsonMatch in jsonMatches) {
              final jsonString = jsonMatch.group(0);
              if (jsonString != null) {
                final decodedJson = jsonDecode(jsonString);
                // Look for common keys that might contain video URLs
                if (decodedJson is Map) {
                  if (decodedJson.containsKey('url') && decodedJson['url'] is String && videoRegex.hasMatch(decodedJson['url'])) {
                    videos.add(Video(url: decodedJson['url'], quality: "Blogger", language: language)); // Changed VideoModel to Video
                  }
                  if (decodedJson.containsKey('sources') && decodedJson['sources'] is List) {
                    for (final source in decodedJson['sources']) {
                      if (source is Map && source.containsKey('file') && source['file'] is String && videoRegex.hasMatch(source['file'])) {
                        videos.add(Video(url: source['file'], quality: source['label'] ?? "Blogger", language: language));
                      }
                    }
                  }
                }
              }
            }
          } catch (e) {
            // Ignore JSON parsing errors, as not all script content will be valid JSON
          }
        }
      }
    } catch (e) {
      print("Error extracting videos from Blogger: $e");
    }
    return videos;
  }

  // ============================== Filters ===============================
  Future<List<String>> fetchGenres() async {
    final genresUrl = Uri.parse("$baseUrl/generos/");
    final response = await http.get(genresUrl);

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final genreElements = document.querySelectorAll("a.genre-link");
      return genreElements.map((element) => element.text).toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }

  // ============================== Settings ============================== 
  String getPreferredLanguage() {
    return _getPreference(PREF_LANGUAGE_KEY, PREF_LANGUAGE_DEFAULT);
  }

  Future<bool> setPreferredLanguage(String language) {
    return _setPreference(PREF_LANGUAGE_KEY, language);
  }

  String getPreferredQuality() {
    return _getPreference(PREF_QUALITY_KEY, PREF_QUALITY_DEFAULT);
  }

  Future<bool> setPreferredQuality(String quality) {
    return _setPreference(PREF_QUALITY_KEY, quality);
  }

  // ============================= Utilities ============================== 
  List<Video> sortVideos(List<Video> videos) { // Changed VideoModel to Video
    final preferredLanguage = getPreferredLanguage();
    final preferredQuality = getPreferredQuality();

    videos.sort((a, b) {
      // Prioritize by language
      final langA = a.language?.toLowerCase() ?? "";
      final langB = b.language?.toLowerCase() ?? "";
      final prefLang = preferredLanguage.toLowerCase();

      final langMatchA = langA.contains(prefLang);
      final langMatchB = langB.contains(prefLang);

      if (langMatchA && !langMatchB) return -1;
      if (!langMatchA && langMatchB) return 1;

      // Prioritize by quality string match
      final qualityA = a.quality?.toLowerCase() ?? "";
      final qualityB = b.quality?.toLowerCase() ?? "";
      final prefQuality = preferredQuality.toLowerCase();

      final qualityMatchA = qualityA.contains(prefQuality);
      final qualityMatchB = qualityB.contains(prefQuality);

      if (qualityMatchA && !qualityMatchB) return -1;
      if (!qualityMatchA && qualityMatchB) return 1;

      // Prioritize by numerical quality
      final numQualityA = int.tryParse(REGEX_QUALITY.firstMatch(qualityA)?.group(1) ?? '0') ?? 0;
      final numQualityB = int.tryParse(REGEX_QUALITY.firstMatch(qualityB)?.group(1) ?? '0') ?? 0;

      return numQualityB.compareTo(numQualityA); // Descending order for numerical quality
    });

    return videos;
  }

  // Companion object constants
  static const String PREF_LANGUAGE_KEY = "preferred_language";
  static const String PREF_LANGUAGE_DEFAULT = "Legendado";
  static const String PREF_LANGUAGE_TITLE = "Língua preferida";
  static const List<String> PREF_LANGUAGE_VALUES = ["Legendado", "Dublado"];
  static const List<String> PREF_LANGUAGE_ENTRIES = PREF_LANGUAGE_VALUES;

  static const String PREF_QUALITY_KEY = "preferred_quality";
  static const String PREF_QUALITY_DEFAULT = "720p"; // Default quality

  // Regex for quality
  static final RegExp REGEX_QUALITY = RegExp(r"(\d+)p");
}