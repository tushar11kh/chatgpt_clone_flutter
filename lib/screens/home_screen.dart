import 'package:chatgpt_clone/bloc/chat/chat_bloc.dart';
import 'package:chatgpt_clone/bloc/chat/chat_event.dart';
import 'package:chatgpt_clone/bloc/chat/chat_state.dart';
import 'package:chatgpt_clone/bloc/model/model_bloc.dart';
import 'package:chatgpt_clone/bloc/model/model_event.dart';
import 'package:chatgpt_clone/bloc/model/model_state.dart';
import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:chatgpt_clone/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../widgets/theme_dialogue.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _searchFocus = FocusNode();

  bool _isFocused = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {
        _isFocused = _searchFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
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

              return DropdownButton<String>(
                value: currentModel,
                dropdownColor: bgColor,
                underline: const SizedBox.shrink(),
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                items: const [
                  DropdownMenuItem(value: 'sonar', child: Text('Sonar')),
                  DropdownMenuItem(
                    value: 'sonar-reasoning',
                    child: Text('Sonar Reasoning'),
                  ),
                ],
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
      drawer: _buildDrawer(bgColor, textColor, inputBgColor),
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          _searchFocus.unfocus();
          _searchController.clear();
          setState(() {});
        }
      },
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
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: _removeImage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[messages.length - 1 - index];

                              if (msg.isUser) {
                                // User message - show in bubble
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: chatBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (msg.imageUrl != null)
                                          Image.asset(
                                            'assets/placeholder.jpg',
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        Text(
                                          msg.text,
                                          style: TextStyle(color: textColor),
                                        ),
                                        Text(
                                          'Model: ${msg.modelUsed}',
                                          style: TextStyle(
                                            color: textColor.withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                // AI message - show as plain text (no bubble)
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.text,
                                        style: TextStyle(color: textColor),
                                      ),
                                      Text(
                                        'Model: ${msg.modelUsed}',
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.6),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
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

            // Input box
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: inputBgColor,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.insert_photo_outlined, color: textColor),
                    onPressed: _pickImage,
                  ),
                ),
                SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Ask anything",
                      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: inputBgColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      suffixIcon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: _chatController.text.isEmpty
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
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
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
                                      size: 20,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(Color bgColor, Color textColor, Color inputBgColor) {
    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 60, 12, 12),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              cursorColor: textColor,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search conversations",
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: inputBgColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                prefixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: (_isFocused || _searchController.text.isNotEmpty)
                      ? IconButton(
                          key: const ValueKey('arrow'),
                          icon: Icon(
                            Icons.arrow_back,
                            color: textColor,
                            size: 32,
                          ),
                          onPressed: () {
                            _searchFocus.unfocus();
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : IconButton(
                          key: const ValueKey('search'),
                          icon: Icon(Icons.search, size: 32, color: textColor),
                          onPressed: () {
                            _searchFocus.requestFocus();
                          },
                        ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add, color: textColor),
            title: Text("New Chat", style: TextStyle(color: textColor)),
            onTap: () {
              context.read<ChatBloc>().add(const ClearChat());
              Navigator.pop(context);
            },
          ),

          // Conversations list
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, chatState) {
                // Load conversations when drawer opens - for ANY state
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<ChatBloc>().add(const LoadConversations());
                });

                List<Conversation> conversations = [];
                String? selectedConversationId;

                if (chatState is ChatLoaded) {
                  conversations = chatState.conversations;
                  selectedConversationId = chatState.selectedConversationId;
                } else if (chatState is ChatInitial) {
                  // Initial state - conversations are being loaded
                  conversations = [];
                }

                final searchQuery = _searchController.text.toLowerCase();

                // Show loading if we're in initial state (conversations haven't loaded yet)
                if (chatState is ChatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show empty state if no conversations
                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 64,
                          color: textColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No conversations yet",
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start a chat to see history here",
                          style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter conversations based on search
                final filteredConversations = conversations
                    .where(
                      (conv) => conv.title.toLowerCase().contains(searchQuery),
                    )
                    .toList();

                // Show empty search state
                if (filteredConversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: textColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No conversations found",
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try a different search term",
                          style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = filteredConversations[index];
                    return ListTile(
                      leading: Icon(Icons.chat, color: textColor),
                      title: Text(
                        conversation.title,
                        style: TextStyle(color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${conversation.messages.length} messages',
                        style: TextStyle(color: textColor.withOpacity(0.6)),
                      ),
                      trailing: selectedConversationId == conversation.id
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        context.read<ChatBloc>().add(
                          SelectConversation(conversation.id),
                        );
                        Navigator.pop(context);
                      },
                      onLongPress: () {
                        _showRenameDialog(context, conversation);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Bottom options
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.light_mode, color: textColor),
                  title: Text(
                    "Color Scheme",
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () {
                    ThemeDialog.show(
                      context: context,
                      bgColor: inputBgColor,
                      textColor: textColor,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
