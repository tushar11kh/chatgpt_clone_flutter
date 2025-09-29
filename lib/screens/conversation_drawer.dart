import 'package:chatgpt_clone/bloc/chat/chat_bloc.dart';
import 'package:chatgpt_clone/bloc/chat/chat_event.dart';
import 'package:chatgpt_clone/bloc/chat/chat_state.dart';
import 'package:chatgpt_clone/constants.dart';
import 'package:chatgpt_clone/models/chat_model.dart';
import 'package:chatgpt_clone/widgets/theme_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationDrawer extends StatefulWidget {
  final Color bgColor;
  final Color textColor;
  final Color inputBgColor;
  final VoidCallback onNewChat;
  // final VoidCallback onThemeChange;

  const ConversationDrawer({
    super.key,
    required this.bgColor,
    required this.textColor,
    required this.inputBgColor,
    required this.onNewChat,
    // required this.onThemeChange,
  });

  @override
  State<ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends State<ConversationDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String? _editingConversationId;
  TextEditingController? _renameController;
  bool _isFocused = false;

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
    _searchController.dispose();
    _searchFocus.dispose();
    _renameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: widget.bgColor,
      child: Column(
        children: [
          // Search field
          _buildSearchField(),

          // New Chat button
          _buildNewChatButton(),

          // Conversations list
          _buildConversationsList(),

          // Bottom options
          _buildBottomOptions(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 60, 12, 12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        cursorColor: widget.textColor,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Search conversations",
          hintStyle: TextStyle(color: widget.textColor.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: widget.inputBgColor,
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
                      color: widget.textColor,
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
                    icon: Icon(Icons.search, size: 32, color: widget.textColor),
                    onPressed: () {
                      _searchFocus.requestFocus();
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewChatButton() {
    return ListTile(
      leading: Icon(Icons.edit_square, color: widget.textColor),
      title: Text("New Chat", style: TextStyle(color: widget.textColor)),
      onTap: () {
        widget.onNewChat();
        Navigator.pop(context);
      },
    );
  }

  Widget _buildConversationsList() {
    return Expanded(
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
                    color: widget.textColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No conversations yet",
                    style: TextStyle(
                      color: widget.textColor.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start a chat to see history here",
                    style: TextStyle(
                      color: widget.textColor.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Filter conversations based on search
          final filteredConversations = conversations
              .where((conv) => conv.title.toLowerCase().contains(searchQuery))
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
                    color: widget.textColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No conversations found",
                    style: TextStyle(
                      color: widget.textColor.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try a different search term",
                    style: TextStyle(
                      color: widget.textColor.withOpacity(0.4),
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
              final isEditing = _editingConversationId == conversation.id;

              return ListTile(
                tileColor: selectedConversationId == conversation.id
                    ? Colors.grey.withOpacity(0.3)
                    : null,
                title: isEditing
                    ? TextField(
                        controller: _renameController,
                        style: TextStyle(color: widget.textColor),
                        decoration: InputDecoration(
                          hintText: "Conversation title",
                          hintStyle: TextStyle(
                            color: widget.textColor.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        autofocus: true,
                        onSubmitted: (newTitle) {
                          _saveRename(context, conversation, newTitle);
                        },
                      )
                    : Text(
                        conversation.title,
                        style: TextStyle(color: widget.textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                // Remove the trailing checkmark entirely
                trailing: null,
                onTap: () {
                  if (isEditing) return; // Don't select if editing
                  context.read<ChatBloc>().add(
                    SelectConversation(conversation.id),
                  );
                  Navigator.pop(context);
                },
                onLongPress: () {
                  _showConversationOptions(context, conversation);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomOptions() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.light_mode, color: widget.textColor),
            title: Text(
              "Color Scheme",
              style: TextStyle(color: widget.textColor),
            ),
            onTap: () {
              ThemeDialog.show(
                context: context,
                bgColor: widget.inputBgColor,
                textColor: widget.textColor,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showConversationOptions(
    BuildContext context,
    Conversation conversation,
  ) {
    // final textColor = getPrimarywidget.textColor(Theme.of(context).brightness);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: getBackgroundColor(Theme.of(context).brightness),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: widget.textColor),
              title: Text("Rename", style: TextStyle(color: widget.textColor)),
              onTap: () {
                Navigator.pop(context);
                _startEditing(conversation);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, conversation);
              },
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: getInputBackgroundColor(
                    Theme.of(context).brightness,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: widget.textColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Conversation conversation) {
    // final textColor = getPrimarywidget.textColor(Theme.of(context).brightness);
    // final bgColor = getBackgroundColor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.bgColor,
        title: Text(
          "Delete Conversation",
          style: TextStyle(color: widget.textColor),
        ),
        content: Text(
          "Are you sure you want to delete '${conversation.title}'? This action cannot be undone.",
          style: TextStyle(color: widget.textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: widget.textColor)),
          ),
          TextButton(
            onPressed: () {
              _deleteConversation(context, conversation);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteConversation(BuildContext context, Conversation conversation) {
    // TODO: Implement delete conversation in BackendService and ChatBloc
    context.read<ChatBloc>().add(DeleteConversation(conversation.id));
    // Reload conversations to reflect the deletion
    context.read<ChatBloc>().add(const LoadConversations());
    Navigator.pop(context); // This closes the drawer
    setState(() {});
  }

  void _startEditing(Conversation conversation) {
    setState(() {
      _editingConversationId = conversation.id;
      _renameController = TextEditingController(text: conversation.title);

      // Move cursor to the end
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _renameController?.selection = TextSelection.fromPosition(
          TextPosition(offset: _renameController!.text.length),
        );
      });
    });
  }

  void _saveRename(
    BuildContext context,
    Conversation conversation,
    String newTitle,
  ) {
    final trimmedTitle = newTitle.trim();
    if (trimmedTitle.isNotEmpty && trimmedTitle != conversation.title) {
      context.read<ChatBloc>().add(
        UpdateConversationTitle(conversation.id, trimmedTitle),
      );
    }

    // Exit editing mode
    setState(() {
      _editingConversationId = null;
      _renameController?.dispose();
      _renameController = null;
    });
  }
}
