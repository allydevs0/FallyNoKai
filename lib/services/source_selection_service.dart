import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime/services/default_anime_scraper.dart';
import 'package:anime/services/animefire_source.dart';
import 'package:anime/services/anime_source.dart';

class SourceSelectionService {
  static const String _selectedSourceKey = 'selected_anime_source';

  Future<AnimeSource> getSelectedSource() async {
    final prefs = await SharedPreferences.getInstance();
    final sourceName = prefs.getString(_selectedSourceKey);

    switch (sourceName) {
      case "Anime Fire":
        return AnimeFireSource();
      case "Default Anime Scraper":
      default:
        return DefaultAnimeScraper();
    }
  }

  Future<void> setSelectedSource(String sourceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSourceKey, sourceName);
  }

  List<AnimeSource> getAllSources() {
    return [
      DefaultAnimeScraper(),
      AnimeFireSource(),
    ];
  }
}
