import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _fileName = 'theme_settings.json';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Get the file path for storing theme settings
  Future<File> _getThemeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Load theme preference from file
  Future<void> _loadTheme() async {
    try {
      final file = await _getThemeFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = json.decode(contents);
        _isDarkMode = data['isDarkMode'] ?? false;
      } else {
        _isDarkMode = false; // Default to light mode
      }
      notifyListeners();
    } catch (e) {
      // Handle any errors silently and keep default value
      _isDarkMode = false;
      debugPrint('Error loading theme preference: $e');
    }
  }

  // Save theme preference to file
  Future<void> _saveTheme() async {
    try {
      final file = await _getThemeFile();
      final data = {'isDarkMode': _isDarkMode};
      await file.writeAsString(json.encode(data));
    } catch (e) {
      // Handle any errors silently
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Toggle theme and save preference
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveTheme();
  }

  // Optional: Method to set theme directly
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      await _saveTheme();
    }
  }
}
