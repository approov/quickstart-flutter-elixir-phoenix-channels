// @dart=2.9

import 'dart:io';
import 'package:http/http.dart' as http;

// UNCOMMENT TO USE APPROOV
//import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

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
  // IF RUNNING PHOENIX CHANNELS SERVER LOCALLY
  // static String apiHost = localhost;
  // IF USING THE UNPROTECTED PHOENIX CHANNELS SERVER BEFORE ADDING APPROOV
  static String apiHost = 'unprotected.phoenix-channels.demo.approov.io';
  // IF USING THE PROTECTED PHOENIX CHANNELS SERVER WHEN USING APPROOV
  //static String apiHost = 'token.phoenix-channels.demo.approov.io';

  static String get apiBaseUrl {
    String host = apiHost;
    return "${httpProtocol}://${host}";
  }

  // COMMENT LINE BELOW IF USING APPROOV
  static final httpClient = new http.Client();

  // UNCOMMENT LINES BELOW IF USING APPROOV
  /*static final httpClient = () {
    var approovClient = ApproovClient('<enter your config here>');
    // We use a custom header "X-Approov-Token" rather than just "Approov-Token"
    ApproovService.setApproovHeader("X-Approov-Token", "");
    ApproovService.setBindingHeader('Authorization');
    return approovClient;
  }();*/

  static String get websocketUrl {
    return "${websocketProtocol}://${apiHost}";
  }

  // UNCOMMENT IF USING APPROOV
  /*static Future<String> fetchApproovTokenBinding(String data) async {
    if (data != null)
      ApproovService.setDataHashInToken(data);
    // note this will return an empty string if the token cannot be obtained for any reason
    return ApproovService.fetchApproovToken(apiHost);
  }*/
}
