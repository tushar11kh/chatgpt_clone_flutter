import 'package:chatgpt_clone/bloc/chat/chat_bloc.dart';
import 'package:chatgpt_clone/bloc/chat/chat_event.dart';
import 'package:chatgpt_clone/bloc/chat/chat_state.dart';
import 'package:chatgpt_clone/bloc/model/model_bloc.dart';
import 'package:chatgpt_clone/bloc/model/model_event.dart';
import 'package:chatgpt_clone/bloc/model/model_state.dart';
import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:chatgpt_clone/screens/conversation_drawer.dart';
import 'package:chatgpt_clone/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = getBackgroundColor(brightness);
    final textColor = getPrimaryTextColor(brightness);
    final chatBgColor = getChatBackgroundColor(brightness);
    final inputBgColor = getInputBackgroundColor(brightness);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: textColor),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text("ChatGPT clone", style: TextStyle(color: textColor)),
        actions: [
          BlocBuilder<ModelBloc, ModelState>(
            builder: (context, modelState) {
              final currentModel = modelState is ModelInitial
                  ? modelState.model
                  : 'sonar';

              // Mapping full names to short labels
              final Map<String, String> modelShortLabels = {
                'sonar': 's',
                'sonar-reasoning': 's-r',
                'sonar-pro': 's-p',
              };

              final Map<String, String> modelFullNames = {
                'sonar': 'Sonar',
                'sonar-reasoning': 'Sonar Reasoning',
                'sonar-pro': 'Sonar Pro',
              };

              return DropdownButton<String>(
                value: currentModel,
                dropdownColor: bgColor,
                underline: const SizedBox.shrink(),
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                // Compact label in AppBar
                selectedItemBuilder: (context) {
                  return modelShortLabels.keys.map((model) {
                    return Center(
                      child: Text(
                        modelShortLabels[model]!,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList();
                },
                // Full names in dropdown
                items: modelFullNames.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: TextStyle(color: textColor),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<ModelBloc>().add(ChangeModel(value));
                  }
                },
              );
            },
          ),
        ],
      ),
      drawer: ConversationDrawer(
        bgColor: bgColor,
        textColor: textColor,
        inputBgColor: inputBgColor,
        onNewChat: () {
          // Clear local UI state
          _chatController.clear();
          setState(() {
            _selectedImage = null;
          });
          // Clear the chat state
          context.read<ChatBloc>().add(const ClearChat());
          // Navigator.pop(context) is now handled in ConversationDrawer
        },
        // onThemeChange: onThemeChange
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, chatState) {
                  if (chatState is ChatInitial) {
                    return Center(
                      child: Text(
                        "What can I help with?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    );
                  } else if (chatState is ChatLoaded) {
                    final messages = chatState.messages;
                    return Column(
                      children: [
                        Expanded(
                          child: BlocBuilder<ChatBloc, ChatState>(
                            builder: (context, chatState) {
                              if (chatState is ChatInitial) {
                                // Show welcome message for initial state
                                return Center(
                                  child: Text(
                                    "What can I help with?",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                );
                              } else if (chatState is ChatLoaded) {
                                final messages = chatState.messages;

                                // Show welcome message even in ChatLoaded if no messages
                                if (messages.isEmpty && !chatState.isLoading) {
                                  return Center(
                                    child: Text(
                                      "What can I help with?",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    
                                    Expanded(
  child: ListView.builder(
    reverse: true,
    padding: const EdgeInsets.all(12),
    itemCount: messages.length,
    itemBuilder: (context, index) {
      final msg = messages[messages.length - 1 - index];
      
      return ChatBubble(
        text: msg.text,
        isUser: msg.isUser,
                modelUsed: msg.modelUsed, // Add this line

        imageUrl: msg.imageUrl,
        images: msg.images,
      );
    },
  ),
),
                                    if (chatState.isLoading)
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                  ],
                                );
                              } else if (chatState is ChatError) {
                                return Center(
                                  child: Text(
                                    "Error: ${chatState.error}",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (chatState is ChatError) {
                    return Center(
                      child: Text(
                        "Error: ${chatState.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Input box
// Input box
Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    // Image picker button - OUTSIDE the container
    Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: inputBgColor,
      ),
      child: IconButton(
        icon: Icon(Icons.insert_photo_outlined, color: textColor,size: 23,),
        onPressed: _pickImage,
      ),
    ),
    SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
    
    // Expanded input container with image preview inside
    Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: inputBgColor,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(18, 4, 2, 4),
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview inside the textfield container
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Stack(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: textColor.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        icon: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Text input field
            TextField(
              controller: _chatController,
              style: TextStyle(color: textColor),
              maxLines: null, // Allows unlimited lines
              minLines: 1, // Start with 1 line
              decoration: InputDecoration(
                hintText: "Ask anything...",
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
                suffixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: _chatController.text.isEmpty && _selectedImage == null
                      ? IconButton(
                          key: const ValueKey('wave'),
                          icon: ClipOval(
                            child: Image.asset(
                              'assets/wave.jpg',
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Voice Chats"),
                                content: const Text(
                                  "Voice chats are unavailable right now.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      "OK",
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : IconButton(
                          key: const ValueKey('arrow'),
                          icon: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: Transform.rotate(
                              angle: -1.57,
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                          onPressed: () {
                            _sendMessage(context);
                          },
                        ),
                ),
              ),
              cursorColor: textColor,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _sendMessage(context),
            ),
          ],
        ),
      ),
    ),
  ],
),
          ],
        ),
      ),
    );
  }

  // Add this method for renaming conversations
  void _showRenameDialog(BuildContext context, Conversation conversation) {
    final textColor = getPrimaryTextColor(Theme.of(context).brightness);
    final controller = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rename Conversation", style: TextStyle(color: textColor)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter new title",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ChatBloc>().add(
                  UpdateConversationTitle(
                    conversation.id,
                    controller.text.trim(),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text("Rename", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) async {
    final text = _chatController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final modelState = context.read<ModelBloc>().state;
    final currentModel = modelState is ModelInitial
        ? modelState.model
        : 'sonar';

    // Dispatch to BLoC, BLoC handles sending to backend
    context.read<ChatBloc>().add(
      SendMessage(text, currentModel, imageFile: _selectedImage),
    );

    // Clear input
    _chatController.clear();
    setState(() {
      _selectedImage = null;
    });
  }
}
