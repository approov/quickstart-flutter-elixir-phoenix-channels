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

import 'dart:convert';
import 'package:echo/http_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UserAuth {
  final http = HttpService.httpClient;

  Future<String?> login(String username, String password) async {
    String _token;

    Map credentials = {"username": username, "password": password};

    Map<String, String> headers = {"content-type": "application/json"};

    Response response = await http
        .post(Uri.parse("${HttpService.apiBaseUrl}/auth/login"), headers: headers, body: jsonEncode(credentials))
        .catchError((onError) {
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

    Map credentials = {"username": username, "password": password};

    Map<String, String> headers = {"content-type": "application/json"};

    Response response = await http
        .post(Uri.parse("${HttpService.apiBaseUrl}/auth/register"), headers: headers, body: jsonEncode(credentials))
        .catchError((onError) {
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
