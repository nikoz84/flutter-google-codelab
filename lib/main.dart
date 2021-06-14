import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(
    const FriendlyChatApp(),
  );
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Google',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({required this.text, required this.animationController});
  final String text;
  final AnimationController animationController;
  String _name = 'Nicolás';

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(child: Text(_name[0]))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name, style: Theme.of(context).textTheme.headline4),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  @override
  void dispose() {
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  // Title
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat de Teste'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: Container(
        child: Column(
          // MODIFIED
          children: [
            // NEW
            Flexible(
              // NEW
              child: ListView.builder(
                // NEW
                padding: EdgeInsets.all(5.0), // NEW
                reverse: true, // NEW
                itemBuilder: (_, int index) => _messages[index], // NEW
                itemCount: _messages.length, // NEW
              ), // NEW
            ), // NEW
            Divider(height: 1.0), // NEW
            Container(
              // NEW
              decoration:
                  BoxDecoration(color: Theme.of(context).cardColor), // NEW
              child: _buildTextComposer(), // MODIFIED
            ),
          ], // Child
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS // NEW
            ? BoxDecoration(                                 // NEW
          border: Border(                              // NEW
            top: BorderSide(color: Colors.grey[200]!), // NEW
          ),                                           // NEW
        )  : null,
      ),
    );
  }

  // Text Input
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        child: Row(children: [
          Flexible(
              child: TextField(
            controller: _textController,
            onChanged: (String text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: _isComposing ? _handleSubmitted : null,
            decoration:
                InputDecoration.collapsed(hintText: 'Envia uma mensagem'),
            focusNode: _focusNode,
          )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text('Send'),
                      onPressed: _isComposing
                          ? () => _handleSubmitted(_textController.text)
                          : null,
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _isComposing
                          ? () => _handleSubmitted(_textController.text)
                          : null,
                    ))
        ]),
      ),
    );
  }

  // Action
  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      // NEW
      _isComposing = false; // NEW
    });

    var message = ChatMessage(
      text: text,
      animationController: AnimationController(
        // NEW
        duration: const Duration(milliseconds: 700), // NEW
        vsync: this, // NEW
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    _focusNode.requestFocus();
    message.animationController.forward();
  }
}
