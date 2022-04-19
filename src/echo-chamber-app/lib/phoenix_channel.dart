// @dart=2.9

import 'package:echo/http_service.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class PhoenixChannelSocket {

  static PhoenixSocket _socket;

  static Map<String, PhoenixChannel> _channels = {};

  static connect() async {
    final socket_options = new PhoenixSocketOptions(
        params: await HttpService.buildRequestAttributesWithUserToken()
    );

    // To run from the Android the emulator we need to use `10.0.2.2`, because
    // if we use `localhost` we just hit the emulator VM, not our computer
    // `localhost`.
    _socket = PhoenixSocket(
      "${HttpService.websocketUrl}/socket/websocket",
      // UNCOMMENT IF USING APPROOV
      //'<enter your config string here>',
      socketOptions: socket_options
    );

    await _socket.connect();
  }

  static join (
    String channelName,
    {
      onMessage,
      onError
    }
  ) async {

    if (_socket == null) {
      onError("Phoenix Channel: No network???");
      return;
    }

    if (! _socket.isConnected) {
      onError("Phoenix Channel: socket is not connected");
      return;
    }

    // Only join if not already joined.
    if(_channels != null && _channels[channelName] != null) {
      return;
    }

    final PhoenixChannel _channel = _socket.channel(
        channelName,
        await HttpService.buildRequestAttributesWithUserToken()
    );

    // Setup listeners for channel events
    _channel.on(channelName, onMessage);
    _channel.onError(onError);

    // Make the request to the server to join the channel
    _channel.join();

    _channels[channelName] = _channel;
  }

  static push(String message, String channelName) async {
    if(_channels == null || _channels[channelName] == null) {
      print("Missing channel for: ${channelName}");
      return;
    }

    Map payload = await HttpService.buildRequestAttributesWithUserToken();
    payload["message"] = message;

    _channels[channelName].push(
        event: "echo_it",
        payload: payload
    );
  }
}
