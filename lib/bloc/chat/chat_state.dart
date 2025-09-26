import 'package:equatable/equatable.dart';
import '../../models/chat_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  
  const ChatLoaded(this.messages, {this.isLoading = false});

  ChatLoaded copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatLoaded(
      messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading];
}

class ChatError extends ChatState {
  final String error;
  const ChatError(this.error);

  @override
  List<Object?> get props => [error];
}