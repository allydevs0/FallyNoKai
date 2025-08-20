import 'dart:convert';

class Anime {
  final String title;
  final String imageUrl;
  final String description;
  final int id;

  Anime({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.id,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      title: json['title']['romaji'] ?? json['title']['english'] ?? 'N/A',
      imageUrl: json['coverImage']['large'] ?? '',
      description: json['description'] ?? 'N/A',
      id: json['id'],
    );
  }

  // For shared_preferences storage
  Map<String, dynamic> toJson() => {
        'title': {'romaji': title}, // Store as romaji for simplicity
        'coverImage': {'large': imageUrl},
        'description': description,
        'id': id,
      };

  // For shared_preferences retrieval
  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      title: map['title']['romaji'] ?? 'N/A',
      imageUrl: map['coverImage']['large'] ?? '',
      description: map['description'] ?? 'N/A',
      id: map['id'],
    );
  }
}

class Episode {
  final String title;
  final String url;

  Episode({
    required this.title,
    required this.url,
  });
}