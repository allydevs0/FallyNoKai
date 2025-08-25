import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime/services/default_anime_scraper.dart';
import 'package:anime/services/animefire_source.dart';
import 'package:anime/services/goyabu_source.dart';
import 'package:anime/services/anime_source.dart';

class SourceSelectionService with ChangeNotifier {
  static const String _selectedSourceKey = 'selected_anime_source';
  late AnimeSource _selectedSource;

  SourceSelectionService() {
    _selectedSource = DefaultAnimeScraper();
    getSelectedSource().then((source) {
      _selectedSource = source;
      notifyListeners();
    });
  }

  AnimeSource get selectedSource => _selectedSource;

  Future<AnimeSource> getSelectedSource() async {
    final prefs = await SharedPreferences.getInstance();
    final sourceName = prefs.getString(_selectedSourceKey);

    switch (sourceName) {
      case "Anime Fire":
        return AnimeFireSource();
      case "Goyabu":
        return GoyabuSource();
      case "Default Anime Scraper":
      default:
        return DefaultAnimeScraper();
    }
  }

  Future<void> setSelectedSource(String sourceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSourceKey, sourceName);
    _selectedSource = await getSelectedSource();
    notifyListeners();
  }

  List<AnimeSource> getAllSources() {
    return [
      DefaultAnimeScraper(),
      AnimeFireSource(),
      GoyabuSource(),
    ];
  }
}