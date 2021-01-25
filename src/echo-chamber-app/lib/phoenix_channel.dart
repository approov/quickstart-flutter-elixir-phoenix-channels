import 'package:echo/http_service.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:echo/user_auth.dart';

class PhoenixChannelSocket {
  static String _authToken;

  static PhoenixSocket _socket;

  static Map<String, PhoenixChannel> _channels = {};

  static connect() async {
    _authToken = await _getAuthenticationToken();

    final socket_options = new PhoenixSocketOptions(
      params: {
        "Authorization": _authToken,
      }
    );

    // To run from the Android the emulator we need to use `10.0.2.2`, because
    // if we use `localhost` we just hit the emulator VM, not our computer
    // `localhost`.
    _socket = PhoenixSocket(
      "${HttpService.websocketUrl}/socket/websocket",
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

    // Only join if not already joined.
    if(_channels != null && _channels[channelName] != null) {
      return;
    }

    final PhoenixChannel _channel = _socket.channel(
      channelName,
      {
        "Authorization": _authToken,
      });

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

    _channels[channelName].push(
        event: "echo_it",
        payload: {
          "message": message,
          "Authorization": _authToken,
        }
    );
  }

  static _getAuthenticationToken() async {
    // @TODO Add Authentication register screen
    await UserAuth().register("me@gmail.com", "very_strong_password");

    // @TODO Add Authentication login screen
    return await UserAuth().login("me@gmail.com", "very_strong_password").then((value) => value);
  }
}
