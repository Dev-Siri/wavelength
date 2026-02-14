import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/auth_user.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class AuthRepo {
  static Future<ApiResponse<String>> mobileOAuth({
    required String serverAuthCode,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$apiGatewayUrl/auth/login/google/mobile?code=$serverAuthCode",
        ),
      );

      final decodedResponse = await compute<String, ApiResponse<String>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: decodedJson["data"]["authCode"] as String,
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AuthRepo.mobileOAuth",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<String>> consumeAuthToken({
    required String authCode,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/auth/token/consume?code=$authCode"),
      );

      final decodedResponse = await compute<String, ApiResponse<String>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: decodedJson["data"]["authToken"] as String,
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AuthRepo.consumeAuthToken",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<AuthUser>> fetchUserProfile({
    required String authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/auth/profile"),
        headers: {"Authorization": "Bearer $authToken"},
      );

      final decodedResponse = await compute<String, ApiResponse<AuthUser>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: AuthUser.fromJson(decodedJson["data"]),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AuthRepo.fetchUserProfile",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
