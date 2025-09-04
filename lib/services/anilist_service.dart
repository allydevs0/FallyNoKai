import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:anime/models/anime_model.dart';
import 'package:anime/services/settings_service.dart';

class AniListService {
  static const String _apiUrl = 'https://graphql.anilist.co';
  final SettingsService _settingsService;

  AniListService(this._settingsService);

  Future<List<Anime>> getTrendingAnime() async {
    const String query = r'''
      query ($isAdult: Boolean) {
        Page(perPage: 50) {
          media(sort: TRENDING_DESC, type: ANIME, isAdult: $isAdult) {
            id
            title {
              romaji
              english
              native
            }
            bannerImage
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
    return _fetchAnimeList(query);
  }

  Future<List<Anime>> getPopularAnime() async {
    const String query = r'''
      query ($isAdult: Boolean) {
        Page(perPage: 50) {
          media(sort: POPULARITY_DESC, type: ANIME, isAdult: $isAdult) {
            id
            title {
              romaji
              english
              native
            }
            bannerImage
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
    return _fetchAnimeList(query);
  }

  Future<List<Anime>> getLatestUpdates() async {
    const String query = r'''
      query ($isAdult: Boolean) {
        Page(perPage: 50) {
          media(sort: UPDATED_AT_DESC, type: ANIME, isAdult: $isAdult) {
            id
            title {
              romaji
              english
              native
            }
            bannerImage
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
    return _fetchAnimeList(query);
  }

  Future<List<Anime>> _fetchAnimeList(String query) async {
    final variables = {'isAdult': _settingsService.isNsfwEnabled};

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        if (kDebugMode) {
          print(data['errors']);
        }
        throw Exception('Failed to load anime list: ${data['errors'][0]['message']}');
      }
      final List<dynamic> mediaList = data['data']['Page']['media'];
      return mediaList.map((json) => Anime(
        title: json['title']['romaji'] ?? json['title']['english'] ?? json['title']['native'] ?? 'N/A',
        url: json['siteUrl'] ?? '',
        thumbnailUrl: json['coverImage']['large'] ?? '',
        bannerImageUrl: json['bannerImage'] ?? '',
        genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      )).toList().cast<Anime>();
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      throw Exception('Failed to load anime list: ${response.statusCode}');
    }
  }
}