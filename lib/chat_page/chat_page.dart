import 'dart:convert';
import 'dart:math';

import 'package:ai_bff/services/chat_list_service.dart';
import 'package:ai_bff/services/groq_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:groq_sdk/groq_sdk.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.chat,
    required this.name,
  });

  final GroqChat chat;
  final String name;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _gService = GroqService();
  final _service = ChatListService();
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _ai = const types.User(id: '82091008-a484-4a19-ae75-a22bf8d6d3ac');

  @override
  Widget build(BuildContext context) {
    // _messages.addAll(_service.messageCache[widget.name]);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.person),
          )
        ],
      ),
      body: StreamBuilder<ChatEvent>(
          stream: widget.chat.stream,
          builder: (context, chatEvent) {
            chatEvent.data?.when(
              request: (event) {},
              response: (event) {
                final textMessage = types.TextMessage(
                  author: _ai,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  id: randomString(),
                  text: event.response.choices.first.message,
                );
                _addMessage(textMessage);
              },
            );
            return Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              onAttachmentPressed: () {},
              user: _user,
            );
          }),
    );
  }

  void _addMessage(types.Message message) {
    _messages.insert(0, message);
    // _service[widget.chat] = message;
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    _addMessage(textMessage);
    _gService.sendText(chat: widget.chat, transactionText: message.text);
  }
}
