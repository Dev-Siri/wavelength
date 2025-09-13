import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/playlist_theme_color.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/constants.dart";

class ImageRepo {
  static Future<ApiResponse<ThemeColor>> fetchImageThemeColor({
    required String url,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/image/theme-color?url=$url"),
      );
      final decodedResponse = await compute<String, ApiResponse<ThemeColor>>((
        stringResponse,
      ) {
        final decodedJson = jsonDecode(stringResponse);
        final isSuccessful = decodedJson["success"] as bool;

        if (isSuccessful) {
          return ApiResponseSuccess(
            data: ThemeColor.fromJson(decodedJson["data"]),
          );
        }

        return ApiResponseError(message: decodedJson["message"] as String);
      }, response.body);

      return decodedResponse;
    } catch (e) {
      return ApiResponseError(message: e.toString());
    }
  }
}
