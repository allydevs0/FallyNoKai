import 'video_model.dart';

class Anime {
  String? url;
  String? title;
  String? thumbnailUrl;
  String? description;
  List<String>? genres;
  List<Video>? videos;
  String? bannerImageUrl; // Added bannerImageUrl

  Anime({
    this.url,
    this.title,
    this.thumbnailUrl,
    this.description,
    this.genres,
    this.videos,
    this.bannerImageUrl, // Added to constructor
  });

  // fromMap constructor
  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      url: map['url'] as String?,
      title: map['title'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      description: map['description'] as String?,
      genres: (map['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      videos: (map['videos'] as List<dynamic>?)?.map((e) => Video.fromMap(e as Map<String, dynamic>)).toList(),
      bannerImageUrl: map['bannerImageUrl'] as String?,
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'genres': genres,
      'videos': videos?.map((e) => e.toMap()).toList(),
      'bannerImageUrl': bannerImageUrl,
    };
  }

  // fromJson factory (uses fromMap)
  factory Anime.fromJson(Map<String, dynamic> json) => Anime.fromMap(json);

  // toJson method (uses toMap)
  Map<String, dynamic> toJson() => toMap();
}