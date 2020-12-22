library approov_web_socket;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:math';

import 'package:websocket/websocket.dart' show WebSocket, WebSocketStatus;

import 'package:approovsdkflutter/approovsdkflutter.dart';

part 'crypto.dart';
part 'http_impl.dart';
part 'approov_web_socket_impl.dart';

/// Options controlling compression in a [WebSocket].
///
/// A [CompressionOptions] instance can be passed to [WebSocket.connect], or
/// used in other similar places where [WebSocket] compression is configured.
///
/// In most cases the default [compressionDefault] is sufficient, but in some
/// situations, it might be desirable to use different compression parameters,
/// for example to preserve memory on small devices.
class ApproovCompressionOptions extends CompressionOptions {
  /// Default [WebSocket] compression configuration.
  ///
  /// Enables compression with default window sizes and no reuse. This is the
  /// default options used by [WebSocket.connect] if no [CompressionOptions] is
  /// supplied.
  ///
  /// * `clientNoContextTakeover`: false
  /// * `serverNoContextTakeover`: false
  /// * `clientMaxWindowBits`: null (default maximal window size of 15 bits)
  /// * `serverMaxWindowBits`: null (default maximal window size of 15 bits)
  static const ApproovCompressionOptions compressionDefault = const ApproovCompressionOptions();

  const ApproovCompressionOptions(
      {clientNoContextTakeover = false,
        serverNoContextTakeover = false,
        clientMaxWindowBits,
        serverMaxWindowBits,
      enabled = false})
      : super(
            clientNoContextTakeover: clientNoContextTakeover,
            serverNoContextTakeover: serverNoContextTakeover,
            clientMaxWindowBits: clientMaxWindowBits,
            serverMaxWindowBits: serverMaxWindowBits,
            enabled: enabled);

  /// Parses list of requested server headers to return server compression
  /// response headers.
  ///
  /// Uses [serverMaxWindowBits] value if set, otherwise will attempt to use
  /// value from headers. Defaults to [WebSocket.DEFAULT_WINDOW_BITS]. Returns a
  /// [_CompressionMaxWindowBits] object which contains the response headers and
  /// negotiated max window bits.
  _CompressionMaxWindowBits _createServerResponseHeader(HeaderValue/*?*/ requested) {
    var info = new _CompressionMaxWindowBits("", 0);

    String/*?*/ part = requested?.parameters == null ? null : requested.parameters[_serverMaxWindowBits];
    if (part != null) {
      if (part.length >= 2 && part.startsWith('0')) {
        throw new ArgumentError("Illegal 0 padding on value.");
      } else {
        int mwb = serverMaxWindowBits ?? int.tryParse(part) ?? _ApproovWebSocketImpl.DEFAULT_WINDOW_BITS;
        info.headerValue = "; server_max_window_bits=${mwb}";
        info.maxWindowBits = mwb;
      }
    } else {
      info.headerValue = "";
      info.maxWindowBits = _ApproovWebSocketImpl.DEFAULT_WINDOW_BITS;
    }
    return info;
  }

  /// Returns default values for client compression request headers.
  String _createClientRequestHeader(HeaderValue/*?*/ requested, int size) {
    var info = "";

    // If responding to a valid request, specify size
    if (requested != null) {
      info = "; client_max_window_bits=$size";
    } else {
      // Client request. Specify default
      if (clientMaxWindowBits == null) {
        info = "; client_max_window_bits";
      } else {
        info = "; client_max_window_bits=$clientMaxWindowBits";
      }
      if (serverMaxWindowBits != null) {
        info += "; server_max_window_bits=$serverMaxWindowBits";
      }
    }

    return info;
  }

  /// Create a Compression Header.
  ///
  /// If [requested] is null or contains client request headers, returns Client
  /// compression request headers with default settings for
  /// `client_max_window_bits` header value.  If [requested] contains server
  /// response headers this method returns a Server compression response header
  /// negotiating the max window bits for both client and server as requested
  /// `server_max_window_bits` value.  This method returns a
  /// [_CompressionMaxWindowBits] object with the response headers and
  /// negotiated `maxWindowBits` value.
  _CompressionMaxWindowBits _createHeader([HeaderValue/*?*/ requested]) {
    var info = new _CompressionMaxWindowBits("", 0);
    if (!enabled) {
      return info;
    }

    info.headerValue = _ApproovWebSocketImpl.PER_MESSAGE_DEFLATE;

    if (clientNoContextTakeover &&
        (requested == null || (requested != null && requested.parameters.containsKey(_clientNoContextTakeover)))) {
      info.headerValue += "; client_no_context_takeover";
    }

    if (serverNoContextTakeover &&
        (requested == null || (requested != null && requested.parameters.containsKey(_serverNoContextTakeover)))) {
      info.headerValue += "; server_no_context_takeover";
    }

    var headerList = _createServerResponseHeader(requested);
    info.headerValue += headerList.headerValue;
    info.maxWindowBits = headerList.maxWindowBits;

    info.headerValue += _createClientRequestHeader(requested, info.maxWindowBits);

    return info;
  }
}

// See WebSocket from package:websocket/websocket.dart
class ApproovWebSocket extends _ApproovWebSocketImpl implements WebSocket {
  static Future<io.WebSocket> connect(String url,
    {Iterable<String>/*?*/ protocols,
    Map<String, dynamic>/*?*/ headers,
    CompressionOptions compression = ApproovCompressionOptions.compressionDefault,
    String approovHeader = Approovsdkflutter.APPROOV_HEADER}) =>
      _ApproovWebSocketImpl.connect(url, protocols, headers, compression: compression, approovHeader: approovHeader);
}

// See WebSocket from dart:io
class ApproovIOWebSocket extends _ApproovWebSocketImpl /* implements io.WebSocket*/ {
  static Future<io.WebSocket> connect(String url,
    {Iterable<String>/*?*/ protocols,
    Map<String, dynamic>/*?*/ headers,
    CompressionOptions compression = ApproovCompressionOptions.compressionDefault,
    String approovHeader = Approovsdkflutter.APPROOV_HEADER}) =>
      _ApproovWebSocketImpl.connect(url, protocols, headers, compression: compression, approovHeader: approovHeader);
}
