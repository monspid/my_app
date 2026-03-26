import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/message.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/message_repository.dart';
import 'message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final msgRepo = ref.watch(messageRepositoryProvider);
    final myId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),

      body: Column(
        children: [

          Expanded(
            child: FutureBuilder<List<Message>>(
              future: msgRepo.getMessages(widget.chatId),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: Text("Loading..."));
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return const Center(child: Text("No messages"));
                }

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {

                    final msg = messages[index];
                    final isMine = msg.senderId == myId;

                    return MessageBubble(
                      message: msg,
                      isMine: isMine,
                      replyPreviewText: null,
                      onLongPress: () {},
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Message...",
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {

                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    await msgRepo.sendMessage(
                      chatId: widget.chatId,
                      senderId: myId,
                      text: text,
                    );

                    _controller.clear();

                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}