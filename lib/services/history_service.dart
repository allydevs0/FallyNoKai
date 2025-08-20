import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime/models/anime_model.dart';

class HistoryService {
  static const _historyKey = 'history';
  static const _maxHistorySize = 20; // Limit history size

  final ValueNotifier<List<Anime>> _history = ValueNotifier([]);

  ValueNotifier<List<Anime>> get history => _history;

  HistoryService() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getStringList(_historyKey);
    if (historyString != null) {
      _history.value = historyString
          .map((e) => Anime.fromMap(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString =
        _history.value.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, historyString);
  }

  Future<void> addAnimeToHistory(Anime anime) async {
    // Remove if already in history to move to top
    _history.value =
        _history.value.where((histAnime) => histAnime.id != anime.id).toList();

    // Add to the beginning
    _history.value = [anime, ..._history.value];

    // Trim to max size
    if (_history.value.length > _maxHistorySize) {
      _history.value = _history.value.sublist(0, _maxHistorySize);
    }
    await _saveHistory();
  }
}
