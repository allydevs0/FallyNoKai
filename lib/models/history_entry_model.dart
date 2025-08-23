// lib/models/history_entry_model.dart
import 'dart:convert';
import 'package:anime/models/anime_model.dart';
import 'package:anime/models/episode_model.dart';

class HistoryEntry {
  final Anime anime;
  final Episode? episode;
  final Duration lastPosition;
  final DateTime lastWatched;

  HistoryEntry({
    required this.anime,
    this.episode,
    Duration? lastPosition,
    DateTime? lastWatched,
  })  : lastPosition = lastPosition ?? Duration.zero,
        lastWatched = lastWatched ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'anime': anime.toMap(),
      'episode': episode?.toMap(),
      'lastPositionMilliseconds': lastPosition.inMilliseconds,
      'lastWatchedMilliseconds': lastWatched.millisecondsSinceEpoch,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      anime: Anime.fromMap(Map<String, dynamic>.from(map['anime'] as Map)),
      episode: map['episode'] != null
          ? Episode.fromMap(Map<String, dynamic>.from(map['episode'] as Map))
          : null,
      lastPosition:
          Duration(milliseconds: (map['lastPositionMilliseconds'] ?? 0) as int),
      lastWatched: map['lastWatchedMilliseconds'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['lastWatchedMilliseconds'] as int))
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory HistoryEntry.fromJson(String source) =>
      HistoryEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
