// @dart=2.9

import 'dart:convert';
import 'package:echo/http_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UserAuth {
  final http = HttpService.httpClient;

  Future<String> login(String username, String password) async {
    String _token;

    Map credentials = {
      "username": username,
      "password": password,
    };

    Map<String, String> headers = {
      "content-type": "application/json"
    };

    Response response = await http
        .post(
      Uri.parse("${HttpService.apiBaseUrl}/auth/login"),
      headers: headers,
      body: jsonEncode(credentials),
    ).catchError((onError) {
      print(onError);
      return null;
    });

    if (response == null || response.statusCode != 200) {
      return null;
    }

    _token = jsonDecode(response.body)["token"];
    return _token;
  }

  Future<bool> register(String username, String password) async {
    bool success = false;

    Map credentials = {
      "username": username,
      "password": password,
    };

    Map<String, String> headers = {
      "content-type": "application/json"
    };

    Response response = await http
        .post(
      Uri.parse("${HttpService.apiBaseUrl}/auth/register"),
      headers: headers,
      body: jsonEncode(credentials),
    ).catchError((onError) {
      print(onError);
      return null;
    });

    if (response == null || response.statusCode != 200) {
      return success;
    }

    success = jsonDecode(response.body)["id"] != null;
    return success;
  }
}
