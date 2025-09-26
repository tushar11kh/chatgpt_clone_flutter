import 'package:chatgpt_clone/constants.dart';
import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:chatgpt_clone/services/api_service.dart';
import 'package:chatgpt_clone/widgets/theme_dialogue.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // For File handling
import 'package:image_picker/image_picker.dart'; // For image upload

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Variables start

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<ChatMessage> _messages = [];
  final FocusNode _searchFocus = FocusNode();

  bool _isFocused = false;
  bool _isLoading = false;

  String _selectedModel = 'gpt-3.5-turbo';
  String? _currentConversationId;

  File? _selectedImage;

  // variables ended

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {
        _isFocused = _searchFocus.hasFocus;
      });
    });
    _loadPreferences();
  }

  void _loadPreferences() async {
    // Load saved model preference
    // You can use shared_preferences package for this
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
          imageUrl: _selectedImage != null ? 'local_image' : null,
          modelUsed: _selectedModel,
        ),
      );
      _isLoading = true;
    });

    // Clear image after adding to message
    final tempImage = _selectedImage;
    _selectedImage = null;
    _chatController.clear();

    try {
      // Send to OpenAI via backend
      final response = await ApiService.sendMessage(
        message: text.trim(),
        model: _selectedModel,
        history: _messages,
        imageUrl: tempImage != null ? await _uploadImage(tempImage) : null,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
            modelUsed: _selectedModel,
          ),
        );
        _isLoading = false;
      });

      // Save conversation
      await _saveConversation();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
            modelUsed: _selectedModel,
          ),
        );
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      return await ApiService.uploadImage(imageFile);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      rethrow;
    }
  }

  Future<void> _saveConversation() async {
    final conversation = Conversation(
      id:
          _currentConversationId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _messages.first.text.length > 30
          ? '${_messages.first.text.substring(0, 30)}...'
          : _messages.first.text,
      createdAt: DateTime.now(),
      messages: _messages,
      modelUsed: _selectedModel,
    );

    await ApiService.saveConversation(conversation);
  }

  Future<void> _pickImage() async {
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
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
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
              Scaffold.of(context).openDrawer(); // Handle settings
            },
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: bgColor,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 60, 12, 22),
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              cursorColor: textColor,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search",
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
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.76),
            ListTile(
              leading: Icon(Icons.light_mode, color: textColor),
              title: Text("Color Scheme", style: TextStyle(color: textColor)),
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

      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          // Drawer closed, reset search field
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
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        "What can I help with?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[_messages.length - 1 - index];
                        return Align(
                          alignment: msg.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: chatBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        );
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
                    onPressed: () {
                       _pickImage();
                    },
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

                      // 👇 Place the switcher here
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
                                  backgroundColor:
                                      Colors.white, // white circular background
                                  radius: 16, // matches ~32px total size
                                  child: Transform.rotate(
                                    angle: -1.57, // rotate 90° upwards
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.black,
                                      size: 20, // fits nicely inside the circle
                                    ),
                                  ),
                                ),
                                onPressed: () =>
                                    _sendMessage(_chatController.text),
                              ),
                      ),
                    ),
                    cursorColor: textColor,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
