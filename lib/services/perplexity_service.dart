import 'dart:convert';
import 'dart:io';
import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:chatgpt_clone/services/config_service.dart';
import 'package:perplexity_dart/perplexity_dart.dart';

class PerplexityService {
  static final PerplexityClient _client = PerplexityClient(
    apiKey: ConfigService.perplexityApiKey,
  );

  static const Map<String, PerplexityModel> _modelMap = {
    'sonar': PerplexityModel.sonar,
    'sonar-reasoning': PerplexityModel.sonarReasoning,
    'sonar-pro': PerplexityModel.sonarPro,
    'sonar-deep-research': PerplexityModel.sonarDeepResearch,
    'sonar-reasoning-pro': PerplexityModel.sonarReasoningPro,
  };

  // ---------------- Text or Image Message ----------------
  static Future<String> sendMessage({
    required String message,
    required String model,
    required List<ChatMessage> history,
    File? imageFile,
  }) async {
    try {
      final messages = _convertHistoryToMessages(history);

      // Ensure alternation: last role cannot be user
      if (messages.isEmpty || messages.last.role == MessageRole.assistant) {
        messages.add(StandardMessageModel(role: MessageRole.user, content: message));
      } else if (messages.last.role == MessageRole.user) {
        // Insert a placeholder assistant before adding the new user message
        messages.add(StandardMessageModel(role: MessageRole.assistant, content: '...'));
        messages.add(StandardMessageModel(role: MessageRole.user, content: message));
      }

      // Handle image messages
      if (imageFile != null) {
        return await _sendImageMessage(imageFile, message, model, messages);
      }

      final requestModel = ChatRequestModel(
        model: _modelMap[model] ?? PerplexityModel.sonar,
        messages: messages,
        stream: false,
        maxTokens: 2000,
        temperature: 0.7,
      );

      final response = await _client.sendMessage(requestModel: requestModel);
      return response.content ?? 'No response received';
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ---------------- Image Handling ----------------
  static Future<String> _sendImageMessage(
      File imageFile,
      String message,
      String model,
      List<StandardMessageModel> messages,
      ) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUri = 'data:image/${_getImageFormat(imageFile)};base64,$base64Image';

      final request = ChatRequestModel.defaultImageRequest(
        urlList: [dataUri],
        systemPrompt: 'Analyze the image and respond to the user\'s question.',
        imagePrompt: message,
        stream: false,
        model: _modelMap[model] ?? PerplexityModel.sonarPro,
      );

      final response = await _client.sendMessage(requestModel: request);
      return response.content ?? 'No response received';
    } catch (e) {
      throw Exception('Failed to send image message: $e');
    }
  }

  // ---------------- Image format helper ----------------
  static String _getImageFormat(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) return 'png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'jpeg';
    if (path.endsWith('.gif')) return 'gif';
    if (path.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }

  // ---------------- Convert chat history ----------------
  static List<StandardMessageModel> _convertHistoryToMessages(List<ChatMessage> history) {
    final messages = <StandardMessageModel>[];

    // Add system message first
    messages.add(StandardMessageModel(
      role: MessageRole.system,
      content: 'You are a helpful AI assistant.',
    ));

    // Convert chat history
    for (final chatMessage in history) {
      messages.add(StandardMessageModel(
        role: chatMessage.isUser ? MessageRole.user : MessageRole.assistant,
        content: chatMessage.text,
      ));
    }

    return messages;
  }

  // ---------------- Streaming support ----------------
  static Stream<String> streamMessage({
    required String message,
    required String model,
    required List<ChatMessage> history,
  }) async* {
    final messages = _convertHistoryToMessages(history);

    // Ensure alternation
    if (messages.isEmpty || messages.last.role == MessageRole.assistant) {
      messages.add(StandardMessageModel(role: MessageRole.user, content: message));
    } else if (messages.last.role == MessageRole.user) {
      messages.add(StandardMessageModel(role: MessageRole.assistant, content: '...'));
      messages.add(StandardMessageModel(role: MessageRole.user, content: message));
    }

    final requestModel = ChatRequestModel(
      model: _modelMap[model] ?? PerplexityModel.sonar,
      messages: messages,
      stream: true,
      maxTokens: 2000,
    );

    final stream = _client.streamChat(requestModel: requestModel);
    await for (final chunk in stream) {
      yield chunk; // chunk is already a String
    }
  }
}
