import 'package:ai_bff/chat_page/chat_page.dart';
import 'package:ai_bff/services/chat_list_service.dart';
import 'package:ai_bff/services/groq_service.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatListService _service = ChatListService();
  final GroqService _gService = GroqService();

  Future<(String, String)?> describeBFF() async =>
      await showAdaptiveDialog<(String, String)?>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          String? name;
          String? description;
          return Dialog(
            insetPadding: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('What is the name of your BFF'),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name should not be empty'
                        : null,
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 8),
                  Text('BFF description'),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Description should not be empty'
                        : null,
                    maxLines: null,
                    onChanged: (value) => description = value,
                    decoration: InputDecoration(
                      hintText:
                          'Describe your BFF, you can write details like age, attitude, etc',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, (name, description));
                      },
                      child: Text('Start Chat'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI BFF'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final details = await describeBFF();
          if (details == null) return;
          _service.chats.add((title: details.$1, subtitle: details.$2));
          final chat = await _gService.startChat(details);
          if (context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  chat: chat,
                  name: details.$1,
                ),
              ),
            );
            setState(() {});
          }
        },
        label: Row(
          children: [Icon(Icons.add), Text('New Chat')],
        ),
      ),
      body: _service.chats.isEmpty
          ? Center(
              child: Text('Your chats will appear here (USE VPN)'),
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                final chatDetails = _service.chats[index];
                return ListTile(
                  title: Text(chatDetails.title),
                  subtitle: Text(chatDetails.subtitle),
                  leading: Icon(Icons.person),
                  onTap: () {},
                  tileColor: Theme.of(context).colorScheme.onPrimary,
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: _service.chats.length,
            ),
    );
  }
}
