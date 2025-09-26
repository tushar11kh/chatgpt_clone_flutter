import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {
  final bool isDark;
  
  const ThemeInitial({this.isDark = false});

  @override
  List<Object?> get props => [isDark];
}