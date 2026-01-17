// lib/state/theme_state.dart
import 'package:flutter/material.dart';


class ThemeState extends ChangeNotifier {
  bool isDark = false;

  void toggle() {
    isDark = !isDark;
    notifyListeners();
  }
}

final themeState = ThemeState();

