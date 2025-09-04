import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService with ChangeNotifier {
  static const String _nsfwKey = 'nsfw_enabled';

  late SharedPreferences _prefs;
  bool _isNsfwEnabled = false;

  bool get isNsfwEnabled => _isNsfwEnabled;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isNsfwEnabled = _prefs.getBool(_nsfwKey) ?? false;
    notifyListeners();
  }

  set isNsfwEnabled(bool value) {
    _isNsfwEnabled = value;
    _prefs.setBool(_nsfwKey, value);
    notifyListeners();
  }
}
