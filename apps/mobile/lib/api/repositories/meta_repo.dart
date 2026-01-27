import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/version_status.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";

class MetaRepo {
  static Future<ApiResponse<VersionStatus>> fetchVersionStatus() async {
    try {
      final response = await http.get(Uri.parse("$apiGatewayUrl/meta/vstatus"));
      final decodedResponse = await compute<String, ApiResponse<VersionStatus>>(
        (stringResponse) {
          final decodedJson = jsonDecode(stringResponse);
          final isSuccessful = (decodedJson["success"] as bool);

          if (isSuccessful) {
            return ApiResponseSuccess(
              data: VersionStatus.fromJson(decodedJson["data"]),
            );
          }

          return ApiResponseError(message: decodedJson["message"] as String);
        },
        response.body,
      );

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "MetaRepo.fetchVersionStatus",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
