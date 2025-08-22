
class Anime {
  final String title;
  final String? thumbnailUrl; // Changed from imageUrl
  final String? bannerImageUrl; // Added bannerImageUrl
  final String description;
  final String url; // Added url
  final String? genre;
  final int? status;
  final String? author;
  final double? score;

  Anime({
    required this.title,
    this.thumbnailUrl,
    this.bannerImageUrl, // Added to constructor
    this.description = 'N/A',
    required this.url,
    this.genre,
    this.status,
    this.author,
    this.score,
  });

  // For shared_preferences storage (adapted to new fields)
  Map<String, dynamic> toJson() => {
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'bannerImageUrl': bannerImageUrl, // Added to toJson
        'description': description,
        'url': url,
        'genre': genre,
        'status': status,
        'author': author,
        'score': score,
      };

  // For shared_preferences retrieval (adapted to new fields)
  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      title: map['title'] ?? 'N/A',
      thumbnailUrl: map['thumbnailUrl'],
      bannerImageUrl: map['bannerImageUrl'], // Added to fromMap
      description: map['description'] ?? 'N/A',
      url: map['url'] ?? '',
      genre: map['genre'],
      status: map['status'],
      author: map['author'],
      score: map['score'] as double?,
    );
  }

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
