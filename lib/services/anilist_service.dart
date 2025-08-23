import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anime/models/anime_model.dart';

class AniListService {
  static const String _apiUrl = 'https://graphql.anilist.co';

  Future<List<Anime>> getTrendingAnime() async {
    const String query = r'''
      query {
        Page(perPage: 50) {
          media(sort: TRENDING_DESC, type: ANIME) {
            id
            title {
              romaji
              english
              native
            }
            bannerImage # Added bannerImage
            coverImage {
              large
            }
            averageScore
            siteUrl
            status
            genres
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> mediaList = data['data']['Page']['media'];
      return mediaList.map((json) => Anime(
        title: json['title']['romaji'] ?? json['title']['english'] ?? json['title']['native'] ?? 'N/A',
        url: json['siteUrl'] ?? '',
        thumbnailUrl: json['coverImage']['large'] ?? '',
        bannerImageUrl: json['bannerImage'] ?? '', // Added bannerImageUrl
        score: (json['averageScore'] as num?)?.toDouble(),
      )).toList();
    } else {
      throw Exception('Failed to load trending anime: ${response.statusCode}');
    }
  }
}
