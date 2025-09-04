
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSelectionService extends ChangeNotifier {
  static const _playerKey = 'selected_player';
  String _selectedPlayer = 'native';

  String get selectedPlayer => _selectedPlayer;

  PlayerSelectionService() {
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedPlayer = prefs.getString(_playerKey) ?? 'native';
    notifyListeners();
  }

  Future<void> setPlayer(String player) async {
    _selectedPlayer = player;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerKey, player);
    notifyListeners();
  }
}
