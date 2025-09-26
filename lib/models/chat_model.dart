class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final String modelUsed;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.modelUsed = 'gpt-3.5-turbo',
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'imageUrl': imageUrl,
    'modelUsed': modelUsed,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    imageUrl: json['imageUrl'],
    modelUsed: json['modelUsed'] ?? 'gpt-3.5-turbo',
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages.map((msg) => msg.toJson()).toList(),
    'modelUsed': modelUsed,
  };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    title: json['title'],
    createdAt: DateTime.parse(json['createdAt']),
    messages: (json['messages'] as List)
        .map((msg) => ChatMessage.fromJson(msg))
        .toList(),
    modelUsed: json['modelUsed'],
  );
}