class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final List<String>? images; // supports multiple AI images
  final String modelUsed;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.images,
    required this.modelUsed,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'imageUrl': imageUrl,
        'images': images,
        'modelUsed': modelUsed,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] ?? '',
        isUser: json['isUser'] ?? false,
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        imageUrl: json['imageUrl'],
        images: json['images'] != null ? List<String>.from(json['images']) : null,
        modelUsed: json['modelUsed'] ?? 'sonar',
      );
}

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;
  final String modelUsed;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
    required this.modelUsed,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['_id'] ?? json['id'] ?? '',
    title: json['title'] ?? 'Untitled',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    messages: (json['messages'] as List<dynamic>?)
        ?.map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
        .toList() ?? [],
    modelUsed: json['modelUsed'] ?? 'sonar',
  );
}