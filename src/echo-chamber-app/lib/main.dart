/*
 * Copyright (c) 2025 Approov Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:echo/phoenix_channel.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage('Echo Chamber'),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //MyHomePage({Key key, this.title}) : super(key: key);
  MyHomePage(this.title) : super();
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _channelName = "echo:chamber";
  List<ChatMessage> messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    EasyLoading.show(status: "Connecting...");
    PhoenixChannelSocket.connect(onOpen: this._onOpenSocket, onError: this._onSocketError);
    super.initState();
  }

  _onOpenSocket() {
    EasyLoading.dismiss();
    _enableSubmitButton();
  }

  // @TODO Figure out the steps to trigger this callback again
  // I was only able to trigger this callback once, but I was missing the error
  // parameter, therefore it threw an exception.
  _onSocketError(error) {
    print("socket error: $error");
    _disableSubmitButton();
    EasyLoading.show(status: "Retrying to reconnect...");
  }

  _showToastError(err) {
    _disableSubmitButton();

    Fluttertoast.showToast(
      msg: err.toString(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 10,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  _onChannelError(payload, ref, joinRef) {
    _disableSubmitButton();
    EasyLoading.show(status: "Waiting to rejoin channel...");
  }

  _enableSubmitButton() {
    setState(() {
      _isButtonEnabled = true;
    });
  }

  _disableSubmitButton() {
    setState(() {
      _isButtonEnabled = false;
    });
  }

  _say(payload, _ref, _joinRef) {
    setState(() {
      messages.insert(0, ChatMessage(payload["message"]));
    });
  }

  _sendMessage(message) async {
    EasyLoading.show(status: "Sending...");
    _disableSubmitButton();

    // Will join only if not already joined.
    bool isJoined = await PhoenixChannelSocket.join(_channelName, onMessage: this._say, onError: this._onChannelError);

    if (!isJoined) {
      EasyLoading.dismiss();
      _showToastError("Failed to join the channel");
      EasyLoading.show(status: "Reconnecting...");
      return;
    }

    bool isMessagePushed = await PhoenixChannelSocket.push(message, _channelName);

    if (!isMessagePushed) {
      EasyLoading.dismiss();
      _showToastError("Failed to push message to the channel");
      EasyLoading.show(status: "Reconnecting...");
      return;
    }

    _textController.clear();

    EasyLoading.dismiss();
    _enableSubmitButton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
                      ListTile(leading: Icon(Icons.message), title: Text(message.text), subtitle: Text(message.time)),
                    ],
                  ),
                );
              },
              itemCount: messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            child: MessageComposer(
              textController: _textController,
              sendMessage: _sendMessage,
              isButtonEnabled: _isButtonEnabled,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final DateTime received = DateTime.now();
  ChatMessage(this.text);

  get time => DateFormat.Hms().format(received);
}

class MessageComposer extends StatelessWidget {
  final textController;
  final sendMessage;
  final isButtonEnabled;

  MessageComposer({this.textController, this.sendMessage, this.isButtonEnabled});
  build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: textController,
              onSubmitted: sendMessage,
              enabled: isButtonEnabled,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: isButtonEnabled ? () => sendMessage(textController.text) : null,
            ),
          ),
        ],
      ),
    );
  }
}
