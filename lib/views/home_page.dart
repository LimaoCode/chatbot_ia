import 'package:chatbot_ia/models/chat_message.dart';
import 'package:chatbot_ia/widgets/chat_message_list_item.dart';
import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageList = <ChatMessage>[];
  final _controllerText = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controllerText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Quiz - Preparação para o Quiz'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/Eqp-logo.png",
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildList(),
          const Divider(height: 1.0),
          _buildUserInput(),
        ],
      ),
    );
  }

  // Cria a lista de mensagens (de baixo para cima)
  Widget _buildList() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) =>
            ChatMessageListItem(chatMessage: _messageList[index]),
        itemCount: _messageList.length,
      ),
    );
  }

  // Envia uma mensagem com o padrão a direita
  void _sendMessage({required String text}) {
    _controllerText.clear();
    _addMessage(name: 'Usuário', text: text, type: ChatMessageType.sent);
  }

  // Adiciona uma mensagem na lista de mensagens
  void _addMessage(
      {required String name,
      required String text,
      required ChatMessageType type}) {
    var message = ChatMessage(text: text, name: name, type: type);
    setState(() {
      _messageList.insert(0, message);
    });

    if (type == ChatMessageType.sent) {
      // Envia a mensagem para o chatbot e aguarda sua resposta
      _dialogFlowRequest(query: message.text);
    }
  }

  Future _dialogFlowRequest({required String query}) async {
    // Adiciona uma mensagem temporária na lista
    _addMessage(
        name: 'SIP Quiz - BOT',
        text: 'Escrevendo...',
        type: ChatMessageType.received);

    // Faz a autenticação com o serviço, envia a mensagem e recebe uma resposta da Intent
    DialogAuthCredentials credentials =
        await DialogAuthCredentials.fromFile("assets/credentials.json");

    final DialogFlowtter dialogFlowtter = DialogFlowtter(
      credentials: credentials,
    );

    final QueryInput queryInput = QueryInput(
      text: TextInput(
        text: query,
        languageCode: "pt-BR",
      ),
    );

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: queryInput,
    );

    // remove a mensagem temporária
    setState(() {
      _messageList.removeAt(0);
    });

    // adiciona a mensagem com a resposta do DialogFlow
    _addMessage(
        name: 'SIP Quiz - BOT',
        text: response.text ?? '',
        type: ChatMessageType.received);
  }

  // Campo para escrever a mensagem
  Widget _buildTextField() {
    return Flexible(
      child: TextField(
        controller: _controllerText,
        decoration: const InputDecoration.collapsed(
          hintText: "Enviar mensagem",
        ),
      ),
    );
  }

  // Botão para enviar a mensagem
  Widget _buildSendButton() {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      child: IconButton(
          icon:
              Icon(Icons.send, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            if (_controllerText.text.isNotEmpty) {
              _sendMessage(text: _controllerText.text);
            }
          }),
    );
  }

  // Monta uma linha com o campo de text e o botão de enviao
  Widget _buildUserInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          _buildTextField(),
          _buildSendButton(),
        ],
      ),
    );
  }
}
