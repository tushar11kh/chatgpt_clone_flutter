import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:chatgpt_clone/services/config_service.dart';

class BackendService {
  static final String baseUrl =
      ConfigService.backendUrl; // e.g., http://localhost:3000/api

  /// Send a chat message (text + optional image) to backend
  static Future<Map<String, dynamic>> sendMessage({
    required String text,
    required String model,
    required List<ChatMessage> history,
    String? conversationId,
    File? imageFile,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/chat');
      var request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['text'] = text;
      request.fields['modelUsed'] = model;
      if (conversationId != null)
        request.fields['conversationId'] = conversationId;

      // Optional image
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'conversationId': data['conversationId'],
          'messages': data['messages'],
        };
      } else {
        throw Exception('Backend error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Fetch all past conversations
  static Future<List<dynamic>> getAllConversations() async {
    try {
      var uri = Uri.parse('$baseUrl/conversations');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch conversations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  /// Create new conversation (optional)
  static Future<Map<String, dynamic>> createConversation({
    required String title,
    required String model,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/conversation');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'messages': [], 'modelUsed': model}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['conversation'];
      } else {
        throw Exception('Failed to create conversation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Add to backend_service.dart
  static Future<void> updateConversationTitle({
    required String conversationId,
    required String newTitle,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/conversation/$conversationId');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': newTitle}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update title: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update conversation title: $e');
    }
  }

  static Future<void> deleteConversation(String conversationId) async {
    try {
      var uri = Uri.parse('$baseUrl/conversation/$conversationId');
      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete conversation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }
}
