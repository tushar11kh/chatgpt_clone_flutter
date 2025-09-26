// lib/widgets/theme_dialog.dart
import 'package:flutter/material.dart';
import 'package:chatgpt_clone/main.dart';

class ThemeDialog {
  static void show({
    required BuildContext context,
    required Color bgColor,
    required Color textColor,
  }) {
    ThemeMode currentTheme = MyApp.of(context).themeMode;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            "Choose Theme",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioOption(
                context: context,
                title: "Light",
                value: ThemeMode.light,
                groupValue: currentTheme,
                bgColor: bgColor,
                textColor: textColor,
              ),
              _buildRadioOption(
                context: context,
                title: "Dark",
                value: ThemeMode.dark,
                groupValue: currentTheme,
                bgColor: bgColor,
                textColor: textColor,
              ),
              _buildRadioOption(
                context: context,
                title: "System",
                value: ThemeMode.system,
                groupValue: currentTheme,
                bgColor: bgColor,
                textColor: textColor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildRadioOption({
    required BuildContext context,
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required Color bgColor,
    required Color textColor,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title, style: TextStyle(color: textColor)),
      value: value,
      groupValue: groupValue,
      activeColor: Colors.blue,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          MyApp.of(context).setTheme(newValue);
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Close drawer (if called from drawer)
        }
      },
    );
  }
}