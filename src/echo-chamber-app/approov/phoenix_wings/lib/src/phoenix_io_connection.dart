import 'dart:io';
import 'dart:async';

import 'package:phoenix_wings/src/phoenix_connection.dart';
import 'package:approovsdkflutter/approovsdkflutter.dart';
import 'package:approov_web_socket/approov_web_socket.dart';

/// PhoenixIoConnection handles the creation and use
/// of the underlying websocket connection on browser platforms.
class PhoenixIoConnection extends PhoenixConnection {
  Future<WebSocket> _connFuture;
  WebSocket _conn;
  final String _endpoint;

  // Use completer for close event because:
  //  * onDone of WebSocket doesn't fire consistently :(
  //  * this enables setting onClose/onDone/onError separately
  Completer _closed = new Completer();

  bool get isConnected => _conn?.readyState == WebSocket.open;
  int get readyState => _conn?.readyState ?? WebSocket.closed;

  static PhoenixConnection provider(String endpoint) {
    return new PhoenixIoConnection(endpoint);
  }

  PhoenixIoConnection(this._endpoint);

  // waitForConnection is idempotent, it can be called many
  // times before or after the connection is established
  Future<PhoenixConnection> waitForConnection() async {
    _connFuture ??= ApproovIOWebSocket.connect(_endpoint, approovHeader: Approovsdkflutter.X_APPROOV_HEADER);
    _conn = await _connFuture;

    return this;
  }

  void close([int code, String reason]) => _conn?.close(code, reason);
  void send(String data) {
    if (isConnected) {
      _conn.add(data);
    }
  }

  void onClose(void callback()) {
    _closed.future.then((e) {
      callback();
    });
  }

  void onError(void callback(dynamic)) {
    _conn.handleError(callback);
    _conn.done.catchError(callback);
  }

  String _messageToString(dynamic e) {
    // TODO: types are String or List<int>
    return e as String;
  }

  void onMessage(void callback(String m)) {
    _conn.listen((e) {
      callback(_messageToString(e));
    }, onDone: () {
      _closed.complete();
    });
  }
}
