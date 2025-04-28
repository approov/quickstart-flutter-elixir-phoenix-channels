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

import 'package:echo/http_service.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class PhoenixChannelSocket {
  static late PhoenixSocket _socket;

  static Map<String, PhoenixChannel> _channels = {};

  static connect({onOpen, onError}) async {
    final socket_options = new PhoenixSocketOptions(
      params: await HttpService.buildRequestHeaders(),
      timeout: 2000,
      heartbeatIntervalMs: 3000,
      reconnectAfterMs: const [500, 1000, 1500, 3000],
    );

    // To run from the Android the emulator we need to use `10.0.2.2`, because
    // if we use `localhost` we just hit the emulator VM, not our computer
    // `localhost`.
    _socket = PhoenixSocket(
      "${HttpService.websocketUrl}/socket/websocket",
      // UNCOMMENT IF USING APPROOV
      //'<enter your config string here>',
      socketOptions: socket_options,
    );

    _socket.onOpen(onOpen);
    _socket.onError(onError);
    _socket.connect();
  }

  static Future<bool> join(String channelName, {onMessage, onError}) async {
    // This check needs to be the first, to be able to resume after app looses
    // network and reestablishes the socket connection.
    if (_socket != null && !_socket.isConnected) {
      print("Phoenix Channel: Trying to reconnect to the socket. Poor Network??? Invalid or missing Approov token???");
      return false;
    }

    if (_socket == null) {
      print("Phoenix Channel: No socket connection. No network??? Invalid or missing Approov token???");
      return false;
    }

    // Only join if not already joined.
    if (_channels != null && _channels[channelName] != null) {
      return true;
    }

    final PhoenixChannel _channel = _socket.channel(channelName, await HttpService.buildRequestHeaders());

    // Setup listeners for channel events
    _channel.on(channelName, onMessage);
    _channel.onError(onError);

    // Make the request to the server to join the channel
    _channel.join();

    _channels[channelName] = _channel;

    return true;
  }

  static Future<bool> push(String message, String channelName) async {
    if (_channels == null || _channels[channelName] == null) {
      print("Phoenix Channel: Unknown channel ${channelName}");
      return false;
    }

    Map payload = await HttpService.buildRequestHeaders();
    payload["message"] = message;

    _channels[channelName]?.push(event: "echo_it", payload: payload);

    return true;
  }
}
