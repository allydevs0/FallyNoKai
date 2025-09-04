import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anime/models/video_model.dart';

class BloggerExtractor {
  final http.Client client;

  BloggerExtractor(this.client);

  Future<List<Video>> videosFromUrl(String url, Map<String, String> headers, {String suffix = ""}) async {
    try {
      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        return [];
      }

      final responseBody = response.body;

      if (responseBody.contains("errorContainer")) {
        return [];
      }

      // Extract the JSON-like string for streams
      final streamsStartIndex = responseBody.indexOf(r'"streams":[');
      if (streamsStartIndex == -1) {
        return [];
      }
      final streamsEndIndex = responseBody.indexOf("]", streamsStartIndex);
      if (streamsEndIndex == -1) {
        return [];
      }
      final streamsJsonString = responseBody.substring(streamsStartIndex + r'"streams":['.length, streamsEndIndex);

      final List<Video> videos = [];

      // Split by "}," and process each stream
      final streamParts = streamsJsonString.split("}, ");
      for (var i = 0; i < streamParts.length; i++) {
        var part = streamParts[i];
        if (i < streamParts.length - 1) {
          part += "}"; // Add back the closing brace for all but the last part
        }

        try {
          // Manually parse the relevant fields from the part string
          final playUrlMatch = RegExp(r'"play_url":"([^"]+)"').firstMatch(part);
          final formatIdMatch = RegExp(r'"format_id":(\d+)"').firstMatch(part);

          final videoUrl = playUrlMatch?.group(1)?.replaceAll(r'\', '');
          final formatId = formatIdMatch?.group(1);

          if (videoUrl == null || videoUrl.isEmpty) {
            continue;
          }

          String quality = "Unknown";
          switch (formatId) {
            case "7":
              quality = "240p";
              break;
            case "18":
              quality = "360p";
              break;
            case "22":
              quality = "720p";
              break;
            case "37":
              quality = "1080p";
              break;
          }

          videos.add(Video(
            url: videoUrl,
            quality: "Blogger - $quality $suffix".trim(),
            headers: headers,
          ));
        } catch (e) {
          // Log error for individual stream parsing, but continue with others
          print("Error parsing Blogger stream part: $e");
        }
      }
      return videos;
    } catch (e) {
      print("Error in BloggerExtractor: $e");
      return [];
    }
  }
}