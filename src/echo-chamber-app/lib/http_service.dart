// @dart=2.9
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:echo/user_auth.dart';

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

  // UNCOMMENT IF USING APPROOV
  /*static Future<String> fetchApproovTokenBinding(String data) async {
    if (data != null)
      ApproovService.setDataHashInToken(data);
    // note this will return an empty string if the token cannot be obtained for any reason
    return ApproovService.fetchApproovToken(apiHost);
  }*/

  static String get websocketUrl {
    return "${websocketProtocol}://${apiHost}";
  }

  static Future<Map<String, String>> buildRequestAttributes() async {
    return {
      // UNCOMMENT THE LINE BELOW IF USING APPROOV WITH THE LOCALHOST BACKEND SERVER
      // "X-Approov-Token": _getTokenForLocalhostTesting(type: "valid"),

      // UNCOMMENT THE LINE BELOW IF USING APPROOV WITH THE ONLINE BACKEND SERVER
      //"X-Approov-Token": await fetchApproovTokenBinding(_authToken)
    };
  }

  static Future<Map<String, String>> buildRequestAttributesWithUserToken() async {
      var authToken = await _getAuthenticationToken();
      var attrs = await buildRequestAttributes();
      attrs["Authorization"] = authToken;
      return attrs;
  }

  static Future<String> _getAuthenticationToken() async {
    if (auth_token != null) {
      return auth_token;
    }

    return await register_and_login();
  }

  static Future<String> register_and_login() async {
    // @TODO Add Authentication register screen
    await UserAuth().register("me@gmail.com", "very_strong_password");

    // @TODO Add Authentication login screen
    return await UserAuth().login("me@gmail.com", "very_strong_password").then((value) => value);
  }

  static String _getTokenForLocalhostTesting({type}) {
    switch(type) {
      case "valid": {
        return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjQ3MDg2ODMyMDUuODkxOTEyfQ.c8I4KNndbThAQ7zlgX4_QDtcxCrD9cff1elaCJe9p9U";
      }

      case "expired": {
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTAzMDI4MTZ9.1MlmDnPHlgPzKPqHxsPd6HBZ-DYbDB16qGutk7Eheb8";
      }

      case "invalid_signature": {
        return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1NTUwODMzNDkuMzc3NzYyM30.XzZs_ItunAmisfTAuLLHqTytNnQqnwqh0Koh3PPKAoA";
      }

      case "malformed": {
        return "sddsfs.adsad.asdsa";
      }

      case "empty": {
        return "";
      }
    }
  }
}
