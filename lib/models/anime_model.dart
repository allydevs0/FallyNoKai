
class Anime {
  final String title;
  final String? thumbnailUrl; // Changed from imageUrl
  final String description;
  final String url; // Added url
  final String? genre;
  final int? status;
  final String? author;

  Anime({
    required this.title,
    this.thumbnailUrl,
    this.description = 'N/A',
    required this.url,
    this.genre,
    this.status,
    this.author,
  });

  // For shared_preferences storage (adapted to new fields)
  Map<String, dynamic> toJson() => {
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'description': description,
        'url': url,
        'genre': genre,
        'status': status,
        'author': author,
      };

  // For shared_preferences retrieval (adapted to new fields)
  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      title: map['title'] ?? 'N/A',
      thumbnailUrl: map['thumbnailUrl'],
      description: map['description'] ?? 'N/A',
      url: map['url'] ?? '',
      genre: map['genre'],
      status: map['status'],
      author: map['author'],
    );
  }
}
