import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/auth_user.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class AuthRepo {
  static Future<ApiResponse<String>> createAuthToken(AuthUser authUser) async {
    try {
      final response = await http.post(
        Uri.parse("$apiGatewayUrl/auth/token"),
        body: jsonEncode(authUser.toJson()),
        headers: {"Content-Type": "application/json"},
      );

      final decodedResponse = await compute<String, ApiResponse<String>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(data: decodedJson["data"] as String);
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "AuthRepo.createAuthToken",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
