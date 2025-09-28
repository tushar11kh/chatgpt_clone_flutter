import 'package:equatable/equatable.dart';
import '../../models/chat_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

/// Unified ChatLoaded state with conversationId support
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? conversationId;
  final List<Conversation> conversations; // Add this
  final String? selectedConversationId; // Add this

  const ChatLoaded(
    this.messages, {
    this.isLoading = false,
    this.conversationId,
    this.conversations = const [], // Initialize empty
    this.selectedConversationId,
  });

  // Update copyWith to include new fields
  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? conversationId,
    List<Conversation>? conversations,
    String? selectedConversationId,
  }) {
    return ChatLoaded(
      messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      conversationId: conversationId ?? this.conversationId,
      conversations: conversations ?? this.conversations,
      selectedConversationId: selectedConversationId ?? this.selectedConversationId,
    );
  }

  @override
  List<Object?> get props => [
    messages, 
    isLoading, 
    conversationId, 
    conversations,
    selectedConversationId,
  ];
}

class ChatError extends ChatState {
  final String error;
  const ChatError(this.error);

  @override
  List<Object?> get props => [error];
}

