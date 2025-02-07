import 'package:groq_sdk/groq_sdk.dart';

String getSystemPrompt(String name, String details) {
  return "START INSTRUCTION:"
      "This is a system prompt you will be chatting with a user who is your BFF (Best friend forever), be polite and friendly, chat as though you are talking to abest fries you've known for years"
      "your name is $name and your character , personality and description is $details "
      "END INSTRUCTION";
}

class GroqService {
  GroqService._();

  static final GroqService _singleton = GroqService._();

  factory GroqService() {
    return _singleton;
  }

  final _groq = Groq(const String.fromEnvironment('groqApiKey'));

  Future<GroqChat> startChat((String, String) bFFDetials,
      [String model = GroqModels.gemma2_9b]) async {
    final chat = _groq.startNewChat(
      model,
      settings: GroqChatSettings(
        temperature: 0.9, //More creative response
      ),
    );
    chat.addMessageWithoutSending(
      getSystemPrompt(bFFDetials.$1, bFFDetials.$2),
      role: GroqMessageRole.system,
    );
    return chat;
  }

  Future<String> sendText({
    required GroqChat chat,
    required String transactionText,
  }) async {
    try {
      final (response, usage) = await chat.sendMessage(transactionText);
      assert(response.choices.isNotEmpty, 'Empty Groq response');
      print('Response ${response.choices.first.message}');
      return response.choices.first.messageData.content;
    } catch (error, trace) {
      rethrow;
    }
  }
}
