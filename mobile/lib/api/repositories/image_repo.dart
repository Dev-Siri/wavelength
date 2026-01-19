import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:wavelength/api/models/playlist_theme_color.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/constants.dart";
import "package:image_picker/image_picker.dart";
import "package:wavelength/api/models/uploadthing_file.dart";

class ImageRepo {
  static Future<ApiResponse<ThemeColor>> fetchImageThemeColor({
    required String url,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$apiGatewayUrl/image/theme-color?imageUrl=$url"),
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
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "ImageRepo.fetchImageThemeColor",
      );
      return ApiResponseError(message: errorString);
    }
  }

  static Future<ApiResponse<UploadThingFile>> uploadImage(
    XFile imageFile,
  ) async {
    try {
      final fileBytes = await imageFile.readAsBytes();
      final response = await http.post(
        Uri.parse("$apiGatewayUrl/image/manual-upload"),
        body: fileBytes,
        headers: {
          "Content-Type": imageFile.mimeType ?? "application/octet-stream",
        },
      );

      final decodedResponse =
          await compute<String, ApiResponse<UploadThingFile>>((fileResponse) {
            final decodedJson = jsonDecode(fileResponse);
            final isSuccessful = decodedJson["success"] as bool;

            if (isSuccessful) {
              return ApiResponseSuccess(
                data: UploadThingFile.fromJson(decodedJson["data"]),
              );
            }

            return ApiResponseError(message: decodedJson["message"] as String);
          }, response.body);

      return decodedResponse;
    } catch (e) {
      final errorString = e.toString();
      DiagnosticsRepo.reportError(
        error: errorString,
        source: "ImageRepo.uploadImage",
      );
      return ApiResponseError(message: errorString);
    }
  }
}
