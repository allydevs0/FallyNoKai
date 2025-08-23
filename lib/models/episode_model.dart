// lib/models/episode_model.dart
import 'dart:convert';
import 'package:anime/models/anime_model.dart';

class Episode {
  final String title;
  final String url;
  final double episodeNumber;

  // Campos opcionais para persistência / relacionamento
  final String? animeId;
  final Anime? anime;

  Episode({
    required this.title,
    required this.url,
    required this.episodeNumber,
    this.animeId,
    this.anime,
  });

  /// Identificador único (usamos a URL como id padrão)
  String get id => url;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'episodeNumber': episodeNumber,
      'animeId': animeId,
      'anime': anime?.toMap(),
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map) {
    double? parseEpisodeNumber(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      if (v is num) return v.toDouble();
      return null;
    }

    return Episode(
      title: map['title']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      episodeNumber: parseEpisodeNumber(map['episodeNumber']) ?? 0.0,
      animeId: map['animeId'] as String?,
      anime: map['anime'] != null
          ? Anime.fromMap(Map<String, dynamic>.from(map['anime'] as Map))
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Episode.fromJson(String source) =>
      Episode.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
