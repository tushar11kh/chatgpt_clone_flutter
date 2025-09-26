import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../services/perplexity_service.dart'; // Updated import
import '../../models/chat_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<StreamMessage>(_onStreamMessage);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    List<ChatMessage> updatedMessages = [];
    
    if (currentState is ChatLoaded) {
      updatedMessages = List.from(currentState.messages);
    }

    // Add user message
    updatedMessages.add(ChatMessage(
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: event.imageFile != null ? 'local_image' : null,
      modelUsed: event.model,
    ));

    emit(ChatLoaded(updatedMessages, isLoading: true));

    try {
      // Send to Perplexity API
      final response = await PerplexityService.sendMessage(
        message: event.message,
        model: event.model,
        history: updatedMessages,
        imageFile: event.imageFile,
      );

      // Add assistant response
      updatedMessages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        modelUsed: event.model,
      ));

      emit(ChatLoaded(updatedMessages));

      // Save conversation locally (optional - using shared_preferences)
      await _saveConversationLocally(updatedMessages, event.model);

    } catch (e) {
      // Add error message
      updatedMessages.add(ChatMessage(
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        modelUsed: event.model,
      ));
      
      emit(ChatLoaded(updatedMessages));
    }
  }

  Future<void> _onStreamMessage(StreamMessage event, Emitter<ChatState> emit) async {
    // Implement streaming if needed
    // This would provide real-time typing indicators
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    emit(ChatInitial());
  }

  Future<void> _saveConversationLocally(List<ChatMessage> messages, String model) async {
    // Save to shared_preferences for local persistence
    // You can implement this later for chat history
  }
}