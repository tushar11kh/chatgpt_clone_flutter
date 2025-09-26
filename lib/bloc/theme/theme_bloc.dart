import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'is_dark_theme';

  ThemeBloc() : super(ThemeInitial()) {
    on<ChangeTheme>(_onChangeTheme);
    _loadSavedTheme();
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    emit(ThemeInitial(isDark: event.isDark));
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, event.isDark);
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(ThemeInitial(isDark: isDark));
  }
}