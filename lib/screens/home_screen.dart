import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _controller.clear();
    setState(() {}); // refresh to reset icon back to wave
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = brightness == Brightness.dark ? Colors.black : Colors.white;
    final textColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final chatBgColor =
        brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textColor),
          onPressed: () {
            // Handle settings
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView.builder(
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
                        color: msg.isUser ? Colors.blueAccent : chatBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? Colors.white : textColor,
                        ),
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
                    color: brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[300],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.insert_photo_outlined, color: textColor),
                    onPressed: () {
                      // Handle image upload
                    },
                  ),
                ),
                SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                Expanded(
  child: TextField(
    controller: _controller,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      hintText: "Ask anything",
      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.grey[300],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),

      // 👇 Place the switcher here
      suffixIcon: AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, anim) => ScaleTransition(
    scale: anim,
    child: child,
  ),
  child: _controller.text.isEmpty
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
          onPressed: () {},
        )
      : IconButton(
  key: const ValueKey('arrow'),
  icon: CircleAvatar(
    backgroundColor: Colors.white, // white circular background
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
  onPressed: () => _sendMessage(_controller.text),
),

),

    ),
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

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, this.isUser = true});
}
