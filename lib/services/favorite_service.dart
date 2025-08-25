import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime/models/anime_model.dart';

class FavoriteService {
  static const _favoritesKey = 'favorites';

  final ValueNotifier<List<Anime>> _favorites = ValueNotifier([]);

  ValueNotifier<List<Anime>> get favorites => _favorites;

  FavoriteService();

  Future<void> init() async {
    await clearFavorites(); // TODO: Remove this after one run
    await _loadFavorites();
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
    _favorites.value = [];
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getStringList(_favoritesKey);
    if (favoritesString != null) {
      _favorites.value = favoritesString
          .map((e) => Anime.fromJson(jsonDecode(e) as Map<String, dynamic>)) // Fixed
          .toList();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString =
        _favorites.value.map((e) => jsonEncode(e.toJson())).toList(); // Fixed
    await prefs.setStringList(_favoritesKey, favoritesString);
  }

  bool isFavorite(Anime anime) {
    return _favorites.value.any((favAnime) => favAnime.url == anime.url);
  }

  Future<void> toggleFavorite(Anime anime) async {
    if (isFavorite(anime)) {
      _favorites.value =
          _favorites.value.where((favAnime) => favAnime.url != anime.url).toList();
    } else {
      _favorites.value = [..._favorites.value, anime];
    }
    await _saveFavorites();
  }
}