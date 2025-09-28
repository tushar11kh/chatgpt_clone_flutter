import 'package:flutter/material.dart';

class AppColors {
  // Only the colors actually used in home_screen.dart
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Colors.black;
  
  static const Color lightPrimaryText = Colors.black;
  static const Color darkPrimaryText = Colors.white;
  
  static const Color lightChatBackground = Color.fromARGB(255, 238, 238, 238); // grey[200]
  static const Color darkChatBackground = Color.fromARGB(255, 33, 33, 33); // grey[900]
  
  static const Color lightInputBackground = Color.fromARGB(255, 224, 224, 224); // grey[300]
  static const Color darkInputBackground = Color.fromARGB(255, 48, 48, 48); // grey[850]
}

// Simple helper method to get colors based on brightness
Color getBackgroundColor(Brightness brightness) {
  return brightness == Brightness.dark 
      ? AppColors.darkBackground 
      : AppColors.lightBackground;
}

Color getPrimaryTextColor(Brightness brightness) {
  return brightness == Brightness.dark 
      ? AppColors.darkPrimaryText 
      : AppColors.lightPrimaryText;
}

Color getChatBackgroundColor(Brightness brightness) {
  return brightness == Brightness.dark 
      ? AppColors.darkChatBackground 
      : AppColors.lightChatBackground;
}

Color getInputBackgroundColor(Brightness brightness) {
  return brightness == Brightness.dark 
      ? AppColors.darkInputBackground 
      : AppColors.lightInputBackground;
}