import 'package:chatgpt_clone/services/backend_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../models/chat_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    on<UpdateChat>(_onUpdateChat);
    on<LoadConversations>(_onLoadConversations);
    on<SelectConversation>(_onSelectConversation);
    on<UpdateConversationTitle>(_onUpdateConversationTitle);
    on<DeleteConversation>(_onDeleteConversation);

  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
  // Get current state messages and conversationId
  List<ChatMessage> updatedMessages = [];
  String? conversationId;

  if (state is ChatLoaded) {
    final current = state as ChatLoaded;
    updatedMessages = List.from(current.messages);
    conversationId = current.conversationId;
  }

  // Create user message with temporary image URL
  final userMessage = ChatMessage(
    text: event.message,
    isUser: true,
    timestamp: DateTime.now(),
    imageUrl: event.imageFile != null ? 'local_image' : null,
    images: null,
    modelUsed: event.model,
  );
  updatedMessages.add(userMessage);

  // Emit loading state
  emit(ChatLoaded(updatedMessages, isLoading: true, conversationId: conversationId));

  try {
    // Send message to backend
    final response = await BackendService.sendMessage(
      text: event.message,
      model: event.model,
      conversationId: conversationId,
      imageFile: event.imageFile,
      history: updatedMessages,
    );

    final newConversationId = response['conversationId'] as String;
    final messagesJson = response['messages'] as List<dynamic>;

    // Convert dynamic to ChatMessage
    final backendMessages = messagesJson
        .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
        .toList();

    // Find the user message in backend response and update our local message
    final backendUserMessage = backendMessages.firstWhere(
      (msg) => msg.isUser,
      orElse: () => userMessage,
    );

    // Update the user message with the actual image URL from backend
    final updatedUserMessage = ChatMessage(
      text: userMessage.text,
      isUser: true,
      timestamp: userMessage.timestamp,
      imageUrl: backendUserMessage.imageUrl, // Use the actual URL from backend
      images: backendUserMessage.images,
      modelUsed: userMessage.modelUsed,
    );

    // Replace the temporary user message with the updated one
    updatedMessages[updatedMessages.length - 1] = updatedUserMessage;

    // Add AI messages (filter out user messages since we already updated ours)
    final aiMessages = backendMessages.where((msg) => !msg.isUser).toList();
    updatedMessages.addAll(aiMessages);

    // Emit final loaded state
    emit(ChatLoaded(updatedMessages, isLoading: false, conversationId: newConversationId));
  } catch (e) {
    // On error, add AI error message
    updatedMessages.add(ChatMessage(
      text: 'Failed to send message: ${e.toString()}',
      isUser: false,
      timestamp: DateTime.now(),
      modelUsed: event.model,
    ));

    emit(ChatLoaded(updatedMessages, isLoading: false, conversationId: conversationId));
  }
}

  Future<void> _onUpdateChat(UpdateChat event, Emitter<ChatState> emit) async {
    emit(
      ChatLoaded(
        event.messages,
        conversationId: event.conversationId,
        isLoading: false,
      ),
    );
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    emit(ChatInitial());
  }

  // Add these methods
  Future<void> _onLoadConversations(LoadConversations event, Emitter<ChatState> emit) async {
  try {
    final conversationsJson = await BackendService.getAllConversations();
    final conversations = conversationsJson
        .map((conv) => Conversation.fromJson(conv as Map<String, dynamic>))
        .toList();

    // Handle both ChatLoaded and ChatInitial states
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      emit(current.copyWith(conversations: conversations));
    } else {
      // If initial state, create ChatLoaded with empty messages but loaded conversations
      emit(ChatLoaded(
        [],
        conversations: conversations,
        isLoading: false,
      ));
    }
  } catch (e) {
    // Handle error but don't break the state
    print('Failed to load conversations: $e');
    
    // Even on error, ensure we have a valid state with empty conversations
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      emit(current.copyWith(conversations: const []));
    } else {
      emit(ChatLoaded([], conversations: const []));
    }
  }
}

  Future<void> _onSelectConversation(
    SelectConversation event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conversationsJson = await BackendService.getAllConversations();
      final conversations = conversationsJson
          .map((conv) => Conversation.fromJson(conv as Map<String, dynamic>))
          .toList();

      final selectedConversation = conversations.firstWhere(
        (conv) => conv.id == event.conversationId,
        orElse: () => conversations.first,
      );

      emit(
        ChatLoaded(
          selectedConversation.messages,
          conversationId: selectedConversation.id,
          conversations: conversations,
          selectedConversationId: selectedConversation.id,
        ),
      );
    } catch (e) {
      // Handle error
      print('Failed to select conversation: $e');
    }
  }

  Future<void> _onUpdateConversationTitle(
    UpdateConversationTitle event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    try {
      await BackendService.updateConversationTitle(
        conversationId: event.conversationId,
        newTitle: event.newTitle,
      );

      // Reload conversations to get updated list
      add(const LoadConversations());
    } catch (e) {
      print('Failed to update conversation title: $e');
    }
  }

  Future<void> _onDeleteConversation(DeleteConversation event, Emitter<ChatState> emit) async {
  try {
    await BackendService.deleteConversation(event.conversationId);
    
    // Check if we're deleting the current conversation
    final currentState = state;
    if (currentState is ChatLoaded && currentState.conversationId == event.conversationId) {
      // Clear the current chat
      emit(ChatInitial());
    }
    
    // Always reload conversations list
    add(const LoadConversations());
  } catch (e) {
    print('Failed to delete conversation: $e');
  }
}


}
