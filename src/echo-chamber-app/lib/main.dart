import 'package:flutter/material.dart';
import 'package:echo/phoenix_channel.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Echo Chamber'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _channelName = "echo:chamber";
  List<ChatMessage> messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    PhoenixChannelSocket.connect();
    super.initState();
  }

  _error() {
    setState(() {
      // @TODO Show toaster message with the error.
      messages.insert(0, ChatMessage(text: "ERRROR"));
    });
  }

  _say(payload, _ref, _joinRef) {
    setState(() {
      messages.insert(0, ChatMessage(text: payload["message"]));
    });
  }

  _sendMessage(message) async {
    // Will join only if not already joined.
    await PhoenixChannelSocket.join(
        _channelName,
        onMessage: this._say,
        onError: this._error
    );

    PhoenixChannelSocket.push(message, _channelName);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                final message = messages[index];
                return Card(
                    child: Column(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.message),
                        title: Text(message.text),
                        subtitle: Text(message.time)),
                  ],
                ));
              },
              itemCount: messages.length,
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Container(
              child: MessageComposer(
            textController: _textController,
            sendMessage: _sendMessage,
          ))
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final DateTime received = DateTime.now();
  ChatMessage({this.text});

  get time => DateFormat.Hms().format(received);
}

class MessageComposer extends StatelessWidget {
  final textController;
  final sendMessage;

  MessageComposer({this.textController, this.sendMessage});
  build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                  controller: textController,
                  onSubmitted: sendMessage,
                  decoration:
                      InputDecoration.collapsed(hintText: "Send a message")),
            ),
            Container(
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(textController.text)),
            )
          ],
        ));
  }
}
