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

class StreamMessage extends ChatEvent {
  final String message;
  final String model;
  
  const StreamMessage(this.message, this.model);

  @override
  List<Object?> get props => [message, model];
}

class LoadConversations extends ChatEvent {
  const LoadConversations();
}

class SelectConversation extends ChatEvent {
  final String conversationId;
  const SelectConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ClearChat extends ChatEvent {
  const ClearChat();
}