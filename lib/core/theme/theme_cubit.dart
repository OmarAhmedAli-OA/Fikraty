import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _themeKey = 'is_dark_mode';

  // Default to the system theme before loading preferences
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey);
    
    if (isDark == null) {
      emit(ThemeMode.system); // User hasn't chosen yet
    } else {
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    // If current state is system, check the actual brightness to toggle correctly
    final isCurrentlyDark = state == ThemeMode.dark;
    final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    
    await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
    emit(newMode);
  }
}