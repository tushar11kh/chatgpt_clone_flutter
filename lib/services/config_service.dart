import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String get backendUrl => 'http://192.168.1.9:5001/api';
  
  static Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
  }
}