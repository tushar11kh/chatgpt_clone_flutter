import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';

class ThemeDialog {
  static void show({
    required BuildContext context,
    required Color bgColor,
    required Color textColor,
  }) {
    final themeBloc = BlocProvider.of<ThemeBloc>(context);

    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: themeBloc,
        child: AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            "Choose Theme",
            style: TextStyle(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Light Mode", style: TextStyle(color: textColor)),
                leading: Icon(Icons.light_mode, color: textColor),
                onTap: () {
                  themeBloc.add(ChangeTheme(false));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("Dark Mode", style: TextStyle(color: textColor)),
                leading: Icon(Icons.dark_mode, color: textColor),
                onTap: () {
                  themeBloc.add(ChangeTheme(true));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}