import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';

class ApiService {
  static const String baseUrl = 'YOUR_BACKEND_URL'; // Replace with your backend URL
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY'; // Should be in backend

  // Send message to OpenAI via backend
  static Future<String> sendMessage({
    required String message,
    required String model,
    required List<ChatMessage> history,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'model': model,
          'history': history.map((msg) => msg.toJson()).toList(),
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload image to backend (which will upload to Cloudinary)
  static Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return data['imageUrl'];
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // Save conversation to backend
  static Future<void> saveConversation(Conversation conversation) async {
    await http.post(
      Uri.parse('$baseUrl/api/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(conversation.toJson()),
    );
  }

  // Load conversations from backend
  static Future<List<Conversation>> loadConversations() async {
    final response = await http.get(Uri.parse('$baseUrl/api/conversations'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((conv) => Conversation.fromJson(conv)).toList();
    }
    return [];
  }
}