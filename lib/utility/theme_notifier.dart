import 'package:flutter/material.dart';
import 'package:phrazy/data/web_storage/web_storage.dart';
import 'package:phrazy/utility/style.dart'; // Keep this for PhrazyColors and Style.textStyles

class PhrazyThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme;

  PhrazyThemeNotifier() : _currentTheme = PhrazyTheme.getTheme(defaultColors) {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  void _loadTheme() {
    if (WebStorage.isHighContrast) {
      _currentTheme = PhrazyTheme.getTheme(highContrastColors);
    } else {
      _currentTheme = PhrazyTheme.getTheme(defaultColors);
    }
    notifyListeners();
  }

  void toggleTheme() {
    WebStorage.toggleHighContrast();
    _loadTheme();
  }
}
