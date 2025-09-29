import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Add this import
import 'package:http/http.dart' as http;
import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:chatgpt_clone/services/config_service.dart';

class BackendService {
  static final String baseUrl = ConfigService.backendUrl;

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
      if (conversationId != null) request.fields['conversationId'] = conversationId;

      // Optional image
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Check if response is JSON
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        debugPrint("Non-JSON response: ${response.body}");
        throw Exception('Something went wrong. Please try again.');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'conversationId': data['conversationId'],
          'messages': data['messages'],
        };
      } else {
        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'];
          debugPrint("Backend error: $errorMessage");
          throw Exception('Failed to send message. Please try again.');
        } catch (_) {
          debugPrint("Invalid error response: ${response.body}");
          throw Exception('Failed to send message. Please try again.');
        }
      }
    } catch (e, stack) {
      debugPrint("sendMessage Exception: $e");
      debugPrint(stack.toString());
      throw Exception('Failed to send message. Please try again.');
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
        debugPrint("getAllConversations error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to load conversations. Please try again later.');
      }
    } catch (e, stack) {
      debugPrint("getAllConversations Exception: $e");
      debugPrint(stack.toString());
      throw Exception('Failed to load conversations. Please try again later.');
    }
  }

  /// Create new conversation
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
        debugPrint("createConversation error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to create conversation. Please try again later.');
      }
    } catch (e, stack) {
      debugPrint("createConversation Exception: $e");
      debugPrint(stack.toString());
      throw Exception('Failed to create conversation. Please try again later.');
    }
  }

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
        debugPrint("updateConversationTitle error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to update title. Please try again later.');
      }
    } catch (e, stack) {
      debugPrint("updateConversationTitle Exception: $e");
      debugPrint(stack.toString());
      throw Exception('Failed to update conversation title. Please try again later.');
    }
  }

  static Future<void> deleteConversation(String conversationId) async {
    try {
      var uri = Uri.parse('$baseUrl/conversation/$conversationId');
      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        debugPrint("deleteConversation error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to delete conversation. Please try again later.');
      }
    } catch (e, stack) {
      debugPrint("deleteConversation Exception: $e");
      debugPrint(stack.toString());
      throw Exception('Failed to delete conversation. Please try again later.');
    }
  }
}