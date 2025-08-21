import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

import 'package:anime/models/anime_model.dart';
import 'package:anime/models/episode_model.dart';
import 'package:anime/models/video_model.dart';
import 'package:anime/services/anime_source.dart';

// DTOs (Data Transfer Objects)
class VideoDto {
  final String url;
  final String quality;

  VideoDto({required this.url, required this.quality});

  factory VideoDto.fromJson(Map<String, dynamic> json) {
    return VideoDto(
      url: json['src'],
      quality: json['label'],
    );
  }
}

class AFResponseDto {
  final List<VideoDto> videos;

  AFResponseDto({required this.videos});

  factory AFResponseDto.fromJson(Map<String, dynamic> json) {
    return AFResponseDto(
      videos: (json['data'] as List)
          .map((e) => VideoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Filters Data
class AFFiltersData {
  static const String IGNORE_SEARCH_MSG = "NOTA: Os filtros abaixos são IGNORADOS durante a pesquisa.";
  static const String IGNORE_SEASON_MSG = "NOTA: O filtro de gêneros IGNORA o de temporadas.";
  static const Pair<String, String> EVERY = Pair("Qualquer um", "");

  static const List<Pair<String, String>> SEASONS = [
    EVERY,
    Pair("Outono", "outono"),
    Pair("Inverno", "inverno"),
    Pair("Primavera", "primavera"),
    Pair("Verão", "verao"),
  ];

  static const List<Pair<String, String>> GENRES = [
    Pair("Ação", "acao"),
    Pair("Artes Marciais", "artes-marciais"),
    Pair("Aventura", "aventura"),
    Pair("Comédia", "comedia"),
    Pair("Demônios", "demonios"),
    Pair("Drama", "drama"),
    Pair("Ecchi", "ecchi"),
    Pair("Espaço", "espaco"),
    Pair("Esporte", "esporte"),
    Pair("Fantasia", "fantasia"),
    Pair("Ficção Científica", "ficcao-cientifica"),
    Pair("Harém", "harem"),
    Pair("Horror", "horror"),
    Pair("Jogos", "jogos"),
    Pair("Josei", "josei"),
    Pair("Magia", "magia"),
    Pair("Mecha", "mecha"),
    Pair("Militar", "militar"),
    Pair("Mistério", "misterio"),
    Pair("Musical", "musical"),
    Pair("Paródia", "parodia"),
    Pair("Psicológico", "psicologico"),
    Pair("Romance", "romance"),
    Pair("Seinen", "seinen"),
    Pair("Shoujo-ai", "shoujo-ai"),
    Pair("Shounen", "shounen"),
    Pair("Slice of Life", "slice-of-life"),
    Pair("Sobrenatural", "sobrenatural"),
    Pair("Superpoder", "superpoder"),
    Pair("Suspense", "suspense"),
    Pair("Vampiros", "vampiros"),
    Pair("Vida Escolar", "vida-escolar"),
  ];
}

// Helper for Pair (Dart doesn't have a built-in Pair like Kotlin)
class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  const Pair(this.first, this.second);
}

// Extractor classes
class AnimeFireExtractor {
  final http.Client client;

  AnimeFireExtractor(this.client);

  Future<List<Video>> videoListFromElement(Element videoElement, Map<String, String> headers) async {
    final jsonUrl = videoElement.attributes['data-video-src'];
    if (jsonUrl == null) return [];

    final response = await client.get(Uri.parse(jsonUrl), headers: headers);
    final responseDto = AFResponseDto.fromJson(json.decode(response.body));
    return responseDto.videos.map((it) {
      final url = it.url.replaceAll("\\", "");
      return Video(url: url, quality: it.quality, headers: headers);
    }).toList();
  }
}

class IframeExtractor {
  final http.Client client;

  IframeExtractor(this.client);

  Future<List<Video>> videoListFromDocument(Document doc, Map<String, String> headers) async {
    final iframeElement = doc.querySelector("div#div_video iframe");
    if (iframeElement == null) return [];

    final iframeUrl = iframeElement.attributes['src'];
    if (iframeUrl == null) return [];

    final response = await client.get(Uri.parse(iframeUrl), headers: headers);
    final url = response.body
        .substringAfter("play_url")
        .substringAfter(":\"")
        .substringBefore("\"");
    final video = Video(url: url, quality: "Default", headers: headers);
    return [video];
  }
}

// Helper extension for String (equivalent to Kotlin's substringAfter)
extension StringExtension on String {
  String substringAfter(String delimiter) {
    final index = indexOf(delimiter);
    if (index == -1) return this;
    return substring(index + delimiter.length);
  }

  String substringBefore(String delimiter) {
    final index = indexOf(delimiter);
    if (index == -1) return this;
    return substring(0, index);
  }

  String substringAfterLast(String delimiter) {
    final index = lastIndexOf(delimiter);
    if (index == -1) return this;
    return substring(index + delimiter.length);
  }

  String substringBeforeLast(String delimiter) {
    final index = lastIndexOf(delimiter);
    if (index == -1) return this;
    return substring(0, index);
  }
}

// Helper extension for Element (equivalent to Kotlin's getInfo)
extension ElementExtension on Element {
  String? getInfo(String key) {
    // Select all div.animeInfo elements and find the one that contains the key text
    final infoElement = querySelectorAll("div.animeInfo").firstWhereOrNull(
      (element) => element.text.contains(key),
    );
    return infoElement?.querySelector("span")?.text;
  }
}

// Helper extension for Iterable (to mimic Kotlin's firstWhereOrNull)
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Main AnimeFireSource class
class AnimeFireSource implements AnimeSource {
  @override
  final String name = "Anime Fire";
  @override
  final String baseUrl = "https://animefire.plus";
  @override
  final bool supportsLatest = true;

  final http.Client _client = http.Client();
  late final AnimeFireExtractor _animeFireExtractor = AnimeFireExtractor(_client);
  late final IframeExtractor _iframeExtractor = IframeExtractor(_client);

  Map<String, String> get _headers => {
        "Referer": baseUrl,
        "Accept-Language": "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7",
      };

  @override
  Future<List<Anime>> fetchPopularAnime(int page) async {
    final response = await _client.get(Uri.parse("$baseUrl/top-animes/$page"), headers: _headers);
    final document = html_parser.parse(response.body);
    return _parseAnimeList(document);
  }

  @override
  Future<List<Anime>> fetchLatestUpdates(int page) async {
    final response = await _client.get(Uri.parse("$baseUrl/home/$page"), headers: _headers);
    final document = html_parser.parse(response.body);
    return _parseAnimeList(document);
  }

  List<Anime> _parseAnimeList(Document document) {
    final animeElements = document.querySelectorAll("article.cardUltimosEps > a");
    return animeElements.map((element) {
      final url = element.attributes['href']!;
      String animeUrl;
      final lastSegment = url.substringAfterLast("/"); // Use extension
      if (int.tryParse(lastSegment) != null) {
        final substr = url.substringBeforeLast("/"); // Use extension
        animeUrl = "$substr-todos-os-episodios";
      } else {
        animeUrl = url;
      }

      return Anime(
        title: element.querySelector("h3.animeTitle")!.text,
        thumbnailUrl: element.querySelector("img")?.attributes['data-src'],
        url: animeUrl,
      );
    }).toList();
  }

  @override
  Future<List<Anime>> searchAnime(int page, String query, List<dynamic> filters) async {
    // Filters are not yet implemented in Dart, so we'll ignore them for now
    // and focus on the query.
    final fixedQuery = query.trim().replaceAll(" ", "-").toLowerCase();
    final response = await _client.get(Uri.parse("$baseUrl/pesquisar/$fixedQuery/$page"), headers: _headers);
    final document = html_parser.parse(response.body);
    return _parseAnimeList(document);
  }

  @override
  Future<Anime> fetchAnimeDetails(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers);
    final document = html_parser.parse(response.body);

    final content = document.querySelector("div.divDivAnimeInfo")!;
    final names = content.querySelector("div.div_anime_names")!;
    final infos = content.querySelector("div.divAnimePageInfo")!;

    final description = StringBuffer();
    if (content.querySelector("div.divSinopse > span") != null) {
      description.writeln(content.querySelector("div.divSinopse > span")!.text);
    }
    if (names.querySelector("h6") != null) {
      description.writeln('\nNome alternativo: ${names.querySelector("h6")!.text}');
    }
    if (infos.getInfo("Dia de") != null) {
      description.writeln('\nDia de lançamento: ${infos.getInfo("Dia de")!}');
    }
    if (infos.getInfo("Áudio") != null) {
      description.writeln('\nTipo: ${infos.getInfo("Áudio")!}');
    }
    if (infos.getInfo("Ano") != null) {
      description.writeln('\nAno: ${infos.getInfo("Ano")!}');
    }
    if (infos.getInfo("Episódios") != null) {
      description.writeln('\nEpisódios: ${infos.getInfo("Episódios")!}');
    }
    if (infos.getInfo("Temporada") != null) {
      description.writeln('\nTemporada: ${infos.getInfo("Temporada")!}');
    }

    return Anime(
      title: names.querySelector("h1")!.text,
      thumbnailUrl: content.querySelector("div.sub_animepage_img > img")?.attributes['data-src'],
      url: url,
      genre: infos.querySelectorAll("a.spanGeneros").map((e) => e.text).join(", "),
      status: _parseStatus(infos.getInfo("Status")),
      description: description.toString(),
      author: infos.getInfo("Estúdios"),
    );
  }

  int _parseStatus(String? statusString) {
    switch (statusString?.trim()) {
      case "Completo":
        return 1; // SAnime.COMPLETED equivalent
      case "Em lançamento":
        return 0; // SAnime.ONGOING equivalent
      default:
        return 2; // SAnime.UNKNOWN equivalent
    }
  }

  @override
  Future<List<Episode>> fetchEpisodeList(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers);
    final document = html_parser.parse(response.body);
    final episodeElements = document.querySelectorAll("div.div_video_list > a");

    return episodeElements.map((element) {
      final episodeUrl = element.attributes['href']!;
      final episodeNumber = double.tryParse(episodeUrl.substringAfterLast("/")) ?? 0.0;
      return Episode(
        title: element.text,
        url: episodeUrl,
        episodeNumber: episodeNumber,
      );
    }).toList().reversed.toList(); // Reversed as in Kotlin
  }

  @override
  Future<List<Video>> fetchVideoList(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers);
    final document = html_parser.parse(response.body);

    final videoElement = document.querySelector("video#my-video");
    if (videoElement != null) {
      return await _animeFireExtractor.videoListFromElement(videoElement, _headers);
    } else {
      return await _iframeExtractor.videoListFromDocument(document, _headers);
    }
  }
}
