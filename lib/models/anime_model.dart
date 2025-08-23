// lib/models/anime_model.dart
import 'dart:convert';

class Anime {
  final String title;
  final String? thumbnailUrl;
  final String? bannerImageUrl;
  final String description;
  final String url;
  final String? genre;
  final int? status;
  final String? author;
  final double? score;

  Anime({
    required this.title,
    this.thumbnailUrl,
    this.bannerImageUrl,
    this.description = 'N/A',
    required this.url,
    this.genre,
    this.status,
    this.author,
    this.score,
  });

  /// Compatibilidade: usa `url` como identificador único do anime.
  String get id => url;

  /// Serializa para Map (usado por HistoryEntry.toMap(), SharedPreferences, etc.)
  Map<String, dynamic> toMap() => {
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'bannerImageUrl': bannerImageUrl,
        'description': description,
        'url': url,
        'genre': genre,
        'status': status,
        'author': author,
        'score': score,
      };

  /// Serializa para JSON (String)
  String toJson() => jsonEncode(toMap());

  /// Cria a partir de Map (quando deserializar do SharedPreferences / arquivo)
  factory Anime.fromMap(Map<String, dynamic> map) {
    double? parseScore(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      if (v is num) return v.toDouble();
      return null;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return Anime(
      title: map['title']?.toString() ?? 'N/A',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      bannerImageUrl: map['bannerImageUrl'] as String?,
      description: map['description']?.toString() ?? 'N/A',
      url: map['url']?.toString() ?? '',
      genre: map['genre'] as String?,
      status: parseInt(map['status']),
      author: map['author'] as String?,
      score: parseScore(map['score']),
    );
  }

  /// Cria a partir de JSON (String)
  factory Anime.fromJson(String source) =>
      Anime.fromMap(jsonDecode(source) as Map<String, dynamic>);

  Anime copyWith({
    String? title,
    String? thumbnailUrl,
    String? bannerImageUrl,
    String? description,
    String? url,
    String? genre,
    int? status,
    String? author,
    double? score,
  }) {
    return Anime(
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      description: description ?? this.description,
      url: url ?? this.url,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      author: author ?? this.author,
      score: score ?? this.score,
    );
  }
}
