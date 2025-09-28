import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String get backendUrl => dotenv.get('BACKEND_URL'); // Add this line
  
  static Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
  }
}