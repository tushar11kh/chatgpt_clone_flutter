import 'package:chatgpt_clone/bloc/theme/theme_state.dart';
import 'package:chatgpt_clone/services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'bloc/chat/chat_bloc.dart';
import 'bloc/theme/theme_bloc.dart';
import 'bloc/model/model_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.loadEnv();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => ModelBloc()),
        BlocProvider(create: (context) => ChatBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState is ThemeInitial ? themeState.isDark : false;
          
          return MaterialApp(
            title: 'ChatGPT Clone',
            theme: isDark ? ThemeData.dark() : ThemeData.light(),
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}