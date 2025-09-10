import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/playlist_theme_color.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/constants.dart";

class ImageRepo {
  static Future<ApiResponse> fetchImageThemeColor({required String url}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/image/theme-color?url=$url"),
      );
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (themeColor) => ThemeColor.fromJson(themeColor),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
