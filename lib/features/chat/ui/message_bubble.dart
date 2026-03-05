import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final String? replyPreviewText;
  final VoidCallback onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.replyPreviewText,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bubbleColor = isMine ? cs.primaryContainer : cs.surfaceContainerHighest;
    final textColor = isMine ? cs.onPrimaryContainer : cs.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomLeft: Radius.circular(isMine ? 16 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (replyPreviewText != null && replyPreviewText!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    replyPreviewText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 12),
                  ),
                ),
              ],
              Text(message.text, style: TextStyle(color: textColor, fontSize: 15)),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  formatTimeShort(message.sentAt),
                  style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}