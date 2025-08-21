class Video {
  final String url;
  final String quality;
  final Map<String, String>? headers;

  Video({
    required this.url,
    required this.quality,
    this.headers,
  });
}
