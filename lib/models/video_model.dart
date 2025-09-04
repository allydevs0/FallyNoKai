class Video {
  String? url;
  String? quality;
  String? language;
  Map<String, String>? headers; // Added headers

  Video({
    this.url,
    this.quality,
    this.language,
    this.headers, // Added to constructor
  });

  // fromMap constructor
  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      url: map['url'] as String?,
      quality: map['quality'] as String?,
      language: map['language'] as String?,
      headers: (map['headers'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as String)),
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'quality': quality,
      'language': language,
      'headers': headers,
    };
  }

  // fromJson factory (uses fromMap)
  factory Video.fromJson(Map<String, dynamic> json) => Video.fromMap(json);

  // toJson method (uses toMap)
  Map<String, dynamic> toJson() => toMap();
}