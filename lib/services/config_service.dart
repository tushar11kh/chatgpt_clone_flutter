import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String get perplexityApiKey => dotenv.get('PERPLEXITY_API_KEY');
  
  static Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
  }
}