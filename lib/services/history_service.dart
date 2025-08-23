// lib/services/history_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime/models/history_entry_model.dart';

class HistoryService {
  static const _historyKey = 'history';
  static const _maxHistorySize = 20; // Limit history size

  final ValueNotifier<List<HistoryEntry>> _history =
      ValueNotifier<List<HistoryEntry>>([]);

  ValueNotifier<List<HistoryEntry>> get history => _history;

  HistoryService();

  Future<void> init() async {
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getStringList(_historyKey);
    if (historyString != null) {
      _history.value = historyString
          .map((e) => HistoryEntry.fromMap(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } else {
      _history.value = [];
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = _history.value.map((e) => e.toJson()).toList();
    await prefs.setStringList(_historyKey, historyString);
  }

  // Compara duas entradas de histórico sem acessar propriedades que podem ser nulas.
  bool _isSameEntry(HistoryEntry a, HistoryEntry b) {
    final aEpisodeUrl = a.episode?.url ?? '';
    final bEpisodeUrl = b.episode?.url ?? '';
    return a.anime.url == b.anime.url && aEpisodeUrl == bEpisodeUrl;
  }

  Future<void> addOrUpdateHistoryEntry(HistoryEntry newEntry) async {
    // Remove entradas iguais (por anime + episode) antes de adicionar no topo.
    _history.value = _history.value
        .where((entry) => !_isSameEntry(entry, newEntry))
        .toList();

    // Adiciona no começo
    _history.value = [newEntry, ..._history.value];

    // Limita tamanho máximo
    if (_history.value.length > _maxHistorySize) {
      _history.value = _history.value.sublist(0, _maxHistorySize);
    }

    await _saveHistory();
  }

  Future<void> removeByEpisodeUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    _history.value = _history.value.where((e) => (e.episode?.url ?? '') != url).toList();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history.value = [];
    await _saveHistory();
  }
}
