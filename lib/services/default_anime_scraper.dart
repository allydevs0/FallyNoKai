import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import 'package:anime/models/anime_model.dart';
import 'package:anime/models/episode_model.dart';
import 'package:anime/models/video_model.dart';
import 'package:anime/services/anime_source.dart';

class DefaultAnimeScraper implements AnimeSource {
  @override
  final String name = "Default Anime Scraper";
  @override
  final String baseUrl = 'https://animefire.plus'; // Corrigindo para HTTPS
  @override
  final bool supportsLatest = false; // Default scraper doesn't support latest updates directly

  final http.Client _client = http.Client(); // Use default client, no SSL bypass

  // Helper for parsing status
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
  Future<List<Anime>> fetchPopularAnime(int page) async {
    // Default scraper doesn't have a direct "popular" endpoint,
    // so we'll return an empty list or throw an error.
    // For now, returning empty list.
    return [];
  }

  @override
  Future<List<Anime>> fetchLatestUpdates(int page) async {
    // Default scraper doesn't have a direct "latest updates" endpoint,
    // so we'll return an empty list or throw an error.
    // For now, returning empty list.
    return [];
  }

  @override
  Future<List<Anime>> searchAnime(int page, String query, List<dynamic> filters) async {
    // Baseado na implementação Kotlin do AnimeFire
    final fixedQuery = query.trim().replaceAll(" ", "-").toLowerCase();
    final searchUrl = '$baseUrl/pesquisar/$fixedQuery/$page';
    
    print("🔍 DefaultAnimeScraper: Fazendo pesquisa em $searchUrl");
    
    try {
      final response = await _client.get(Uri.parse(searchUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': baseUrl,
        'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
      });

      print("📡 Status da resposta: ${response.statusCode}");
      print("📄 Tamanho da resposta: ${response.body.length} caracteres");

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final List<Anime> results = [];

        // Debug: Vamos ver o que tem no HTML
        print("🔍 Analisando HTML...");
        print("📄 Primeiros 500 caracteres: ${response.body.substring(0, 500)}");
        
        // Usar o seletor correto baseado na implementação Kotlin
        final List<Element> animeElements = document.querySelectorAll('article.cardUltimosEps > a').map((e) => e).toList();
        print("🎬 Elementos encontrados com 'article.cardUltimosEps > a': ${animeElements.length}");
        
        // Se não encontrar nada, tentar alternativas
        if (animeElements.isEmpty) {
          final List<Element> altElements1 = document.querySelectorAll('article.cardUltimosEps a').map((e) => e).toList();
          final List<Element> altElements2 = document.querySelectorAll('.cardUltimosEps a').map((e) => e).toList();
          final List<Element> altElements3 = document.querySelectorAll('article a').map((e) => e).toList();
          final List<Element> altElements4 = document.querySelectorAll('a[href*="/anime/"]').map((e) => e).toList();
          
          print("🎬 Alternativa 1 - article.cardUltimosEps a: ${altElements1.length}");
          print("🎬 Alternativa 2 - .cardUltimosEps a: ${altElements2.length}");
          print("🎬 Alternativa 3 - article a: ${altElements3.length}");
          print("🎬 Alternativa 4 - a[href*='/anime/']: ${altElements4.length}");
          
          // Usar a alternativa que funcionar
          final List<Element> workingElements = altElements1.isNotEmpty ? altElements1 :
                                              altElements2.isNotEmpty ? altElements2 :
                                              altElements3.isNotEmpty ? altElements3 :
                                              altElements4.isNotEmpty ? altElements4 : <Element>[];
          
          if (workingElements.isNotEmpty) {
            print("✅ Usando elementos alternativos: ${workingElements.length}");
            return _parseAnimeElements(workingElements);
          }
        }
        
        return _parseAnimeElements(animeElements);
      } else {
        print("❌ Erro HTTP: ${response.statusCode}");
        throw Exception('Failed to load search results: ${response.statusCode}');
      }
    } catch (e) {
      print("💥 Erro na pesquisa: $e");
      rethrow;
    }
  }

  List<Anime> _parseAnimeElements(List<Element> elements) {
    final List<Anime> results = [];
    
    for (var element in elements) {
      try {
        final url = element.attributes['href'] ?? '';
        final titleElement = element.querySelector('h3.animeTitle, h3, h2, .title, .name');
        final imgElement = element.querySelector('img');
        
        String title = '';
        String imgUrl = '';
        
        if (titleElement != null) {
          title = titleElement.text.trim();
        } else {
          // Se não encontrar título específico, usar o texto do elemento
          title = element.text.trim();
        }
        
        if (imgElement != null) {
          imgUrl = imgElement.attributes['data-src'] ?? 
                   imgElement.attributes['src'] ?? '';
        }
        
        print("🔍 Analisando elemento: tag=${element.localName ?? 'unknown'}, title='$title', url='$url'");

        if (url.isNotEmpty && title.isNotEmpty) {
          // Limpar a URL se necessário
          String finalUrl = url;
          if (url.startsWith('/')) {
            finalUrl = '$baseUrl$url';
          }
          
          // Converter URL de episódio para URL de anime (baseado na implementação Kotlin)
          if (url.contains('/episodio/')) {
            final substr = url.substring(0, url.lastIndexOf('/'));
            finalUrl = '$baseUrl$substr-todos-os-episodios';
          }
          
          print("📺 Anime encontrado: $title - $finalUrl");
          results.add(Anime(
            title: title,
            url: finalUrl,
            thumbnailUrl: imgUrl,
          ));
        }
      } catch (e) {
        print("⚠️ Erro ao processar elemento: $e");
        continue;
      }
    }
    
    print("✅ Total de animes retornados: ${results.length}");
    return results;
  }

  @override
  Future<Anime> fetchAnimeDetails(String animeUrl) async {
    print("🔍 Buscando detalhes do anime: $animeUrl");
    
    try {
      final response = await _client.get(Uri.parse(animeUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
      });

      if (response.statusCode == 200) {
        final document = parse(response.body);
        
        // Usar os seletores corretos baseados na implementação Kotlin
        final content = document.querySelector('div.divDivAnimeInfo');
        if (content == null) {
          throw Exception('Não foi possível encontrar as informações do anime');
        }
        
        final names = content.querySelector('div.div_anime_names');
        final infos = content.querySelector('div.divAnimePageInfo');
        
        if (names == null) {
          throw Exception('Não foi possível encontrar o nome do anime');
        }
        
        // Extrair título
        final titleElement = names.querySelector('h1');
        final title = titleElement?.text.trim() ?? 'Título não encontrado';
        
        // Extrair imagem
        final imgElement = content.querySelector('div.sub_animepage_img > img');
        final imageUrl = imgElement?.attributes['data-src'] ?? 
                        imgElement?.attributes['src'] ?? '';
        
        // Extrair gêneros
        String genre = '';
        if (infos != null) {
          final genreElements = infos.querySelectorAll('a.spanGeneros');
          genre = genreElements.map((e) => e.text.trim()).join(', ');
        }
        
        // Extrair descrição
        final descriptionBuffer = StringBuffer();
        final sinopseElement = content.querySelector('div.divSinopse > span');
        if (sinopseElement != null) {
          descriptionBuffer.writeln(sinopseElement.text.trim());
        }
        
        if (names.querySelector('h6') != null) {
          descriptionBuffer.writeln('\nNome alternativo: ${names.querySelector('h6')!.text.trim()}');
        }
        
        if (infos != null) {
          final diaLancamento = _getInfo(infos, 'Dia de');
          final audio = _getInfo(infos, 'Áudio');
          final ano = _getInfo(infos, 'Ano');
          final episodios = _getInfo(infos, 'Episódios');
          final temporada = _getInfo(infos, 'Temporada');
          
          if (diaLancamento != null) {
            descriptionBuffer.writeln('\nDia de lançamento: $diaLancamento');
          }
          if (audio != null) {
            descriptionBuffer.writeln('\nTipo: $audio');
          }
          if (ano != null) {
            descriptionBuffer.writeln('\nAno: $ano');
          }
          if (episodios != null) {
            descriptionBuffer.writeln('\nEpisódios: $episodios');
          }
          if (temporada != null) {
            descriptionBuffer.writeln('\nTemporada: $temporada');
          }
        }
        
        final description = descriptionBuffer.toString().trim();
        
        print("✅ Detalhes extraídos: $title");
        
        return Anime(
          title: title,
          thumbnailUrl: imageUrl,
          description: description,
          url: animeUrl,
          genre: genre.isNotEmpty ? genre : null,
        );
      } else {
        throw Exception('Failed to load anime details: ${response.statusCode}');
      }
    } catch (e) {
      print("💥 Erro ao buscar detalhes do anime: $e");
      rethrow;
    }
  }
  
  String? _getInfo(Element element, String key) {
    // Buscar por elementos que contenham o texto da chave
    final allDivs = element.querySelectorAll('div.animeInfo');
    for (var div in allDivs) {
      final text = div.text.trim();
      if (text.contains(key)) {
        final span = div.querySelector('span');
        return span?.text.trim();
      }
    }
    return null;
  }

  @override
  Future<List<Episode>> fetchEpisodeList(String url) async {
    print("🔍 Buscando lista de episódios: $url");
    
    try {
      final response = await _client.get(Uri.parse(url), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
      });

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final List<Episode> episodes = [];

        // Usar o seletor correto baseado na implementação Kotlin
        final episodeElements = document.querySelectorAll('div.div_video_list > a');
        print("🎬 Episódios encontrados: ${episodeElements.length}");

        for (var element in episodeElements) {
          try {
            final episodeUrl = element.attributes['href'] ?? '';
            final episodeName = element.text.trim();
            
            // Extrair número do episódio da URL
            double episodeNumber = 0.0;
            try {
              final lastSlashIndex = episodeUrl.lastIndexOf('/');
              final episodeStr = lastSlashIndex >= 0 ? episodeUrl.substring(lastSlashIndex + 1) : '';
              episodeNumber = double.tryParse(episodeStr) ?? 0.0;
            } catch (e) {
              print("⚠️ Erro ao extrair número do episódio: $e");
            }

            if (episodeUrl.isNotEmpty && episodeName.isNotEmpty) {
              // Limpar a URL se necessário
              String finalUrl = episodeUrl;
              if (episodeUrl.startsWith('/')) {
                finalUrl = '$baseUrl$episodeUrl';
              }
              
              print("📺 Episódio encontrado: $episodeName - $finalUrl");
              episodes.add(Episode(
                title: episodeName,
                url: finalUrl,
                episodeNumber: episodeNumber,
              ));
            }
          } catch (e) {
            print("⚠️ Erro ao processar episódio: $e");
            continue;
          }
        }

        // Reverter a lista como na implementação Kotlin
        final reversedEpisodes = episodes.reversed.toList();
        print("✅ Total de episódios retornados: ${reversedEpisodes.length}");
        return reversedEpisodes;
      } else {
        throw Exception('Failed to load episode list: ${response.statusCode}');
      }
    } catch (e) {
      print("💥 Erro ao buscar lista de episódios: $e");
      rethrow;
    }
  }

  @override
  Future<List<Video>> fetchVideoList(String episodeUrl) async {
    print("🎬 Buscando links de vídeo para: $episodeUrl");
    
    try {
      final response = await _client.get(Uri.parse(episodeUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
      });

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final List<Video> videos = [];

        // Tentar encontrar vídeo direto primeiro
        final videoElement = document.querySelector('video#my-video');
        if (videoElement != null) {
          print("🎥 Vídeo direto encontrado");
          final videoSrc = videoElement.attributes['data-video-src'];
          if (videoSrc != null) {
            try {
              // Fazer requisição para obter os links de vídeo
              final videoResponse = await _client.get(Uri.parse(videoSrc), headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                'Referer': episodeUrl,
              });
              
              if (videoResponse.statusCode == 200) {
                final videoData = jsonDecode(videoResponse.body);
                if (videoData['data'] != null) {
                  final videoList = videoData['data'] as List;
                  for (var video in videoList) {
                    final url = (video['src'] as String).replaceAll('\\', '');
                    final quality = video['label'] ?? 'Unknown';
                    videos.add(Video(
                      url: url,
                      quality: quality,
                      headers: {'Referer': episodeUrl},
                    ));
                    print("🎬 Vídeo encontrado: $quality - $url");
                  }
                }
              }
            } catch (e) {
              print("⚠️ Erro ao processar vídeo direto: $e");
            }
          }
        }

        // Se não encontrou vídeo direto, tentar iframe
        if (videos.isEmpty) {
          print("🔍 Tentando encontrar iframe...");
          final iframeElements = document.querySelectorAll('iframe');
          for (var iframe in iframeElements) {
            final src = iframe.attributes['src'];
            if (src != null && src.isNotEmpty) {
              try {
                final iframeResponse = await _client.get(Uri.parse(src), headers: {
                  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                  'Referer': episodeUrl,
                });
                
                if (iframeResponse.statusCode == 200) {
                  final iframeDoc = parse(iframeResponse.body);
                  final iframeVideo = iframeDoc.querySelector('video source');
                  if (iframeVideo != null) {
                    final videoUrl = iframeVideo.attributes['src'];
                    if (videoUrl != null) {
                      videos.add(Video(
                        url: videoUrl,
                        quality: 'Default',
                        headers: {'Referer': src},
                      ));
                      print("🎬 Vídeo em iframe encontrado: $videoUrl");
                    }
                  }
                }
              } catch (e) {
                print("⚠️ Erro ao processar iframe: $e");
              }
            }
          }
        }

        // Se ainda não encontrou, tentar links de download
        if (videos.isEmpty) {
          print("🔍 Tentando encontrar links de download...");
          final downloadElements = document.querySelectorAll('a[href*=".mp4"], a[href*=".m3u8"]');
          for (var link in downloadElements) {
            final url = link.attributes['href'];
            final title = link.text.trim();
            if (url != null && url.isNotEmpty) {
              videos.add(Video(
                url: url.startsWith('http') ? url : '$baseUrl$url',
                quality: title.isNotEmpty ? title : 'Download',
                headers: {'Referer': episodeUrl},
              ));
              print("🎬 Link de download encontrado: $title - $url");
            }
          }
        }

        // Ordenar por qualidade (720p primeiro, depois 360p)
        videos.sort((a, b) {
          if (a.quality.contains('720p')) return -1;
          if (b.quality.contains('720p')) return 1;
          if (a.quality.contains('360p')) return -1;
          if (b.quality.contains('360p')) return 1;
          return 0;
        });

        print("✅ Total de vídeos encontrados: ${videos.length}");
        return videos;
      } else {
        throw Exception('Failed to load video links: ${response.statusCode}');
      }
    } catch (e) {
      print("💥 Erro ao buscar links de vídeo: $e");
      rethrow;
    }
  }
}
