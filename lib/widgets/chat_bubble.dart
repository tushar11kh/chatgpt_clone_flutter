import 'package:chatgpt_clone/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? imageUrl;         // legacy single image
  final List<String>? images;     // multiple images from backend
  final bool isLoading;
  final String modelUsed;         // Add this field

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.modelUsed,      // Add to constructor
    this.imageUrl,
    this.images,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = getBackgroundColor(brightness);
    final textColor = getPrimaryTextColor(brightness);
    final chatBgColor = getChatBackgroundColor(brightness);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.6 : 0.8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isUser ? chatBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Render multiple images if present - INSIDE the grey bubble
            if ((images != null && images!.isNotEmpty) || (imageUrl != null && imageUrl != 'local_image')) 
              ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      if (images != null && images!.isNotEmpty)
                        ...images!.map(
                          (url) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              width: double.infinity,
                              height: 135, // 10% smaller than 150
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (imageUrl != null && imageUrl != 'local_image')
                        Container(
                          width: double.infinity,
                          height: 135, // 10% smaller than 150
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            // Chat text bubble - INSIDE the grey bubble
            if (text.isNotEmpty || isLoading)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16, 
                  ((images != null && images!.isNotEmpty) || (imageUrl != null && imageUrl != 'local_image')) ? 0 : 12, 
                  16, 
                  4 // Reduced bottom padding to make room for model text
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : isUser
                     ? Text(
                        text,
                        style: TextStyle(color: textColor, fontSize: 16),
                      )
                      : MarkdownBody(  // AI messages use markdown
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: textColor, fontSize: 16),
                  strong: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ),
            // Model information text
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Model: $modelUsed',
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}