import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anime/models/anime_model.dart'; // Import the Anime model

class ApiService {
  final String _anilistApiUrl = 'https://graphql.anilist.co';

  Future<List<Anime>> searchAniListAnime(String query) async {
    final String graphqlQuery = '''
      query ({"search": String}) {
        Page (perPage: 10) {
          media (search: "$search", type: ANIME) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            description
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_anilistApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': graphqlQuery,
        'variables': {
          'search': query,
        },
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> mediaList = data['data']['Page']['media'];
      return mediaList.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load AniList anime: ${response.statusCode}');
    }
  }
}
