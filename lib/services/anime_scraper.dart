import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class AnimeScraper {
  final String baseUrl = 'https://animefire.plus/';

  Future<List<Map<String, String>>> searchAnime(String query) async {
    // This search URL and selectors are a guess and might need adjustment
    final searchUrl = Uri.parse('$baseUrl/pesquisar/$query');
    final response = await http.get(searchUrl);

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final List<Map<String, String>> results = [];

      // Assuming a common structure for search results
      final animeElements = document.querySelectorAll('div.card-anime'); // Common selector for anime cards
      for (var element in animeElements) {
        final titleElement = element.querySelector('h3.anime-title a'); // Common selector for title
        final urlElement = element.querySelector('a'); // The main link for the anime card

        if (titleElement != null && urlElement != null) {
          final title = titleElement.text.trim();
          final url = urlElement.attributes['href'];
          if (url != null) {
            results.add({'title': title, 'url': url});
          }
        }
      }
      return results;
    } else {
      throw Exception('Failed to load search results: ${response.statusCode}');
    }
  }

  Future<List<Map<String, String>>> getEpisodes(String animeUrl) async {
    final response = await http.get(Uri.parse(animeUrl));

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final List<Map<String, String>> episodes = [];

      // Find all <a> tags and filter based on href containing /hd/ or /sd/
      final downloadLinks = document.querySelectorAll('a');
      for (var link in downloadLinks) {
        final href = link.attributes['href'];
        if (href != null && (href.contains('/hd/') || href.contains('/sd/'))) {
          // Extract episode title from the link's text or surrounding elements
          // This part might need further refinement based on actual HTML structure
          final title = link.text.trim().isNotEmpty ? link.text.trim() : 'Episode Link'; // Placeholder title
          episodes.add({'title': title, 'url': href});
        }
      }
      return episodes;
    } else {
      throw Exception('Failed to load episodes: ${response.statusCode}');
    }
  }
}
