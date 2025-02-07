typedef ChatListDetails = ({String title, String subtitle});

class ChatListService {
  ChatListService._();

  static final _singleton = ChatListService._();

  factory ChatListService() => _singleton;

  List<ChatListDetails> chats = [];
}
