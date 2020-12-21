import 'dart:io';
import 'package:http/http.dart' as http;

class HttpService {

  static String httpProtocol = "https";
  static String websocketProtocol = "wss";

  static String auth_token;

  static String get localhost {
    httpProtocol = "http";
    websocketProtocol = "ws";

    if (Platform.isAndroid) {
      return '10.0.2.2:8002';
    } else {
      return 'localhost:8002';
    }
  }

  // Choose one of the below endpoints:
  // static String apiHost = localhost;
  static String apiHost = 'unprotected.phoenix-channels.demo.approov.io';

  static String get apiBaseUrl {
    // We need to call apiHost first, otherwise we get https in localhost.
    String host = apiHost;

    return "${httpProtocol}://${host}";
  }

  static final httpClient = new http.Client();

  static String get websocketUrl {
    return "${websocketProtocol}://${apiHost}";
  }
}
