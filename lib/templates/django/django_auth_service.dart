
import 'dart:convert';

import 'package:flutter_api_services/src/api_helpers.dart';
import 'package:flutter_api_services/src/response_types.dart';
import 'package:http/http.dart';

import 'json/django_results_api_json.dart';

// ===============================================================================/
// DJANGO AUTH SERVICE ===========================================================/
// ===============================================================================/

class DjangoAuthService {
  final Client client;
  final Uri uriApiBase;

  const DjangoAuthService({
    required this.client,
    required this.uriApiBase,
  });

  /// ======================= //
  ///
  /// LOGIN
  ///
  /// callLoginApi
  /// @[PARAM]
  /// String email                     - email to login with
  /// String password                  - password to login with
  ///
  /// @[RETURN]
  /// ApiResponse                      - error or success based on result(s)
  ///
  Future<ApiResponse> postLoginApi({required String email, required String password}) async {
    Uri uri = uriLogin();
    Map<String, String> headers = headerNoAuth();
    String body = bodyGeneric(map: <String, String>{
      'email': email,
      'password': password,
    });

    try {
      Response response = await client.post(uri, headers: headers, body: body);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      DjangoResultsApiJson res = DjangoResultsApiJson.fromJson(json: decoded);
      switch (response.statusCode) {
        case 200: // success
          return ApiResponseSuccess(message: res.message, results: res.results);
        case 400: // bad request
          return ApiResponseError(message: res.message);
        case 500: // server error
          return ApiResponseError(message: res.message);
        default: // who knows
          return ApiResponseError(message: res.message);
      }
    } catch (e) {
      logApiPrint("AuthService.postLoginApi: error\n${e.toString()}", tag: "EXP");
      return ApiResponseError();
    }
  }

  Uri uriLogin() {
    return Uri.parse("$uriApiBase/login/");
  }

  /// ======================= //
  ///
  /// SIGN UP
  ///
  /// callSignupApi
  /// @[PARAM]
  /// String email                     - email to login with
  /// String password                  - password to login with
  ///
  /// @[RETURN]
  /// ApiResponse                      - error or success based on result(s)
  ///
  Future<ApiResponse> postSignupApi({required String email, required String password}) async {
    Uri uri = uriSignup();
    Map<String, String> headers = headerNoAuth();
    String body = bodyGeneric(map: <String, String>{
      'email': email,
      'password': password,
    });

    try {
      Response response = await client.post(uri, headers: headers, body: body);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      DjangoResultsApiJson res = DjangoResultsApiJson.fromJson(json: decoded);
      switch (response.statusCode) {
        case 201: // success
          return ApiResponseSuccess(message: res.message, results: res.results);
        case 200: // success
          return ApiResponseSuccess(message: res.message, results: res.results);
        case 400: // bad request
          return ApiResponseError(message: res.message);
        case 500: // server error
          return ApiResponseError(message: res.message);
        default: // who knows
          return ApiResponseError(message: res.message);
      }
    } catch (e) {
      logApiPrint("AuthService.postSignupApi: error\n${e.toString()}", tag: "EXP");
      return ApiResponseError();
    }
  }

  Uri uriSignup() {
    return Uri.parse("$uriApiBase/signup/");
  }

  String getErrorMessage(Map<String, dynamic> decoded) {
    if (decoded['error'] != null) {
      return decoded['error'];
    } else if (decoded['message'] != null) {
      return decoded['message'];
    } else if (decoded['email'] != null) {
      return decoded['email'];
    } else if (decoded['non_field_errors'] != null) {
      return decoded['non_field_errors'][0];
    } else {
      return "Error. Please try again later.";
    }
  }
}
