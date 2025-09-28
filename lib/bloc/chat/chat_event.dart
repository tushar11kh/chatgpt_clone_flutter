import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String message;
  final String model;
  final File? imageFile;

  const SendMessage(this.message, this.model, {this.imageFile});

  @override
  List<Object?> get props => [message, model, imageFile];
}

class UpdateChat extends ChatEvent {
  final List<ChatMessage> messages; // Use ChatMessage instead of dynamic
  final String conversationId;

  const UpdateChat({
    required this.messages,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [messages, conversationId];
}

class ClearChat extends ChatEvent {
  const ClearChat();
}

// Add these events
class LoadConversations extends ChatEvent {
  const LoadConversations();
}

class SelectConversation extends ChatEvent {
  final String conversationId;
  const SelectConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class UpdateConversationTitle extends ChatEvent {
  final String conversationId;
  final String newTitle;
  
  const UpdateConversationTitle(this.conversationId, this.newTitle);

  @override
  List<Object?> get props => [conversationId, newTitle];
}